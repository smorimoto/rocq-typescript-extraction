open Import
open Names
open Extraction_plugin
open Miniml
module E = EConstr
module D = Context.Rel.Declaration
module Refmap = Table.Refmap'
module T = Ts_type

type alias =
  { vars : int
  ; parameters : int list
  ; positions : int list
  ; schema : T.schema
  }

type ctor =
  { lifted : T.tparam list
  ; args : T.t list
  }

type t =
  { terms : T.schema Refmap.t
  ; aliases : alias Refmap.t
  ; ctors : ctor Refmap.t
  ; fields : Id.t list Refmap.t
  ; member : global -> ml_type -> T.schema option
  ; scope : ModPath.t -> Environ.env option
  }

type lifted =
  { var : int
  ; bound : ml_type
  }

type field =
  { proj : Constant.t
  ; pos : int
  ; fname : Id.t
  }

type fresh =
  { mutable next : int
  ; mutable named : (int * Id.t) list
  }

type approximation =
  | Upper
  | Lower
  | Exact
[@@deriving equal]

let reverse = function
  | Upper -> Lower
  | Lower -> Upper
  | Exact -> Exact
;;

type recursion =
  { head : E.t
  ; args : E.t list
  ; decreasing : int
  ; depth : int
  ; self : T.t
  }

type ctx =
  { state : Common.State.t
  ; base : Environ.env
  ; env : Environ.env
  ; sigma : Evd.evar_map
  ; rels : E.rel_context
  ; lifted : (int * lifted) list
  ; quantified : (int * int) list
  ; vars : int
  ; opaque : global -> bool
  ; is_function : global -> bool
  ; alias : global -> alias option
  ; fields_of : global -> field list
  ; projection : Constant.t -> (global * int) option
  ; records : (int * int list) list
  ; fresh : fresh option
  ; constant : global option
  ; owner : global option
  ; recursion : recursion option
  ; approximation : approximation
  ; existentials : int list
  }

let rec lossy ~opaque = function
  | Tunknown -> true
  | Tglob (r, args) -> opaque r || List.exists args ~f:(lossy ~opaque)
  | Tarr (a, b) -> lossy ~opaque a || lossy ~opaque b
  | Tmeta { contents = Some t; _ } -> lossy ~opaque t
  | Tmeta _ | Tvar _ | Tvar' _ | Tdummy _ | Taxiom -> false
;;

let depth ctx = List.length ctx.rels
let push ctx d = { ctx with env = E.push_rel d ctx.env; rels = d :: ctx.rels }
let level ctx n = depth ctx - n

let binder_entry ctx assoc k =
  match E.kind ctx.sigma k with
  | Rel n -> List.Assoc.find assoc ~equal:Int.equal (level ctx n)
  | _ -> None
;;

type kind =
  | Type
  | Logical
  | Info
[@@deriving equal]

let kind env sigma t =
  if Reductionops.is_arity env sigma t
  then Type
  else (
    let q = Retyping.get_sort_quality_of env sigma t in
    if Sorts.Quality.is_qprop q || Sorts.Quality.is_qsprop q then Logical else Info)
;;

(* Extraction numbers the type variables of [k] after the binders of
   sorts in the context, so under a quantified binder it mentions
   none. *)
let extract ctx k =
  match
    Extraction.extract_with_type
      ctx.state
      ctx.base
      ctx.sigma
      (E.it_mkLambda_or_LetIn k ctx.rels)
  with
  | Some (_, ml)
    when Mlutil.type_maxvar ml <= if List.is_empty ctx.quantified then ctx.vars else 0 ->
    Some ml
  | Some _ | None -> None
;;

let ctor (r : global) ind j = { r with glob = GlobRef.ConstructRef (ind, j) }

let literals r constructors =
  let code c = String.strip (Table.find_custom c) in
  let codes = List.map constructors ~f:code in
  let literal s =
    String.equal s "true"
    || String.equal s "false"
    || (String.length s >= 2 && Char.equal s.[0] '"')
    || (Ts_print.is_atom s
        && (Char.equal s.[0] '-' || (Char.( >= ) s.[0] '0' && Char.( <= ) s.[0] '9')))
  in
  List.for_all constructors ~f:Table.is_custom
  && List.for_all codes ~f:literal
  &&
  let sorted = List.dedup_and_sort ~compare:String.compare in
  match code r with
  | "boolean" -> [%equal: string list] (sorted codes) [ "false"; "true" ]
  | ty ->
    [%equal: string list]
      (sorted (List.map (Ts_print.union_members ty) ~f:String.strip))
      (sorted codes)
;;

let lossless ctx k =
  match extract ctx k with
  | Some ml when not (lossy ~opaque:ctx.opaque ml) -> Some (T.of_ml ml)
  | Some _ | None -> None
;;

let constructors (r : global) =
  match r.glob with
  | GlobRef.IndRef ind ->
    let _, oib = Global.lookup_inductive ind in
    List.init (Array.length oib.mind_consnames) ~f:(fun j -> ctor r ind (j + 1))
  | GlobRef.VarRef _ | GlobRef.ConstRef _ | GlobRef.ConstructRef _ ->
    CErrors.anomaly (Pp.str "Ts_kernel.constructors: an enumeration is an inductive.")
;;

let enumeration = function
  | Tglob (({ glob = GlobRef.IndRef ind; _ } as r), [])
    when Environ.mem_mind (fst ind) (Global.env ()) ->
    let mib, oib = Global.lookup_inductive ind in
    mib.mind_nparams = 0
    && oib.mind_nrealargs = 0
    && Array.length oib.mind_consnames >= 2
    && Array.for_all oib.mind_consnrealargs ~f:(fun n -> n = 0)
    && ((not (Table.is_custom r)) || literals r (constructors r))
  | Tglob _ | Tarr _ | Tvar _ | Tvar' _ | Tmeta _ | Tdummy _ | Tunknown | Taxiom -> false
