open Import
open Extraction_plugin
open Miniml
module T = Ts_type

type ty = T.t

type binder =
  { id : ml_ident
  ; ty : ty
  }

type cause =
  | Magic
  | Mismatch

type expr =
  | Local of int * ty list
  | Global of global * ty list
  | Apply of expr * arg list
  | Lambda of int list * binder list * ty * expr
  | Let of binder * int list * expr * expr * ty
  | Construct of global * ty list * expr list
  | Match of match_
  | Unpack of unpack
  | Fix of int * fixdef array
  | Fail of string
  | Dummy
  | Cast of expr * ty * ty * cause
  | Uint of Uint63.t
  | Float of Float64.t
  | String of Pstring.t
  | Parray of expr list * expr
  | Tuple of expr list

and arg =
  { expr : expr
  ; atomic : bool
  }

and match_ =
  { scrutinee : expr
  ; ind : global
  ; tyargs : ty list
  ; branches : branch list
  ; result : ty
  }

and branch =
  { binders : binder list
  ; pattern : pattern
  ; body : expr
  }

and pattern =
  | Ctor of global * int option list
  | Default of { binds_scrutinee : bool }

and unpack =
  { tuple : expr
  ; elements : ty list
  ; binders : binder list
  ; positions : int option list
  ; body : expr
  ; result : ty
  }

and fixdef =
  { name : Names.Id.t
  ; tparams : int list
  ; ty : ty
  ; body : expr
  }

type stats = { reconstruction_casts : int }

let arity = function
  | Lambda (_, bs, _, _) -> List.length bs
  | _ -> 0
;;

type local =
  { tparams : int list
  ; ty : ty
  }

type ctx =
  { env : Ts_env.t
  ; locals : local list
  ; next : int ref
  ; bounds : (int * ty) list
  ; refined : (int * global) list
  }

type branch_input =
  { binder_ids : ml_ident list
  ; binder_types : ty list
  ; context : ctx
  ; pattern : pattern
  ; body : ml_ast
  }

let push ctx tys =
  { ctx with locals = List.map tys ~f:(fun ty -> { tparams = []; ty }) @ ctx.locals }
;;

let unsupported what =
  CErrors.user_err
    Pp.(str "TypeScript extraction does not support " ++ str what ++ str ".")
;;

let meta = T.meta

let primitive p args =
  match Ts_primitives.global p with
  | Some r -> T.Glob (r, args)
  | None -> meta ()
;;

let generalise ctx ~kept ts =
  let free = kept @ T.metas (List.map ctx.locals ~f:(fun (l : local) -> l.ty)) in
  List.filter_map (T.metas ts) ~f:(fun m ->
    if List.exists free ~f:(T.same m)
    then None
    else (
      Int.incr ctx.next;
      T.bind m (T.Var !(ctx.next));
      Some (m, !(ctx.next))))
;;

let unnamed_params = function
  | Lambda (_, bs, _, _) ->
    List.filter_map bs ~f:(fun (b : binder) ->
      match b.id, T.resolve b.ty with
      | Miniml.Dummy, T.Meta m -> Some m
      | _ -> None)
  | _ -> []
;;