;;

let bound_global = function
  | Tglob (r, _) -> r
  | Tarr _ | Tvar _ | Tvar' _ | Tmeta _ | Tdummy _ | Tunknown | Taxiom ->
    CErrors.anomaly (Pp.str "Ts_kernel: a bound is an inductive.")
;;

let term_type ctx k bound =
  match E.kind ctx.sigma (Reductionops.whd_all ctx.env ctx.sigma k) with
  | Rel n ->
    Option.map
      (List.Assoc.find ctx.lifted ~equal:Int.equal (level ctx n))
      ~f:(fun l -> T.Var l.var)
  | Construct ((ind, j), _) -> Some (T.Glob (ctor (bound_global bound) ind j, []))
  | _ -> None
;;

let bounds al = List.filter_map al.schema.tparams ~f:(fun (p : T.tparam) -> p.bound)
let kernel_type env gr = E.of_constr (fst (Typeops.type_of_global_in_context env gr))

let definition env (r : global) =
  match r.glob with
  | GlobRef.ConstRef kn ->
    (match (Environ.lookup_constant kn env).const_body with
     | Declarations.Def b -> Some (E.of_constr b)
     | Declarations.Undef _
     | Declarations.OpaqueDef _
     | Declarations.Primitive _
     | Declarations.Symbol _ -> None)
  | GlobRef.VarRef _ | GlobRef.IndRef _ | GlobRef.ConstructRef _ -> None
;;

let no_form ctx k (r : global) fields =
  CErrors.user_err
    Pp.(
      str "TypeScript extraction cannot type "
      ++ (match ctx.owner with
        | Some o -> Printer.pr_global o.glob
        | None -> str "a declaration")
      ++ str ": its result, of type "
      ++ Printer.pr_leconstr_env ctx.env ctx.sigma k
      ++ str ", is a "
      ++ Printer.pr_global r.glob
      ++ str " whose "
      ++ prlist_with_sep (fun () -> str " and ") (fun f -> Id.print f.fname) fields
      ++ str
           " may depend on its arguments, and TypeScript has no type for it without \
            unknown.")
;;

let recursive_head ctx head =
  Option.filter ctx.recursion ~f:(fun recursion ->
    E.eq_constr ctx.sigma head (E.Vars.lift (depth ctx - recursion.depth) recursion.head))
;;

let inductive_args ctx k (r : global) args =
  let head, kargs =
    E.decompose_app_list ctx.sigma (Reductionops.whd_all ctx.env ctx.sigma k)
  in
  match E.kind ctx.sigma head with
  | Ind (ind, _)
    when GlobRef.CanOrd.equal (GlobRef.IndRef ind) r.glob
         && List.length kargs = List.length args -> Some (ind, kargs)
  | _ -> None
;;

let rec copy ctx = function
  | Tglob (f, args) ->
    let args = List.map args ~f:(copy ctx) in
    (match ctx.alias f, ctx.fields_of f with
     | Some (al : alias), _ when List.length args = al.vars -> T.Glob (f, args @ bounds al)
     | _, (_ :: _ as fields) -> T.Glob (f, args @ List.map fields ~f:(fun _ -> T.lost ()))
     | _, [] -> T.Glob (f, args))
  | Tarr (a, b) -> T.Arrow (copy ctx a, copy ctx b)
  | Tmeta { contents = Some t; _ } -> copy ctx t
  | (Tmeta _ | Tvar _ | Tvar' _ | Tdummy _ | Tunknown | Taxiom) as t -> T.of_ml t

and refine ctx k ml =
  if not (lossy ~opaque:ctx.opaque ml)
  then T.of_ml ml
  else (
    match ml with
    | Tglob (f, []) when Option.is_some (projected ctx f) ->
      (match binder_field ctx k with
       | Some t -> t
       | None -> closed ctx k ml)
    | Tglob (f, _)
      when ctx.is_function f
           && Option.is_none ctx.owner
           && not (equal_approximation ctx.approximation Upper) -> refine ctx k Tunknown
    | Tglob (f, vl) when ctx.is_function f ->
      let head, kargs = E.decompose_app_list ctx.sigma k in
      (match ctx.alias f, E.kind ctx.sigma head with
       | Some (al : alias), Const (kn, _)
         when GlobRef.CanOrd.equal (GlobRef.ConstRef kn) f.glob
              && List.length al.parameters = List.length vl ->
         let bounds =
           List.drop al.schema.tparams al.vars
           |> List.map ~f:(fun (p : T.tparam) ->
             match p.bound with
             | Some (T.Glob (r, [])) -> Tglob (r, [])
             | Some _ | None ->
               CErrors.anomaly (Pp.str "Ts_kernel: a lifted parameter has a bound."))
         in
         T.Glob
           ( f
           , List.map2_exn al.parameters vl ~f:(fun pos ml ->
               match List.nth kargs pos with
               | Some arg -> refine { ctx with approximation = Exact } arg ml
               | None -> copy ctx ml)
             @ List.map2_exn al.positions bounds ~f:(fun pos bound ->
               match
                 Option.bind (List.nth kargs pos) ~f:(fun k -> term_type ctx k bound)
               with
               | Some t -> t
               | None ->
                 (match ctx.approximation with
                  | Upper -> T.of_ml bound
                  | Lower | Exact -> T.lost ())) )
       | _ -> copy ctx ml)
    | Tunknown ->
      let k = Reductionops.whd_all ctx.env ctx.sigma k in
      let read ctx k = refine ctx k (Option.value (extract ctx k) ~default:Tunknown) in
      let node = E.kind ctx.sigma k in
      let recursion =
        match node with
        | App (head, _) -> recursive_head ctx head
        | _ -> None
      in
      (match node, recursion with
       | Rel n, _ when List.Assoc.mem ctx.quantified ~equal:Int.equal (level ctx n) ->
         T.Var (List.Assoc.find_exn ctx.quantified ~equal:Int.equal (level ctx n))
       | Rel n, _
         when equal_approximation ctx.approximation Lower
              && List.mem ctx.existentials (level ctx n) ~equal:Int.equal -> T.Never
       | App (_, args), Some recursion ->
         if
           equal_approximation ctx.approximation Upper
           && Array.length args = List.length recursion.args
           && List.for_alli recursion.args ~f:(fun i arg ->
             i = recursion.decreasing
             || E.eq_constr
                  ctx.sigma
                  args.(i)
                  (E.Vars.lift (depth ctx - recursion.depth) arg))
         then recursion.self
         else T.lost ()
       | Prod (x, ka, kb), _ when equal_kind (kind ctx.env ctx.sigma ka) Info ->
         let inner = push ctx (D.LocalAssum (x, ka)) in
         T.Arrow
           (read { ctx with approximation = reverse ctx.approximation } ka, read inner kb)
       | Case (ci, u, pms, p, iv, scrut, brs), _ ->
         let _, _, _, _, _, _, branches =
           E.annotate_case ctx.env ctx.sigma (ci, u, pms, p, iv, scrut, brs)
         in
         let arms =
           Array.to_list
             (Array.mapi branches ~f:(fun j (binders, br) ->
                let inner =
                  List.fold_right
                    binders
                    ~f:(fun d c ->
                      let existentials =
                        match d with
                        | D.LocalAssum (_, ty)
                          when equal_kind (kind c.env c.sigma ty) Type ->
                          depth c :: c.existentials
                        | D.LocalAssum _ | D.LocalDef _ -> c.existentials
                      in
                      push { c with existentials } d)
                    ~init:ctx
                in
                j + 1, List.is_empty binders, read inner br))
         in
         (match binder_entry ctx ctx.lifted scrut with
          | Some l when List.for_all arms ~f:(fun (_, closed, _) -> closed) ->
            let r = bound_global l.bound in
            T.Cond
              { on = T.Var l.var
              ; arms = List.map arms ~f:(fun (j, _, t) -> ctor r ci.ci_ind j, t)
              }
          | Some _ | None ->
            let types = List.map arms ~f:(fun (_, _, t) -> t) in
            (match ctx.approximation, types with
             | Upper, _ -> T.union types
             | (Lower | Exact), t :: rest when List.for_all rest ~f:(T.equal t) -> t
             | (Lower | Exact), _ -> T.lost ()))
       | _ -> Option.value_or_thunk (lossless ctx k) ~default:T.lost)
    | Tarr (a, b) ->
      (match E.kind ctx.sigma (Reductionops.whd_all ctx.env ctx.sigma k) with
       | Prod (x, ka, kb) ->
         let inner = push ctx (D.LocalAssum (x, ka)) in
         (match a, kind ctx.env ctx.sigma ka with
          | Tdummy _, Type ->
            let v = T.fresh () in
            (match
               refine { inner with quantified = (depth ctx, v) :: ctx.quantified } kb b
             with
             | T.Forall (vs, t) -> T.Forall (v :: vs, t)
             | T.Arrow _ as t -> T.Forall ([ v ], t)
             | _ -> copy ctx ml)
          | _ ->
            T.Arrow
              ( refine { ctx with approximation = reverse ctx.approximation } ka a
              , refine inner kb b ))
       | _ -> copy ctx ml)
    | Tglob (r, args) when not (List.is_empty (ctx.fields_of r)) ->
      let ml_args =
        match inductive_args ctx k r args with
        | Some (_, kargs) ->
          List.map2_exn kargs args ~f:(refine { ctx with approximation = Exact })
        | None -> List.map args ~f:(copy ctx)
      in
      T.Glob (r, ml_args @ record_args ctx r k)
    | Tglob (r, args) ->
      (* An inductive's arguments in MiniML are its kernel arguments when
         every parameter is a type, as for prod and list. *)
      (match inductive_args ctx k r args with
       | Some (_, kargs) ->
         T.Glob
           (r, List.map2_exn kargs args ~f:(refine { ctx with approximation = Exact }))
       | None -> copy ctx ml)
    | Tvar _ | Tvar' _ | Tmeta _ | Tdummy _ | Taxiom -> copy ctx ml)

and projected ctx (f : global) =
  match f.glob with
  | GlobRef.ConstRef kn -> ctx.projection kn
  | GlobRef.VarRef _ | GlobRef.IndRef _ | GlobRef.ConstructRef _ -> None

and binder_field ctx k =
  let head, kargs = E.decompose_app_list ctx.sigma k in
  match E.kind ctx.sigma head, List.rev kargs with
  | Const (kn, _), arg :: _ ->
    (match
       ( ctx.projection kn
       , binder_entry ctx ctx.records (Reductionops.whd_all ctx.env ctx.sigma arg) )
     with
     | Some (_, idx), Some vars -> Some (T.Var (List.nth_exn vars idx))
     | _ -> None)
  | _ -> None

and closed ctx k ml =
  Option.value_or_thunk
    (lossless ctx (Reductionops.whd_all ctx.env ctx.sigma k))
    ~default:(fun () -> copy ctx ml)

and record_args ctx r k =
  let fields = ctx.fields_of r in
  match ctx.fresh, ctx.constant with
  | Some fresh, _ ->
    List.map fields ~f:(fun f ->
      fresh.next <- fresh.next + 1;
      fresh.named <- (fresh.next, f.fname) :: fresh.named;
      T.Var fresh.next)
  | None, Some c -> carriers ctx c r fields
  | None, None -> no_form ctx k r fields

and value_type ctx k r ind args v =
  let fields = ctx.fields_of r in
  let v = Reductionops.whd_all ctx.env ctx.sigma v in
  match E.kind ctx.sigma v with
  | Rel n when List.Assoc.mem ctx.records ~equal:Int.equal (level ctx n) ->
    T.Glob
      ( r
      , args
        @ List.map
            (List.Assoc.find_exn ctx.records ~equal:Int.equal (level ctx n))
            ~f:(fun i -> T.Var i) )
  | App (c, cargs) when E.isConstruct ctx.sigma c ->
    let nparams = (fst (Inductive.lookup_mind_specif ctx.base ind)).mind_nparams in
    let field f =
      let t = cargs.(nparams + f.pos) in
      match binder_field ctx t with
      | Some t -> t
      | None ->
        Option.value_or_thunk
          (lossless ctx (Reductionops.whd_all ctx.env ctx.sigma t))
          ~default:(fun () -> no_form ctx k r fields)
    in
    T.Glob (r, args @ List.map fields ~f:field)
  | Case (ci, _, _, _, _, scrut, brs) ->
    (match binder_entry ctx ctx.lifted (Reductionops.whd_all ctx.env ctx.sigma scrut) with
     | Some l when Array.for_all brs ~f:(fun (nas, _) -> Array.length nas = 0) ->
       T.Cond
         { on = T.Var l.var
         ; arms =
             Array.to_list
               (Array.mapi brs ~f:(fun j (_, br) ->
                  ( ctor (bound_global l.bound) ci.ci_ind (j + 1)
                  , value_type ctx k r ind args br )))
         }
     | Some _ | None -> no_form ctx k r fields)
  | _ -> no_form ctx k r fields

and carriers ctx c r fields =
  let ind =
    match r.glob with
    | GlobRef.IndRef ind -> ind
    | GlobRef.VarRef _ | GlobRef.ConstRef _ | GlobRef.ConstructRef _ ->
      CErrors.anomaly (Pp.str "Ts_kernel.carriers: a record is an inductive.")
  in
  let nparams = (fst (Inductive.lookup_mind_specif ctx.base ind)).mind_nparams in
  let body =
    Option.map (definition ctx.base c) ~f:(Reductionops.nf_all ctx.env ctx.sigma)
  in
  let rec values acc t =
    let acc =
      match E.kind ctx.sigma t with
      | App (f, args) ->
        (match E.kind ctx.sigma f with
         | Construct ((ind', 1), _) when Ind.CanOrd.equal ind ind' -> args :: acc
         | _ -> acc)
      | _ -> acc
    in
    E.fold ctx.sigma values acc t
  in
  let built = List.rev (Option.value_map body ~default:[] ~f:(values [])) in
  let pr = Printer.pr_leconstr_env ctx.env ctx.sigma in
  let ctype = kernel_type ctx.env c.glob in
  List.map fields ~f:(fun f ->
    let given =
      List.fold built ~init:[] ~f:(fun acc (args : E.t array) ->
        let v = args.(nparams + f.pos) in
        if List.exists acc ~f:(E.eq_constr ctx.sigma v) then acc else acc @ [ v ])
    in
    let fail why =
      CErrors.user_err
        Pp.(
          str "TypeScript extraction cannot type "
          ++ Printer.pr_global c.glob
          ++ str ", of type "
          ++ pr ctype
          ++ str ": "
          ++ why
          ++ str ", and TypeScript has no type for them without unknown.")
    in
    match given with
    | [ value ] ->
      (match lossless ctx value with
       | Some t -> t
       | None ->
         fail
           Pp.(
             str "its " ++ Id.print f.fname ++ str " " ++ pr value ++ str " has no type"))
    | [] ->
      fail
        Pp.(
          str "the "
          ++ Id.print f.fname
          ++ str " of its "
          ++ Printer.pr_global r.glob
          ++ str "s is not known before it runs")
    | vs ->
      fail
        Pp.(
          str "its "
          ++ Printer.pr_global r.glob
          ++ str "s have different "
          ++ Id.print f.fname
          ++ str "s ("
          ++ prlist_with_sep (fun () -> str ", ") pr vs
          ++ str ")"))
;;

let rec erase ~alias ~fields lifted = function
  | T.Cond { arms; _ } ->
    (match List.map arms ~f:(fun (_, t) -> erase ~alias ~fields lifted t) with
     | t :: ts when List.for_all ts ~f:(Mlutil.eq_ml_type t) -> t
     | _ -> Tunknown)
  | T.Var i ->
    (match List.find lifted ~f:(fun l -> l.var = i) with
     | Some l -> l.bound
     | None -> Tvar i)
  | T.Glob (r, args) ->
    let args =
      match alias r with
      | Some (al : alias) -> List.take args al.vars
      | None -> List.take args (List.length args - List.length (fields r))
    in
    Tglob (r, List.map args ~f:(erase ~alias ~fields lifted))
  | T.Arrow (a, b) -> Tarr (erase ~alias ~fields lifted a, erase ~alias ~fields lifted b)
  | T.Forall (vs, t) ->
    List.fold_right
      vs
      ~f:(fun _ t -> Tarr (Tdummy Ktype, t))
      ~init:(erase ~alias ~fields lifted t)
  | T.Erased | T.Never -> Tdummy Kprop
  | T.Meta _ | T.Tuple _ | T.Union _ -> Tunknown
;;

let rec aligned ~opaque ml t =
  let aligned = aligned ~opaque in
  match ml, t with
  | Tmeta { contents = Some ml; _ }, _ -> aligned ml t
  | Tunknown, _ | Taxiom, Tunknown -> true
  | Tglob (f, []), _ when opaque f -> true
  | Tarr (a, b), Tarr (a', b') -> aligned a a' && aligned b b'
  | Tglob (r, args), Tglob (r', args') ->
    GlobRef.CanOrd.equal r.glob r'.glob
    && List.length args = List.length args'
    && List.for_all2_exn args args' ~f:aligned
  | Tdummy _, Tdummy _ -> true
  | (Tvar i | Tvar' i), Tvar j -> i = j
  | (Taxiom | Tarr _ | Tglob _ | Tdummy _ | Tvar _ | Tvar' _ | Tmeta _), _ -> false
;;

let occurs sigma n t = not (E.Vars.noccurn sigma n t)

let rec mentions i = function
  | T.Var j -> i = j
  | T.Glob (_, ts) | T.Tuple ts | T.Union ts -> List.exists ts ~f:(mentions i)
  | T.Arrow (a, b) -> mentions i a || mentions i b
  | T.Cond { on; arms } ->
    mentions i on || List.exists arms ~f:(fun (_, t) -> mentions i t)
  | T.Forall (_, t) -> mentions i t
  | T.Meta _ | T.Erased | T.Never -> false
;;

let name d =
  match Context.binder_name (D.get_annot d) with
  | Name id -> id
  | Anonymous -> Id.of_string "b"
;;

type param =
  | Kept_erased of ml_type
  | Informative of ctx * E.rel_declaration * ml_type

let record_type ctx k ml =
  match ml with
  | Tglob (r, args) when not (List.is_empty (ctx.fields_of r)) ->
    Option.map (inductive_args ctx k r args) ~f:(fun (ind, kargs) -> r, ind, kargs, args)
  | Tglob _ | Tarr _ | Tvar _ | Tvar' _ | Tmeta _ | Tdummy _ | Tunknown | Taxiom -> None
;;

let rec matches ctx v lvl =
  match E.kind ctx.sigma (Reductionops.whd_all ctx.env ctx.sigma v) with
  | Case (_, _, _, _, _, scrut, brs) ->
    (match E.kind ctx.sigma (Reductionops.whd_all ctx.env ctx.sigma scrut) with
     | Rel n -> level ctx n = lvl
     | _ -> false)
    || Array.exists brs ~f:(fun (nas, br) -> Array.length nas = 0 && matches ctx br lvl)
  | _ -> false
;;

let signature ?(keep_result = false) ?body ~start (r : global) ~kty ~nb t =
  let start = { start with vars = nb; owner = Some r } in
  let sigma = start.sigma in
  let binders, result = E.decompose_prod_decls sigma kty in
  let rec walk ctx ml acc = function
    | [] -> Some (List.rev acc, ml, ctx)
    | d :: rest ->
      (match kind ctx.env sigma (D.get_type d), ml with
       | (Type | Logical), Tarr ((Tdummy _ as dom), ml') ->
         walk (push ctx d) ml' (Kept_erased dom :: acc) rest
       | (Type | Logical), _ -> walk (push ctx d) ml acc rest
       | Info, Tarr (dom, ml') ->
         walk (push ctx d) ml' (Informative (ctx, d, dom) :: acc) rest
       | Info, _ -> None)
  in
  let open Option.Let_syntax in
  let%map params, ml_result, last = walk start t [] (List.rev binders) in
  let infos =
    List.filter_map params ~f:(function
      | Informative (c, d, dom) -> Some (c, d, dom)
      | Kept_erased _ -> None)
  in
  let returned =
    match body with
    | Some b when not (List.is_empty infos) ->
      let own = List.take last.rels (depth last - depth start) in
      Option.map (record_type last result ml_result) ~f:(fun record ->
        record, E.mkApp (b, Context.Rel.instance E.mkRel 0 own))
    | Some _ | None -> None
  in
  let later lvl =
    List.exists infos ~f:(fun (c, d, dom) ->
      depth c > lvl
      && lossy ~opaque:start.opaque dom
      && occurs sigma (depth c - lvl) (D.get_type d))
    || (lossy ~opaque:start.opaque ml_result && occurs sigma (depth last - lvl) result)
    || Option.exists returned ~f:(fun (_, v) -> matches last v lvl)
  in
  let candidates =
    List.filter_map infos ~f:(fun (c, d, dom) ->
      Option.some_if (enumeration dom && later (depth c)) (depth c, d, dom))
  in
  let translate chosen =
    let lifted =
      List.mapi chosen ~f:(fun k (lvl, _, dom) -> lvl, { var = nb + k + 1; bound = dom })
    in
    let fresh = { next = nb + List.length lifted; named = [] } in
    let records = ref [] in
    let param = function
      | Kept_erased dom -> T.of_ml dom
      | Informative (c, d, dom) ->
        (match List.Assoc.find lifted ~equal:Int.equal (depth c) with
         | Some l -> T.Var l.var
         | None ->
           let before = fresh.next in
           let t =
             refine
               { c with lifted; records = !records; fresh = Some fresh }
               (D.get_type d)
               dom
           in
           (match E.kind sigma (Reductionops.whd_all c.env sigma (D.get_type d)) with
            | Ind _ when fresh.next > before ->
              records
              := (depth c, List.init (fresh.next - before) ~f:(fun i -> before + i + 1))
                 :: !records
            | _ -> ());
           t)
    in
    let ps = List.map params ~f:param in
    let res =
      if keep_result
      then T.of_ml ml_result
      else (
        let ctx =
          { last with
            lifted
          ; records = !records
          ; fresh = None
          ; constant = Option.some_if (List.is_empty infos) r
          }
        in
        match returned with
        | Some ((rr, ind, kargs, args), v) ->
          value_type
            ctx
            result
            rr
            ind
            (List.map2_exn kargs args ~f:(refine { ctx with approximation = Exact }))
            v
        | None -> refine ctx result ml_result)
    in
    lifted, ps, res, List.rev fresh.named
  in
  let lifted, ps, res, named = translate candidates in
  let used lvl =
    let own = List.Assoc.find_exn lifted ~equal:Int.equal lvl in
    mentions own.var res
    || List.exists2_exn params ps ~f:(fun p ty ->
      (match p with
       | Informative (c, _, _) -> depth c <> lvl
       | Kept_erased _ -> true)
      && mentions own.var ty)
  in
  let chosen = List.filter candidates ~f:(fun (lvl, _, _) -> used lvl) in
  let lifted, ps, res, named =
    if List.length chosen = List.length candidates
    then lifted, ps, res, named
    else translate chosen
  in
  let ty = T.curried ps res in
  let lifted_params = List.map lifted ~f:snd in
  if
    not
      (aligned
         ~opaque:start.opaque
         t
         (erase ~alias:start.alias ~fields:start.fields_of lifted_params ty))
  then
    CErrors.anomaly
      Pp.(
        str "Ts_kernel.signature: the signature of "
        ++ Printer.pr_global r.glob
        ++ str " does not erase to its MiniML type.");
  { T.tparams =
      List.init nb ~f:(fun _ -> { T.hint = None; bound = None })
      @ List.map2_exn chosen lifted_params ~f:(fun (_, d, _) l ->
        { T.hint = Some (name d); bound = Some (T.of_ml l.bound) })
      @ List.map named ~f:(fun (_, id) -> { T.hint = Some id; bound = None })
  ; ty
  }
;;

let schema ~start (r : global) t =
  let kty = kernel_type start.env r.glob in
  signature ?body:(definition start.base r) ~start r ~kty ~nb:(Mlutil.type_maxvar t) t
;;

let constructor ~start (p : ml_ind_packet) j =
  let c = p.ip_consnames_ref.(j) in
  match c.glob with
  | GlobRef.ConstructRef ((mind, _), _) ->
    let mib = Environ.lookup_mind mind start.env in
    let kty = kernel_type start.env c.glob in
    let binders, result = E.decompose_prod_decls start.sigma kty in
    let params, args = List.split_n (List.rev binders) mib.mind_nparams in
    let ctx = List.fold params ~init:start ~f:push in
    let nvars = List.length p.ip_vars in
    let nb = nvars + List.length (start.fields_of p.ip_typename_ref) in
    let ml =
      Mlutil.type_recomp
        ( p.ip_types.(j)
        , Tglob (p.ip_typename_ref, List.init nvars ~f:(fun i -> Tvar (i + 1))) )
    in
    Option.map
      (signature
         ~keep_result:true
         ~start:ctx
         c
         ~kty:(E.it_mkProd_or_LetIn result (List.rev args))
         ~nb
         ml)
      ~f:(fun (s : T.schema) ->
        { lifted = List.drop s.tparams nb
        ; args = fst (T.split (List.length p.ip_types.(j)) s.ty)
        })
  | GlobRef.VarRef _ | GlobRef.ConstRef _ | GlobRef.IndRef _ -> None
;;

let alias ~start ~vars (r : global) kn body =
  let start = { start with vars } in
  let sigma = start.sigma in
  let fixpoint, body =
    match E.kind sigma body with
    | Fix ((_, i), (_, _, bodies)) when Array.length bodies = 1 ->
      true, E.Vars.subst1 (E.mkConstU (kn, E.EInstance.empty)) bodies.(i)
    | _ -> false, body
  in
  let binders, def =
    if fixpoint
    then E.decompose_lambda_decls sigma body
    else (
      let ty = kernel_type start.env r.glob in
      let binders, _ = E.decompose_prod_decls sigma ty in
      ( binders
      , E.mkApp
          (E.Vars.lift (List.length binders) body, Context.Rel.instance E.mkRel 0 binders)
      ))
  in
  let rec walk ctx pos acc parameters = function
    | [] -> ctx, List.rev acc, List.rev parameters
    | (D.LocalDef _ as d) :: rest -> walk (push ctx d) pos acc parameters rest
    | d :: rest ->
      let sort = kind ctx.env sigma (D.get_type d) in
      let candidate =
        match sort with
        | Info ->
          (match extract ctx (D.get_type d) with
           | Some dom when enumeration dom -> Some (depth ctx, pos, d, dom)
           | Some _ | None -> None)
        | Type | Logical -> None
      in
      walk
        (push ctx d)
        (pos + 1)
        (Option.value_map candidate ~default:acc ~f:(fun c -> c :: acc))
        (match sort with
         | Type -> pos :: parameters
         | Info | Logical -> parameters)
        rest
  in
  let last, candidates, parameters = walk start 0 [] [] (List.rev binders) in
  let translate chosen =
    let lifted =
      List.mapi chosen ~f:(fun k (lvl, _, _, dom) ->
        lvl, { var = vars + k + 1; bound = dom })
    in
    let ctx = { last with lifted } in
    let reduced = Reductionops.whd_all ctx.env sigma def in
    let head, args = E.decompose_app_list sigma reduced in
    let d =
      match E.kind sigma head with
      | Fix ((decreasing, i), (_, tys, bodies))
        when List.is_empty chosen && Array.length bodies = 1 ->
        let binders, _ = E.decompose_prod_decls sigma tys.(i) in
        let _, first_order =
          List.fold (List.rev binders) ~init:(ctx, true) ~f:(fun (c, valid) d ->
            ( push c d
            , valid
              &&
              match d with
              | D.LocalAssum (_, ty) -> not (equal_kind (kind c.env sigma ty) Type)
              | D.LocalDef _ -> true ))
        in
        let arity = List.count binders ~f:D.is_local_assum in
        if first_order && List.length args = arity
        then (
          let self = T.Glob (r, List.init vars ~f:(fun i -> T.Var (i + 1))) in
          let ctx =
            { ctx with
              recursion =
                Some { head; args; decreasing = decreasing.(i); depth = depth ctx; self }
            }
          in
          let body = Reductionops.contract_fix sigma (E.destFix sigma head) in
          refine ctx (E.mkApp (body, Array.of_list args)) Tunknown)
        else refine ctx def Tunknown
      | _ -> refine ctx def Tunknown
    in
    lifted, d
  in
  let lifted, d = translate candidates in
  let chosen =
    List.filter candidates ~f:(fun (lvl, _, _, _) ->
      mentions (List.Assoc.find_exn lifted ~equal:Int.equal lvl).var d)
  in
  let lifted, d =
    if List.length chosen = List.length candidates then lifted, d else translate chosen
  in
  let recursive = function
    | T.Glob (g, _) -> GlobRef.CanOrd.equal g.glob r.glob
    | _ -> false
  in
  let d =
    match d with
    | T.Union ts -> T.union (List.filter ts ~f:(fun t -> not (recursive t)))
    | d -> d
  in
  if
    recursive d
    || T.equal d T.Never
    || (not (List.is_empty (T.metas [ d ])))
    || List.exists (T.vars [ d ]) ~f:(fun i -> i < 1 || i > vars + List.length lifted)
  then None
  else
    Some
      { vars
      ; parameters
      ; positions = List.map chosen ~f:(fun (_, pos, _, _) -> pos)
      ; schema =
          { T.tparams =
              List.init vars ~f:(fun _ -> { T.hint = None; bound = None })
              @ List.map2_exn chosen lifted ~f:(fun (_, _, d, _) (_, l) ->
                { T.hint = Some (name d); bound = Some (T.of_ml l.bound) })
          ; ty = d
          }
      }
;;

(* A module's fields are added to the environment of its body, after a
   functor's parameters, as [Extract_env.extract_msignature] adds them, so
   that a member of a functor body and a specification of a module type
   have kernel types. *)
let structure struc =
  let decls = ref [] in
  let scopes = ref [] in
  let scope mp env =
    scopes := (mp, env) :: !scopes;
    env
  in
  let rec fields env mp sel =
    List.iter sel ~f:(fun (l, se) ->
      let at = ModPath.MPdot (mp, l) in
      match se with
      | SEdecl d -> decls := (env, d) :: !decls
      | SEmodule { ml_mod_expr; _ } ->
        (match Environ.lookup_module at env with
         | mb ->
           let reso = Mod_declarations.mod_delta mb in
           let sign = Mod_declarations.mod_type mb in
           (match Mod_declarations.mod_expr mb with
            | Mod_declarations.FullStruct -> body env reso sign ml_mod_expr
            | Mod_declarations.Struct (reso, struc) ->
              body env reso (Modops.annotate_struct_body struc sign) ml_mod_expr
            | Mod_declarations.Algebraic _ | Mod_declarations.Abstract -> ())
         | exception Stdlib.Not_found -> ())
      | SEmodtype _ ->
        (match Environ.lookup_modtype at env with
         | mtb ->
           specs env at (Mod_declarations.mod_delta mtb) (Mod_declarations.mod_type mtb)
         | exception Stdlib.Not_found -> ()))
  and parameter env mbid mtb =
    scope
      (ModPath.MPbound mbid)
      (Environ.Internal.overwrite_module_parameter mbid mtb env)
  and body env reso sign me =
    match sign, me with
    | Declarations.MoreFunctor (mbid, mtb, sign), MEfunctor (_, _, me) ->
      body (parameter env mbid mtb) reso sign me
    | Declarations.NoFunctor struc, MEstruct (mp, sel) ->
      fields (scope mp (Environ.Internal.overwrite_structure mp struc reso env)) mp sel
    | Declarations.MoreFunctor _, (MEident _ | MEstruct _ | MEapply _)
    | Declarations.NoFunctor _, (MEident _ | MEfunctor _ | MEapply _) -> ()
  and specs env at reso = function
    | Declarations.MoreFunctor (mbid, mtb, sign) ->
      specs (parameter env mbid mtb) at reso sign
    | Declarations.NoFunctor struc ->
      ignore
        (scope at (Environ.Internal.overwrite_structure at struc reso env) : Environ.env)
  in
  List.iter struc ~f:(fun (mp, sel) -> fields (Global.env ()) mp sel);
  List.rev !decls, !scopes
;;

let in_env env (r : global) =
  match r.glob with
  | GlobRef.ConstRef kn -> Environ.mem_constant kn env
  | GlobRef.IndRef (mind, _) | GlobRef.ConstructRef ((mind, _), _) ->
    Environ.mem_mind mind env
  | GlobRef.VarRef _ -> false
;;

let create state struc =
  let decls, scopes = structure struc in
  let functions =
    List.fold decls ~init:Refmap.empty ~f:(fun m -> function
      | env, Dtype (r, vl, Tunknown) when (not (Table.is_custom r)) && in_env env r ->
        Refmap.add r (List.length vl, env) m
      | _, (Dtype _ | Dterm _ | Dfix _ | Dind _) -> m)
  in
  let records =
    List.fold decls ~init:Refmap.empty ~f:(fun m -> function
      | env, Dind { ind_kind = Record _; ind_packets = [| p |]; _ }
        when (not p.ip_logical) && in_env env p.ip_typename_ref ->
        let sigma = Evd.from_env env in
        (match p.ip_typename_ref.glob with
         | GlobRef.IndRef ind ->
           let mib = Environ.lookup_mind (fst ind) env in
           let kty = kernel_type env (GlobRef.ConstructRef (ind, 1)) in
           let binders, _ = E.decompose_prod_decls sigma kty in
           let params, args = List.split_n (List.rev binders) mib.mind_nparams in
           let projs =
             match Structures.Structure.find_projections env ind with
             | projs -> projs
             | exception Stdlib.Not_found -> []
           in
           let env' = List.fold params ~init:env ~f:(fun env d -> E.push_rel d env) in
           let _, _, fields =
             List.fold args ~init:(env', 0, []) ~f:(fun (env, pos, acc) d ->
               let acc =
                 match kind env sigma (D.get_type d), List.nth projs pos with
                 | Type, Some (Some proj) ->
                   acc @ [ { proj; pos; fname = Constant.label proj } ]
                 | _ -> acc
               in
               E.push_rel d env, pos + 1, acc)
           in
           if List.is_empty fields then m else Refmap.add p.ip_typename_ref fields m
         | GlobRef.VarRef _ | GlobRef.ConstRef _ | GlobRef.ConstructRef _ -> m)
      | _, (Dind _ | Dtype _ | Dterm _ | Dfix _) -> m)
  in
  let fields_of r = Option.value (Refmap.find_opt r records) ~default:[] in
  let projections =
    Refmap.fold
      (fun r fields acc -> List.mapi fields ~f:(fun i f -> f.proj, (r, i)) @ acc)
      records
      []
  in
  let projection kn = List.Assoc.find projections ~equal:Constant.CanOrd.equal kn in
  let is_function r = Refmap.mem r functions in
  let opaque r = is_function r || Refmap.mem r records in
  let memo = Hashtbl.Poly.create ~size:8 () in
  let rec find (r : global) : alias option =
    match Hashtbl.find memo r.glob with
    | Some a -> a
    | None ->
      Hashtbl.set memo ~key:r.glob ~data:None;
      let a =
        match Refmap.find_opt r functions, r.glob with
        | Some (vars, env), GlobRef.ConstRef kn ->
          Option.bind (definition env r) ~f:(fun body ->
            alias ~start:(start env) ~vars r kn body)
        | Some _, _ | None, _ -> None
      in
      Hashtbl.set memo ~key:r.glob ~data:a;
      a
  and start env : ctx =
    { state
    ; base = env
    ; env
    ; sigma = Evd.from_env env
    ; rels = []
    ; lifted = []
    ; quantified = []
    ; vars = 0
    ; opaque
    ; is_function
    ; alias = find
    ; fields_of
    ; projection
    ; records = []
    ; fresh = None
    ; constant = None
    ; owner = None
    ; recursion = None
    ; approximation = Upper
    ; existentials = []
    }
  in
  let aliases =
    Refmap.fold
      (fun r _ m ->
         match find r with
         | Some a -> Refmap.add r a m
         | None -> m)
      functions
      Refmap.empty
  in
  let read env (r, t) =
    if (not (Table.is_custom r)) && lossy ~opaque t && in_env env r
    then schema ~start:(start env) r t
    else None
  in
  let add env m (r, t) =
    match read env (r, t) with
    | Some s -> Refmap.add r s m
    | None -> m
  in
  let terms =
    List.fold decls ~init:Refmap.empty ~f:(fun m -> function
      | env, Dterm (r, _, t) -> add env m (r, t)
      | env, Dfix (rv, _, tv) ->
        Array.fold2_exn rv tv ~init:m ~f:(fun m r t -> add env m (r, t))
      | _, (Dtype _ | Dind _) -> m)
  in
  let ctors =
    List.fold decls ~init:Refmap.empty ~f:(fun m -> function
      | env, Dind ind ->
        Array.fold ind.ind_packets ~init:m ~f:(fun m (p : ml_ind_packet) ->
          if
            p.ip_logical
            || Table.is_custom p.ip_typename_ref
            || not (in_env env p.ip_typename_ref)
          then m
          else
            Array.foldi p.ip_types ~init:m ~f:(fun j m args ->
              if List.exists args ~f:(lossy ~opaque)
              then (
                match constructor ~start:(start env) p j with
                | Some c -> Refmap.add p.ip_consnames_ref.(j) c m
                | None -> m)
              else m))
      | _, (Dtype _ | Dterm _ | Dfix _) -> m)
  in
  let rec scope_of mp =
    match List.Assoc.find scopes ~equal:ModPath.equal mp, mp with
    | (Some _ as env), _ -> env
    | None, ModPath.MPdot (mp, _) -> scope_of mp
    | None, ModPath.MPfile _ -> Some (Global.env ())
    | None, ModPath.MPbound _ -> None
  in
  let member (r : global) t =
    Option.bind (scope_of (Table.modpath_of_r r)) ~f:(fun env -> read env (r, t))
  in
  { terms
  ; aliases
  ; ctors
  ; fields = Refmap.map (List.map ~f:(fun f -> f.fname)) records
  ; member
  ; scope = scope_of
  }
;;

let term kernel r = Refmap.find_opt r kernel.terms
let member kernel r t = kernel.member r t
let ctor kernel r = Refmap.find_opt r kernel.ctors
let scope kernel mp = kernel.scope mp

let fields kernel r =
  List.map
    (Option.value (Refmap.find_opt r kernel.fields) ~default:[])
    ~f:(fun id -> { T.hint = Some id; bound = None })
;;

let alias kernel r = Option.map (Refmap.find_opt r kernel.aliases) ~f:(fun a -> a.schema)