let generalised ctx e t =
  match e with
  | Lambda _ -> List.map (generalise ctx ~kept:(unnamed_params e) [ t ]) ~f:snd, e
  | Fix (i, defs) when Array.for_all defs ~f:(fun (d : fixdef) -> arity d.body > 0) ->
    let own = Array.map defs ~f:(fun (d : fixdef) -> T.metas [ d.ty ]) in
    let group =
      generalise
        ctx
        ~kept:
          (List.concat_map (Array.to_list defs) ~f:(fun (d : fixdef) ->
             unnamed_params d.body))
        (Array.to_list (Array.map defs ~f:(fun (d : fixdef) -> d.ty)))
    in
    let tparams ms =
      List.filter_map ms ~f:(fun m ->
        List.find_map group ~f:(fun (m', i) -> if T.same m m' then Some i else None))
    in
    let defs =
      Array.mapi defs ~f:(fun j (d : fixdef) -> { d with tparams = tparams own.(j) })
    in
    defs.(i).tparams, Fix (i, defs)
  | _ -> [], e
;;

let cast cause ~expected (e, t) = Cast (e, t, expected, cause)

let ctor_of_ind env (c : global) (ind : global) =
  T.is_ctor c && Names.GlobRef.CanOrd.equal (Ts_env.ctor env c).ind.glob ind.glob
;;

let fits ctx ~expected t =
  let reduce = T.reduce ~unfold:(Ts_env.unfold ctx.env) in
  T.unify expected t
  || (match T.resolve t, T.resolve expected with
      | T.Var v, _ ->
        (match List.Assoc.find ctx.bounds ~equal:Int.equal v with
         | Some b -> T.unify expected b
         | None -> false)
      | T.Glob (c, []), T.Glob (ind, _) -> ctor_of_ind ctx.env c ind
      | _ -> false)
  || T.unify (reduce expected) (reduce t)
;;

let coerce ctx ~expected (e, t) =
  if fits ctx ~expected t then e, t else cast Mismatch ~expected (e, t), expected
;;

let rec refine refined t =
  match T.resolve t with
  | T.Var v as t ->
    (match List.Assoc.find refined ~equal:Int.equal v with
     | Some c -> T.Glob (c, [])
     | None -> t)
  | T.Glob (r, ts) -> T.Glob (r, List.map ts ~f:(refine refined))
  | T.Arrow (a, b) -> T.Arrow (refine refined a, refine refined b)
  | T.Tuple ts -> T.Tuple (List.map ts ~f:(refine refined))
  | T.Union ts -> T.Union (List.map ts ~f:(refine refined))
  | T.Cond { on; arms } ->
    T.Cond
      { on = refine refined on
      ; arms = List.map arms ~f:(fun (c, t) -> c, refine refined t)
      }
  | T.Forall (vs, t) -> T.Forall (vs, refine refined t)
  | (T.Meta _ | T.Erased | T.Never) as t -> t
;;

let visible ctx t = T.reduce t ~unfold:(Ts_env.unfold ctx.env)
let known ctx t = visible ctx (refine ctx.refined t)

let rich ctx t =
  match T.resolve t with
  | T.Glob (r, _) -> Option.is_some (Ts_env.alias ctx.env r)
  | T.Cond _ | T.Union _ | T.Tuple _ -> true
  | T.Var _ | T.Meta _ | T.Arrow _ | T.Erased | T.Never | T.Forall _ -> false
;;

let one_arrow t =
  match T.resolve t with
  | T.Union ts ->
    (match
       List.filter ts ~f:(fun t ->
         match T.resolve t with
         | T.Arrow _ -> true
         | _ -> false)
     with
     | [ a ] -> Some a
     | _ -> None)
  | _ -> None
;;

let envelope ctx t =
  let rec lower = function
    | T.Never -> true
    | T.Arrow (_, result) -> lower (T.resolve result)
    | T.Var _
    | T.Meta _
    | T.Glob _
    | T.Erased
    | T.Tuple _
    | T.Union _
    | T.Cond _
    | T.Forall _ -> false
  in
  match T.resolve (visible ctx t) with
  | T.Union [ a; b ] ->
    let branch arrow base =
      match T.resolve arrow with
      | T.Arrow (input, result)
        when lower (T.resolve input) && T.equal (visible ctx result) (visible ctx t) ->
        Some (visible ctx base)
      | T.Var _
      | T.Meta _
      | T.Glob _
      | T.Arrow _
      | T.Erased
      | T.Never
      | T.Tuple _
      | T.Union _
      | T.Cond _
      | T.Forall _ -> None
    in
    Option.first_some (branch a b) (branch b a)
  | T.Var _
  | T.Meta _
  | T.Glob _
  | T.Arrow _
  | T.Erased
  | T.Never
  | T.Tuple _
  | T.Union _
  | T.Cond _
  | T.Forall _ -> None
;;

let rec constrain_envelope ctx expected actual =
  match envelope ctx expected with
  | None -> ()
  | Some base ->
    (match T.resolve base, T.resolve actual with
     | T.Meta _, _ -> ()
     | base, actual when T.unify base actual -> ()
     | _, T.Arrow (_, result) -> constrain_envelope ctx expected result
     | _, _ -> ())
;;

let unmagic = function
  | MLmagic a -> a
  | a -> a
;;

let eta k a =
  if k <= 0
  then a
  else (
    let ids, body = Mlutil.collect_lams a in
    let args = List.init k ~f:(fun i -> MLrel (k - i)) in
    let body =
      match Mlutil.ast_lift k body with
      | MLapp (f, xs) -> MLapp (f, xs @ args)
      | f -> MLapp (f, args)
    in
    Mlutil.named_lams
      ids
      (Mlutil.named_lams (List.init k ~f:(fun _ -> Id Mlutil.anonymous_name)) body))
;;

let is_forall t =
  match T.resolve t with
  | T.Forall _ -> true
  | T.Var _
  | T.Meta _
  | T.Glob _
  | T.Arrow _
  | T.Erased
  | T.Never
  | T.Tuple _
  | T.Union _
  | T.Cond _ -> false
;;

let lifted_params (s : T.schema) =
  List.exists s.tparams ~f:(fun (p : T.tparam) -> Option.is_some p.bound)
;;

let lifted_var (s : T.schema) = function
  | T.Var v ->
    (match List.nth s.tparams (v - 1) with
     | Some { T.bound = Some b; _ } -> Some (v, b)
     | Some { T.bound = None; _ } | None -> None)
  | _ -> None
;;

let rec join expected tys : ty =
  let elements : ty -> ty list option = function
    | T.Tuple ts -> Some ts
    | T.Var _
    | T.Meta _
    | T.Glob _
    | T.Arrow _
    | T.Erased
    | T.Never
    | T.Union _
    | T.Cond _
    | T.Forall _ -> None
  in
  let joined =
    match List.map tys ~f:elements with
    | Some first :: _ as tuples
      when List.for_all tuples ~f:(function
             | Some ts -> List.length ts = List.length first
             | None -> false) ->
      let tuples = List.filter_opt tuples in
      T.Tuple (List.map (List.transpose_exn tuples) ~f:(join None))
    | _ ->
      let members =
        List.concat_map tys ~f:(fun t ->
          match T.resolve t with
          | T.Union ts -> ts
          | t -> [ t ])
      in
      (match
         List.fold members ~init:[] ~f:(fun acc t ->
           if List.exists acc ~f:(fun u -> T.unify u t) then acc else acc @ [ t ])
       with
       | [ t ] -> t
       | ts -> T.Union ts)
  in
  Option.iter expected ~f:(fun e -> ignore (T.unify e joined : bool));
  joined
;;

let arrow t =
  match T.resolve t with
  | T.Arrow (a, b) -> Some (a, b)
  | T.Meta _ as m ->
    let a = meta ()
    and b = meta () in
    if T.unify m (T.Arrow (a, b)) then Some (a, b) else None
  | T.Var _
  | T.Glob _
  | T.Erased
  | T.Never
  | T.Tuple _
  | T.Union _
  | T.Cond _
  | T.Forall _ -> None
;;

let rec arrows n t =
  if n = 0
  then Some ([], t)
  else
    let open Option.Let_syntax in
    let%bind a, b = arrow t in
    let%map ps, r = arrows (n - 1) b in
    a :: ps, r
;;

let pattern ids pat =
  let n = List.length ids in
  match pat with
  | Pusual r -> Ctor (r, List.init n ~f:(fun k -> Some (n - k)))
  | Pcons (r, ps) ->
    Ctor
      ( r
      , List.map ps ~f:(function
          | Prel j -> Some j
          | Pwild -> None
          | Pcons _ | Ptuple _ | Pusual _ -> unsupported "nested patterns") )
  | Prel 1 when n = 1 -> Default { binds_scrutinee = true }
  | Pwild when n = 0 -> Default { binds_scrutinee = false }
  | Ptuple _ -> unsupported "tuple patterns"
  | Prel _ | Pwild -> unsupported "this shape of pattern"
;;

let position positions j =
  Option.map (List.findi positions ~f:(fun _ p -> Option.mem p j ~equal:Int.equal)) ~f:fst
;;

(* Extraction casts a term to the type it expects when the two do not
   unify, and it expects Tunknown of a dependent result. The simplifier
   moves that cast to the head of an application, into the body of a
   let, and into the branches of a match. *)
let rec check ctx a expected =
  if rich ctx expected then check_rich ctx a expected else check_ml ctx a expected

and loose ctx a =
  match a with
  | MLletin (id, a1, a2) -> let_in ctx id a1 a2 None
  | MLcase (_, s, pv) -> case ctx s pv None
  | MLmagic a1 -> loose ctx a1
  | MLapp (MLmagic f, args) -> infer ctx (MLapp (f, args))
  | _ -> infer ctx a

and against ctx a = function
  | Some expected -> check ctx a expected
  | None -> loose ctx a

and check_ml ctx a expected =
  match T.resolve expected, a with
  | _, MLletin (id, a1, a2) -> let_in ctx id a1 a2 (Some expected)
  | _, MLcase (_, s, pv) -> case ctx s pv (Some expected)
  | T.Forall (vs, body), MLlam _ -> generic ctx vs body a expected
  | _, MLlam _ ->
    let ids, body = Mlutil.collect_lams a in
    let ids = List.rev ids in
    (match arrows (List.length ids) expected with
     | Some (params, result) -> lambda ctx ids params result body, expected
     | None -> cast Mismatch ~expected (infer_lambda ctx ids body), expected)
  | _, MLmagic a1 -> cast Magic ~expected (infer ctx a1), expected
  | _, MLexn s -> Fail s, expected
  | _, MLaxiom s -> Fail ("AXIOM TO BE REALIZED (" ^ s ^ ")"), expected
  | ( _
    , ( MLrel _
      | MLapp _
      | MLglob _
      | MLcons _
      | MLtuple _
      | MLfix _
      | MLdummy _
      | MLuint _
      | MLfloat _
      | MLstring _
      | MLparray _ ) ) -> coerce ctx ~expected (infer ctx a)

(* A type that TypeScript reduces to one ML's unifier handles is checked
   as that type. One that only the matches around [a] reduce, by the
   constructor each picks for a lifted parameter, is checked as the
   reduced type and cast to [expected], since TypeScript does not narrow
   a conditional when it narrows the parameter's value. *)
and check_rich ctx a expected =
  let visible = visible ctx expected in
  if not (rich ctx visible)
  then fst (check ctx (unmagic a) visible), expected
  else (
    let known = known ctx expected in
    if not (rich ctx known)
    then (
      let e, t = check ctx (unmagic a) known in
      Cast (e, t, expected, Magic), expected)
    else (
      match a with
      | MLmagic a1 -> check_rich ctx a1 expected
      | MLletin (id, a1, a2) -> let_in ctx id a1 a2 (Some expected)
      | MLlam _ when Option.is_some (envelope ctx expected) ->
        let e, t = infer ctx a in
        let base = Option.value_exn (envelope ctx expected) in
        if List.is_empty (T.metas [ base ]) then constrain_envelope ctx expected t;
        Cast (e, t, expected, Mismatch), expected
      | MLlam _ when Option.is_some (one_arrow known) ->
        fst (check ctx a (Option.value_exn (one_arrow known))), expected
      | MLcase (_, s, pv)
        when Array.exists pv ~f:(fun (_, p, _) -> Option.is_some (ctor_of p)) ->
        case_rich ctx s pv expected
      | _ ->
        let e, t = infer ctx a in
        let members =
          match T.resolve known with
          | T.Union ts -> ts
          | k -> [ k ]
        in
        if
          T.equal t expected
          || List.exists members ~f:(fun m ->
            (not (rich ctx m)) && fits ctx ~expected:m t)
        then e, expected
        else Cast (e, t, expected, Mismatch), expected))

and let_in ctx id a body expected =
  let e, t = infer ctx a in
  let tparams, e = generalised ctx e t in
  let body, result =
    against { ctx with locals = { tparams; ty = t } :: ctx.locals } body expected
  in
  Let ({ id; ty = t }, tparams, e, body, result), result

and lambda ctx ids params result body =
  let binders = List.map2_exn ids params ~f:(fun id ty -> { id; ty }) in
  let body, result = check (push ctx (List.rev params)) body result in
  Lambda ([], binders, result, body)

and generic ctx vs body a expected =
  let fresh = List.map vs ~f:(fun _ -> T.fresh ()) in
  let body = T.instantiate vs (List.map fresh ~f:(fun i -> T.Var i)) body in
  let rec drop k a =
    match a with
    | _ when k = 0 -> a
    | MLlam (_, a) -> drop (k - 1) (Mlutil.ast_subst (MLdummy Ktype) a)
    | a -> MLapp (a, List.init k ~f:(fun _ -> MLdummy Ktype))
  in
  let a = drop (List.length vs) a in
  match check ctx (eta (1 - Mlutil.nb_lams a) a) body with
  | Lambda ([], bs, result, e), _ -> Lambda (fresh, bs, result, e), expected
  | _ -> coerce ctx ~expected (infer ctx a)

and infer_lambda ctx ids body =
  let params = List.map ids ~f:(fun _ -> meta ()) in
  let result = meta () in
  lambda ctx ids params result body, T.curried params result

and ctor_of = function
  | Pusual r | Pcons (r, _) -> Some r
  | Prel _ | Pwild | Ptuple _ -> None

and scrutinize ctx r s pv =
  let ind = (Ts_env.ctor ctx.env r).ind in
  let tyargs = List.init (Ts_env.ind ctx.env ind).nparams ~f:(fun _ -> meta ()) in
  let ind_ty = T.Glob (ind, tyargs) in
  let scrutinee, st = coerce ctx ~expected:ind_ty (infer ctx s) in
  let lifted =
    match T.resolve st with
    | T.Var v when List.Assoc.mem ctx.bounds ~equal:Int.equal v -> Some v
    | _ -> None
  in
  let branch (ids, pat, body) =
    let n = List.length ids in
    let pattern = pattern ids pat in
    let binder_ty i =
      match pattern with
      | Default { binds_scrutinee = true } -> ind_ty
      | Default { binds_scrutinee = false } -> meta ()
      | Ctor (r, fields) ->
        let args = (Ts_env.ctor ctx.env r).args in
        (match position fields (n - i) with
         | Some k ->
           let bounds =
             List.filter_map (Ts_env.ctor ctx.env r).lifted ~f:(fun (p : T.tparam) ->
               p.bound)
           in
           T.subst (tyargs @ bounds) (List.nth_exn args k)
         | None -> meta ())
    in
    let tys = List.init n ~f:binder_ty in
    let inner = push ctx (List.rev tys) in
    let inner =
      match lifted, pattern with
      | Some v, Ctor (c, _) -> { inner with refined = (v, c) :: inner.refined }
      | _ -> inner
    in
    { binder_ids = ids; binder_types = tys; context = inner; pattern; body }
  in
  ind, tyargs, scrutinee, List.map (Array.to_list pv) ~f:branch

and case_rich ctx s pv expected =
  let r = Array.find_map_exn pv ~f:(fun (_, p, _) -> ctor_of p) in
  let ind, tyargs, scrutinee, branches = scrutinize ctx r s pv in
  let branches =
    List.map branches ~f:(fun { binder_ids; binder_types; context; pattern; body } ->
      let body, _ = check context body expected in
      { binders = List.map2_exn binder_ids binder_types ~f:(fun id ty -> { id; ty })
      ; pattern
      ; body
      })
  in
  Match { scrutinee; ind; tyargs; branches; result = expected }, expected

and case ctx s pv expected =
  match Array.find_map pv ~f:(fun (_, p, _) -> ctor_of p), pv with
  | None, [| (ids, Ptuple ps, body) |] -> unpack ctx ids ps s body expected
  | None, [| ([ id ], Prel 1, body) |] -> let_in ctx id s body expected
  | None, [| ([], Pwild, body) |] ->
    let_in ctx Miniml.Dummy s (Mlutil.ast_lift 1 body) expected
  | None, [||] -> Fail "absurd case", Option.value_or_thunk expected ~default:meta
  | None, _ -> unsupported "this shape of match"
  | Some r, _ ->
    let ind, tyargs, scrutinee, branches = scrutinize ctx r s pv in
    let constrained =
      match Option.map expected ~f:T.resolve with
      | None | Some (T.Meta _) -> None
      | Some
          (( T.Var _
           | T.Glob _
           | T.Arrow _
           | T.Erased
           | T.Never
           | T.Tuple _
           | T.Union _
           | T.Cond _
           | T.Forall _ ) as t) -> Some t
    in
    let branch { binder_ids; binder_types; context; pattern; body } =
      let body, t = against context body constrained in
      ( { binders = List.map2_exn binder_ids binder_types ~f:(fun id ty -> { id; ty })
        ; pattern
        ; body
        }
      , t )
    in
    let branches, tys = List.unzip (List.map branches ~f:branch) in
    let result =
      match constrained with
      | Some t -> t
      | None -> join expected tys
    in
    Match { scrutinee; ind; tyargs; branches; result }, result

and unpack ctx ids ps s body expected =
  let n = List.length ids in
  let positions =
    List.map ps ~f:(function
      | Prel j -> Some j
      | Pwild -> None
      | Pcons _ | Ptuple _ | Pusual _ -> unsupported "nested patterns")
  in
  let tuple, t = infer ctx s in
  let elements, tuple =
    match t with
    | T.Tuple ts when List.length ts = List.length ps -> ts, tuple
    | t ->
      let ts = List.map ps ~f:(fun _ -> meta ()) in
      ts, Cast (tuple, t, T.Tuple ts, Mismatch)
  in
  let binder_ty i =
    match position positions (n - i) with
    | Some k -> List.nth_exn elements k
    | None -> meta ()
  in
  let tys = List.init n ~f:binder_ty in
  let body, result = against (push ctx (List.rev tys)) body expected in
  ( Unpack
      { tuple
      ; elements
      ; binders = List.map2_exn ids tys ~f:(fun id ty -> { id; ty })
      ; positions
      ; body
      ; result
      }
  , result )

and infer ctx a =
  match a with
  | MLrel n ->
    let { tparams; ty } = List.nth_exn ctx.locals (n - 1) in
    let tys = List.map tparams ~f:(fun _ -> meta ()) in
    Local (n, tys), T.instantiate tparams tys ty
  (* Extraction casts a use of a let-bound local at a second type, as
     OCaml's value restriction asks; a local that reconstruction
     generalised needs no cast. *)
  | MLapp (MLmagic (MLrel n), args)
    when not (List.is_empty (List.nth_exn ctx.locals (n - 1)).tparams) ->
    infer ctx (MLapp (MLrel n, args))
  | MLapp (MLmagic (MLglob r), args) when Ts_env.refined ctx.env r ->
    if lifted_params (Ts_env.term ctx.env r).schema
    then apply_schema ctx ~cause:Magic r args
    else apply ~cause:Magic ctx (infer ctx (MLglob r)) args
  | MLapp (MLglob r, args) when lifted_params (Ts_env.term ctx.env r).schema ->
    apply_schema ctx ~cause:Mismatch r args
  | MLglob r ->
    let s = (Ts_env.term ctx.env r).schema in
    let tys =
      List.map s.tparams ~f:(fun (p : T.tparam) ->
        Option.value_or_thunk p.bound ~default:meta)
    in
    Global (r, tys), visible ctx (T.subst tys s.ty)
  | MLapp (MLmagic f, args) ->
    let e, t = infer ctx f in
    if is_forall t
    then apply ctx (e, t) args
    else (
      let m = meta () in
      apply ctx (cast Magic ~expected:m (e, t), m) args)
  | MLapp (f, args) -> apply ctx (infer ctx f) args
  | MLcons (_, r, args) ->
    let c = Ts_env.ctor ctx.env r in
    let n = (Ts_env.ind ctx.env c.ind).nparams in
    let tys = List.init n ~f:(fun _ -> meta ()) in
    let lifted = List.map c.lifted ~f:(fun _ -> meta ()) in
    let all = tys @ lifted in
    let args =
      List.map2_exn args c.args ~f:(fun a t ->
        match T.resolve t with
        | T.Var v when v > n ->
          (match List.nth_exn c.lifted (v - n - 1) with
           | { T.bound = Some bound; _ } ->
             (lifted_arg ctx ~m:(List.nth_exn all (v - 1)) ~bound a).expr
           | { T.bound = None; _ } ->
             CErrors.anomaly (Pp.str "Ts_infer: a lifted binder has a bound."))
        | _ -> fst (check ctx a (T.subst all t)))
    in
    List.iter2_exn lifted c.lifted ~f:(fun m (p : T.tparam) ->
      Option.iter p.bound ~f:(fun b -> ignore (T.unify m b : bool)));
    Construct (r, all, args), T.Glob (c.ind, tys)
  | MLfix (i, ids, defs) ->
    let tys = Array.map defs ~f:(fun _ -> meta ()) in
    let ctx' = push ctx (List.rev (Array.to_list tys)) in
    let defs =
      Array.mapi defs ~f:(fun j d ->
        { name = ids.(j); tparams = []; ty = tys.(j); body = fst (check ctx' d tys.(j)) })
    in
    Fix (i, defs), tys.(i)
  | MLdummy _ -> Dummy, T.Erased
  | MLuint i -> Uint i, primitive Ts_primitives.Int63 []
  | MLfloat f -> Float f, primitive Ts_primitives.Float64 []
  | MLstring s -> String s, primitive Ts_primitives.Pstring []
  | MLtuple es ->
    let es, ts = List.unzip (List.map es ~f:(infer ctx)) in
    Tuple es, T.Tuple ts
  | MLparray (elements, default) ->
    let element = meta () in
    let check_element a = fst (check ctx a element) in
    let elements = List.map (Array.to_list elements) ~f:check_element in
    let default = check_element default in
    Parray (elements, default), primitive Ts_primitives.Parray [ element ]
  | MLlam _ | MLletin _ | MLcase _ | MLmagic _ | MLexn _ | MLaxiom _ ->
    check ctx a (meta ())

and apply_schema ctx ~cause r args =
  let s = (Ts_env.term ctx.env r).schema in
  let tys = List.map s.tparams ~f:(fun _ -> meta ()) in
  let params, result = T.split (List.length args) s.ty in
  let used, rest = List.split_n args (List.length params) in
  let arg a expr = { expr; atomic = Ts_env.atomic a } in
  let applied =
    List.map2_exn params used ~f:(fun p a ->
      match lifted_var s p with
      | Some (v, bound) -> lifted_arg ctx ~m:(List.nth_exn tys (v - 1)) ~bound a
      | None -> arg a (fst (check ctx a (T.subst tys p))))
  in
  List.iteri s.tparams ~f:(fun i (p : T.tparam) ->
    Option.iter p.bound ~f:(fun b -> ignore (T.unify (List.nth_exn tys i) b : bool)));
  apply_rest ctx ~cause (Global (r, tys)) (visible ctx (T.subst tys result)) applied rest

and lifted_arg ctx ~m ~bound a =
  let e, t =
    match a with
    | MLcons (_, c, []) ->
      let c_tys =
        List.init (Ts_env.ind ctx.env (Ts_env.ctor ctx.env c).ind).nparams ~f:(fun _ ->
          meta ())
      in
      Construct (c, c_tys, []), T.Glob (c, [])
    | a -> infer ctx a
  in
  let expr =
    if fits ctx ~expected:bound t
    then (
      if not (T.unify m t) then ignore (T.unify m bound : bool);
      e)
    else (
      ignore (T.unify m bound : bool);
      fst (coerce ctx ~expected:bound (e, t)))
  in
  { expr; atomic = Ts_env.atomic a }

and apply ?(cause = Mismatch) ctx (f, tf) args =
  let arg a expr = { expr; atomic = Ts_env.atomic a } in
  match f with
  | Dummy -> Apply (f, List.map args ~f:(fun a -> arg a (fst (infer ctx a)))), meta ()
  | _ -> apply_rest ctx ~cause f tf [] args

and apply_rest ctx ~cause f tf applied args =
  let arg a expr = { expr; atomic = Ts_env.atomic a } in
  let constrain_candidates candidates =
    List.iter candidates ~f:(fun (expected, actual) ->
      constrain_envelope ctx expected actual);
    let groups =
      List.fold candidates ~init:[] ~f:(fun groups (expected, actual) ->
        match Option.map (envelope ctx expected) ~f:T.resolve with
        | Some (T.Meta m) ->
          let types = Option.value (List.Assoc.find groups ~equal:T.same m) ~default:[] in
          List.Assoc.add groups ~equal:T.same m (actual :: types)
        | Some
            ( T.Var _
            | T.Glob _
            | T.Arrow _
            | T.Erased
            | T.Never
            | T.Tuple _
            | T.Union _
            | T.Cond _
            | T.Forall _ )
        | None -> groups)
    in
    List.iter groups ~f:(fun (m, types) ->
      ignore (T.unify (T.Meta m) (T.union types) : bool))
  in
  let rec go tf applied candidates = function
    | [] ->
      constrain_candidates candidates;
      (if List.is_empty applied then f else Apply (f, List.rev applied)), tf
    | MLdummy _ :: rest when is_forall tf ->
      (match T.resolve tf with
       | T.Forall (v :: vs, body) ->
         let body = T.instantiate [ v ] [ meta () ] body in
         go
           (if List.is_empty vs then body else T.Forall (vs, body))
           applied
           candidates
           rest
       | _ -> CErrors.anomaly (Pp.str "Ts_infer.apply_rest: a generic type binds."))
    | a :: rest as remaining ->
      (match arrow tf with
       | Some (p, r) ->
         let e, _ = check ctx a p in
         let candidates =
           match envelope ctx p, e with
           | Some _, Cast (_, actual, _, _) -> (p, actual) :: candidates
           | (Some _ | None), _ -> candidates
         in
         go r (arg a e :: applied) candidates rest
       | None ->
         constrain_candidates candidates;
         let head = if List.is_empty applied then f else Apply (f, List.rev applied) in
         let inferred = List.map remaining ~f:(infer ctx) in
         let result = meta () in
         let expected = T.curried (List.map inferred ~f:snd) result in
         ( Apply
             ( cast cause ~expected (head, tf)
             , List.map2_exn remaining inferred ~f:(fun a (e, _) -> arg a e) )
         , result ))
  in
  go tf (List.rev applied) [] args
;;

let zonk e =
  let casts = ref 0 in
  let binder (b : binder) =
    match b.id, T.resolve b.ty with
    | Miniml.Dummy, T.Meta _ -> { b with ty = T.Erased }
    | _ -> { b with ty = T.zonk b.ty }
  in
  let rec go = function
    | (Fail _ | Dummy | Uint _ | Float _ | String _) as e -> e
    | Local (n, tys) -> Local (n, List.map tys ~f:T.zonk)
    | Global (r, tys) -> Global (r, List.map tys ~f:T.zonk)
    | Apply (f, args) ->
      Apply (go f, List.map args ~f:(fun a -> { a with expr = go a.expr }))
    | Lambda (vs, bs, t, b) -> Lambda (vs, List.map bs ~f:binder, T.zonk t, go b)
    | Let (b, tparams, e1, e2, t) -> Let (binder b, tparams, go e1, go e2, T.zonk t)
    | Construct (r, tys, args) ->
      Construct (r, List.map tys ~f:T.zonk, List.map args ~f:go)
    | Match m ->
      Match
        { scrutinee = go m.scrutinee
        ; ind = m.ind
        ; tyargs = List.map m.tyargs ~f:T.zonk
        ; branches =
            List.map m.branches ~f:(fun br ->
              { br with binders = List.map br.binders ~f:binder; body = go br.body })
        ; result = T.zonk m.result
        }
    | Unpack u ->
      Unpack
        { u with
          tuple = go u.tuple
        ; elements = List.map u.elements ~f:T.zonk
        ; binders = List.map u.binders ~f:binder
        ; body = go u.body
        ; result = T.zonk u.result
        }
    | Tuple es -> Tuple (List.map es ~f:go)
    | Parray (es, d) -> Parray (List.map es ~f:go, go d)
    | Fix (i, defs) ->
      Fix
        ( i
        , Array.map defs ~f:(fun (d : fixdef) ->
            { d with ty = T.zonk d.ty; body = go d.body }) )
    | Cast (e, from, target, cause) ->
      let e = go e in
      let from = T.zonk from
      and target = T.zonk target in
      (match e, from, target with
       | (Dummy | Fail _), _, _ | _, _, (T.Erased | T.Never) -> e
       | _, from, target when T.equal from target -> e
       | _ ->
         (match cause with
          | Mismatch -> Int.incr casts
          | Magic -> ());
         Cast (e, from, target, cause))
  in
  let e = go e in
  e, { reconstruction_casts = !casts }
;;

let declaration env r a =
  let { Ts_env.schema; arity } = Ts_env.term env r in
  let ctx =
    { env
    ; locals = []
    ; next = ref (List.length schema.tparams)
    ; bounds =
        List.filter_mapi schema.tparams ~f:(fun i (p : T.tparam) ->
          Option.map p.bound ~f:(fun b -> i + 1, b))
    ; refined = []
    }
  in
  let expected = schema.ty in
  let e, ty =
    if arity = 0
    then check ctx a expected
    else (
      let params, result = T.split arity expected in
      let body =
        match a with
        | MLaxiom _ | MLexn _ ->
          lambda ctx (List.init arity ~f:(fun _ -> Miniml.Dummy)) params result a
        | a ->
          let ids, body =
            Mlutil.collect_n_lams arity (eta (arity - Mlutil.nb_lams a) a)
          in
          lambda ctx (List.rev ids) params result body
      in
      body, expected)
  in
  let e, stats = zonk e in
  e, T.zonk ty, stats
;;
