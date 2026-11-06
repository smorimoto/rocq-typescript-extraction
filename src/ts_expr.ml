open Import
open Extraction_plugin
module P = Ts_print
module I = Ts_infer
module T = Ts_type

type var =
  { expr : P.expr
  ; arity : int
  ; ty : I.ty
  ; tparams : int list
  }

(* A function that refers to a global of [defining] stays, since a use
   before the declaration would fail no-use-before-define, and so does
   one whose type mentions one of the [params] type parameters of the
   declaration. *)
type lifting =
  { name : string
  ; defining : Table.Refset'.t
  ; params : int
  ; mutable decls : P.value list
  ; mutable taken : Ts_names.avoid
  }
[@@deriving fields ~direct_iterators:set_all_mutable_fields]

type block =
  { mutable declared : Ts_names.avoid
  ; mutable chosen : Ts_names.avoid
  ; outer : block option
  ; top : bool
  }
[@@deriving fields ~direct_iterators:set_all_mutable_fields]

type self =
  | Top of Miniml.global
  | Named of var

type kept =
  { param : string
  ; copy : string option
  ; param_ty : P.ty
  ; binder : Miniml.ml_ident
  }

type loop =
  { self : self
  ; arity : int
  ; kept : kept list
  ; locals : string list ref
  }

type scope =
  { env : Ts_env.t
  ; names : Ts_names.t
  ; tvars : Ts_names.tvars
  ; vars : var list
  ; avoid : Ts_names.avoid
  ; group : P.expr Table.Refmap'.t
  ; block : block
  ; lifting : lifting
  ; loop : loop option
  ; machine : machine option
  }

and machine =
  { members : Ts_anf.member list
  ; base : int
  ; registers : register list array
  ; locals : string list ref
  ; which : string option
  ; current : int option
  ; leave : P.stmt list
  ; chain : step list
  ; frames : frames
  ; fixed : string list
  ; bodies : (I.binder list * I.expr) array
  ; inline : bool
  ; owner : int
  ; uniform : bool
  }

and register =
  | Register of string
  | Parameter
  | Pushed of column
  | Dropped

and frames =
  { storage : scope
  ; returned : string
  ; depth : string
  ; kinds : string
  ; mutable columns : column list
  ; mutable sites : site list
  }

and column =
  { cty : P.ty
  ; array : string
  ; cursor : string
  }

and site =
  { key : I.expr
  ; kind : int
  ; site_owner : int
  ; site_callee : int
  ; slots : (int * column) list
  ; site_scope : scope
  ; site_binder : I.binder
  ; site_body : I.expr
  ; site_steps : step list
  }

and step =
  { let_binder : I.binder
  ; let_body : I.expr
  ; let_type : I.ty
  ; let_scope : scope
  }

type value =
  { before : P.stmt list
  ; rest : rest
  }

and rest =
  | Expr of P.expr * fork option
  | Jump of P.expr * P.expr list
  | Fork of fork * context
  | Leave of P.stmt list

and context =
  | Hole
  | Around of (P.expr -> P.expr)

and fork =
  { result : P.ty
  ; shape : shape
  }

and shape =
  | Cases of P.expr * (P.expr option * arm) list * P.expr option
  | Tests of (P.expr * arm) list * arm

and arm =
  { scope : scope
  ; value : value
  }

type sink =
  | Return
  | Assign of string
  | Loop of loop

type callee =
  { fn : P.expr
  ; tyargs : P.ty list
  ; tvars : int list
  ; arity : int
  ; schema : T.t
  ; fn_ty : T.t
  ; erased : bool list
  }

type argument =
  { atomic : bool
  ; erased : bool
  ; pins : bool
  }

let erased_value = function
  | I.Dummy | I.Apply (I.Dummy, _) -> true
  | I.Local _
  | I.Global _
  | I.Apply _
  | I.Lambda _
  | I.Let _
  | I.Construct _
  | I.Match _
  | I.Unpack _
  | I.Fix _
  | I.Fail _
  | I.Cast _
  | I.Uint _
  | I.Float _
  | I.String _
  | I.Parray _
  | I.Tuple _ -> false
;;

(* The type of a value built by a constructor of a type with two
   constructors or more is the constructor's interface, narrower than the
   type reconstruction gives it, and so is the type of a match, which is
   the union of its branches' types, and of a failure, which is never.
   TypeScript would infer the narrower type and reject another
   constructor at a second argument. Record literals and custom
   constructors can propagate that narrower type through their fields. *)
let rec pins scope = function
  | I.Dummy | I.Apply (I.Dummy, _) | I.Cast _ | I.Match _ | I.Unpack _ | I.Fail _ -> false
  (* An array literal pins a type variable to an array, not a tuple. *)
  | I.Tuple _ -> false
  | I.Construct (r, _, args) ->
    (match (Ts_env.ind scope.env (Ts_env.ctor scope.env r).ind).repr with
     | Ts_repr.Tagged cs | Ts_repr.Lazy cs -> Array.length cs = 1
     | Ts_repr.Record _ | Ts_repr.Custom _ -> List.for_all args ~f:(pins scope)
     | Ts_repr.Erased -> true)
  | I.Local _
  | I.Global _
  | I.Apply _
  | I.Lambda _
  | I.Let _
  | I.Fix _
  | I.Uint _
  | I.Float _
  | I.String _
  | I.Parray _ -> true
;;

(* TypeScript infers a type argument from the arguments whose parameter
   types name the type variable, so a call writes its type arguments only
   when some type variable of [tvars] occurs in the type of no parameter
   that an argument pins. *)
let inferable params ~tvars =
  let pinned = T.vars (List.filter_map params ~f:(fun (t, p) -> Option.some_if p t)) in
  List.for_all tvars ~f:(fun v -> List.mem pinned v ~equal:Int.equal)
;;

let block ?outer ?(top = false) avoid = { declared = avoid; chosen = avoid; outer; top }

let scope env names tvars ~name ~defining =
  let avoid = Ts_names.avoid names in
  { env
  ; names
  ; tvars
  ; vars = []
  ; avoid
  ; group = Table.Refmap'.empty
  ; block = block avoid
  ; lifting =
      { name
      ; defining =
          List.fold defining ~init:Table.Refset'.empty ~f:(fun s r ->
            Table.Refset'.add r s)
      ; params = List.length (Ts_names.tparams tvars)
      ; taken = avoid
      ; decls = []
      }
  ; loop = None
  ; machine = None
  }
;;

let in_group scope members =
  { scope with
    group =
      List.fold members ~init:scope.group ~f:(fun m (r, e) -> Table.Refmap'.add r e m)
  }
;;

let lifted scope = scope.lifting.decls
let enter scope = { scope with block = block ~outer:scope.block scope.avoid }
let nested scope = { (enter scope) with loop = None; machine = None }

let declare_with scope choose =
  let b = scope.block in
  let l = scope.lifting in
  let rec around b =
    match b.outer with
    | None -> b.declared
    | Some o -> Ts_names.merge b.declared (around o)
  in
  let avoid =
    Ts_names.merge
      scope.avoid
      (Ts_names.merge (Ts_names.lifted scope.names) (Ts_names.merge (around b) b.chosen))
  in
  let name = choose (if b.top then Ts_names.merge avoid l.taken else avoid) in
  l.taken <- Ts_names.add l.taken name;
  b.declared <- Ts_names.add b.declared name;
  let rec record b =
    b.chosen <- Ts_names.add b.chosen name;
    Option.iter b.outer ~f:record
  in
  record b;
  name, { scope with avoid = Ts_names.add scope.avoid name }
;;

let declare scope id = declare_with scope (fun avoid -> fst (Ts_names.fresh avoid id))

let lift_statements scope stmts =
  let l = scope.lifting in
  l.decls
  <- l.decls
     @ List.map stmts ~f:(function
       | P.Const (name, ty, value) ->
         Ts_names.lift scope.names name;
         { P.name; ty; value }
       | P.Bind _
       | P.Let _
       | P.Variable _
       | P.Assign _
       | P.Cell_write _
       | P.Eval _
       | P.Bump _
       | P.Return _
       | P.Break
       | P.Continue
       | P.Switch _
       | P.If _
       | P.Loop _
       | P.While _ ->
         CErrors.anomaly
           (Pp.str "Ts_expr.lift_statements: the top level declares constants only."))
;;

(* A constant whose type has type variables is an arrow of no parameter,
   since a const cannot bind type parameters. *)
let generic scope r =
  let term = Ts_env.term scope.env r in
  term.arity = 0 && (not (List.is_empty term.schema.tparams)) && not (Table.is_custom r)
;;

let global scope r =
  match Table.Refmap'.find_opt r scope.group with
  | Some e -> e
  | None -> Ts_names.value scope.names r
;;

let ty scope t = Ts_names.ty scope.names scope.tvars t
let erased = P.Code "undefined"

let bind scope (b : I.binder) ~arity ~tparams =
  let name, scope = declare scope b.id in
  ( name
  , { scope with vars = { expr = P.Var name; arity; ty = b.ty; tparams } :: scope.vars } )
;;

let value_var expr ty = { expr; arity = 0; ty; tparams = [] }

let binds scope bs =
  let scope, params =
    List.fold_map bs ~init:scope ~f:(fun sc (b : I.binder) ->
      if T.is_erased b.ty
      then { sc with vars = value_var erased b.ty :: sc.vars }, None
      else (
        let name, sc' = bind sc b ~arity:0 ~tparams:[] in
        sc', Some (name, ty sc b.ty)))
  in
  params, scope
;;

let var scope n = List.nth_exn scope.vars (n - 1)
let base name = Miniml.Id (Names.Id.of_string name)

let rec is_path = function
  | P.Var _ -> true
  | P.Field (e, _) | P.Index (e, _) -> is_path e
  | _ -> false
;;

let rec arrow_chain params ~result body =
  match params with
  | [] -> body
  | [ p ] -> P.Arrow ([], Option.to_list p, Some result, P.Expr body)
  | p :: rest ->
    P.Arrow ([], Option.to_list p, None, P.Expr (arrow_chain rest ~result body))
;;

let erased_positions arity t = List.map (fst (T.split arity t)) ~f:T.is_erased

let local_callee scope (v : var) tys =
  if v.arity > 0
  then (
    let tys =
      if List.is_empty tys then List.map v.tparams ~f:(fun i -> T.Var i) else tys
    in
    Some
      { fn = v.expr
      ; tyargs = List.map tys ~f:(ty scope)
      ; tvars = v.tparams
      ; arity = v.arity
      ; schema = v.ty
      ; fn_ty = T.instantiate v.tparams tys v.ty
      ; erased = erased_positions v.arity v.ty
      })
  else None
;;

let callee scope = function
  | I.Global (r, tys) ->
    let term = Ts_env.term scope.env r in
    if term.arity = 0
    then None
    else (
      let fn = global scope r in
      let tyargs =
        match fn with
        | P.Code _ -> []
        | _ -> List.map tys ~f:(ty scope)
      in
      let schema = term.schema.ty in
      Some
        { fn
        ; tyargs
        ; tvars =
            List.filter_mapi term.schema.tparams ~f:(fun i (p : T.tparam) ->
              if Option.is_none p.bound then Some (i + 1) else None)
        ; arity = term.arity
        ; schema
        ; fn_ty = T.subst tys schema
        ; erased = erased_positions term.arity schema
        })
  | I.Local (n, tys) -> local_callee scope (var scope n) tys
  | _ -> None
;;

let curried f args =
  List.fold args ~init:f ~f:(fun f ((a : argument), e) ->
    P.Call (f, [], if a.erased then [] else [ e ]))
;;

let dropped (c : callee) i = Option.value (List.nth c.erased i) ~default:false
let passed (c : callee) es = List.filteri es ~f:(fun i _ -> not (dropped c i))

let call scope c (args : argument list) =
  let k = c.arity in
  let m = List.length args in
  let dropped = dropped c in
  let params, result = T.split k c.fn_ty in
  let tyargs =
    let pinned i t =
      (not (dropped i))
      &&
      match List.nth args i with
      | Some (a : argument) -> a.pins
      | None -> not (T.is_erased t)
    in
    let positions =
      List.mapi
        (List.zip_exn (fst (T.split k c.schema)) params)
        ~f:(fun i (s, t) -> s, pinned i t)
    in
    if inferable positions ~tvars:c.tvars then [] else c.tyargs
  in
  let kept es = passed c es in
  if m >= k
  then
    fun es ->
      let uncurried, extra = List.split_n (List.zip_exn args es) k in
      curried (P.Call (c.fn, tyargs, List.map (kept uncurried) ~f:snd)) extra
  else (
    let missing = List.drop params m in
    let missing_params =
      List.folding_mapi missing ~init:(enter scope) ~f:(fun i sc t ->
        if dropped (m + i)
        then sc, (None, None)
        else if T.is_erased t
        then sc, (None, Some erased)
        else (
          let n, sc = declare sc (base "x") in
          sc, (Some (n, ty scope t), Some (P.Var n))))
    in
    fun es ->
      arrow_chain
        (List.map missing_params ~f:fst)
        ~result:(ty scope result)
        (P.Call (c.fn, tyargs, kept es @ List.filter_map missing_params ~f:snd)))
;;

let eta scope c =
  if c.arity = 1 && List.is_empty c.tyargs then c.fn else call scope c [] []
;;

let reference scope (v : var) tys =
  match local_callee scope v tys with
  | Some c -> eta scope c
  | None -> v.expr
;;

let number f =
  match Float.classify f with
  | Nan -> "NaN"
  | Infinite -> if Float.O.( > ) f 0. then "Infinity" else "-Infinity"
  | Zero when Float.ieee_negative f -> "-0"
  | Zero | Subnormal | Normal ->
    let exact p =
      let s = Printf.sprintf "%.*g" p f in
      Option.some_if (Float.O.( = ) (Float.of_string s) f) s
    in
    Option.value_or_thunk
      (List.find_map [ 15; 16 ] ~f:exact)
      ~default:(fun () -> Printf.sprintf "%.17g" f)
;;

let ctor_index scope r = (Ts_env.ctor scope.env r).index
let repr scope (m : I.match_) = (Ts_env.ind scope.env m.ind).repr

let refers ~local ~global =
  let rec go d = function
    | I.Local (n, _) -> n > d && local (n - d)
    | I.Global (r, _) -> global r
    | I.Fail _ | I.Dummy | I.Uint _ | I.Float _ | I.String _ -> false
    | I.Apply (f, args) -> go d f || List.exists args ~f:(fun (a : I.arg) -> go d a.expr)
    | I.Lambda (_, bs, _, body) -> go (d + List.length bs) body
    | I.Let (_, _, e1, e2, _) -> go d e1 || go (d + 1) e2
    | I.Construct (_, _, es) | I.Tuple es -> List.exists es ~f:(go d)
    | I.Match m ->
      go d m.scrutinee
      || List.exists m.branches ~f:(fun (br : I.branch) ->
        go (d + List.length br.binders) br.body)
    | I.Unpack u -> go d u.tuple || go (d + List.length u.binders) u.body
    | I.Fix (_, defs) ->
      Array.exists defs ~f:(fun (f : I.fixdef) -> go (d + Array.length defs) f.body)
    | I.Cast (e, _, _, _) -> go d e
    | I.Parray (es, x) -> List.exists es ~f:(go d) || go d x
  in
  go 0
;;

let occurs k = refers ~local:(Int.equal k) ~global:(fun _ -> false)

let rec types e =
  let binders bs = List.map bs ~f:(fun (b : I.binder) -> b.ty) in
  match e with
  | I.Local (_, tys) | I.Global (_, tys) -> tys
  | I.Apply (f, args) ->
    types f @ List.concat_map args ~f:(fun (a : I.arg) -> types a.expr)
  | I.Lambda (vs, bs, t, e) ->
    List.map
      (binders bs @ (t :: types e))
      ~f:(T.instantiate vs (List.map vs ~f:(fun _ -> T.Erased)))
  | I.Let (b, _, e1, e2, t) -> b.ty :: (types e1 @ types e2 @ [ t ])
  | I.Construct (_, tys, es) -> tys @ List.concat_map es ~f:types
  | I.Match m ->
    types m.scrutinee
    @ m.tyargs
    @ (m.result
       :: List.concat_map m.branches ~f:(fun (br : I.branch) ->
         binders br.binders @ types br.body))
  | I.Unpack u ->
    types u.tuple @ u.elements @ binders u.binders @ types u.body @ [ u.result ]
  | I.Fix (_, defs) ->
    List.concat_map (Array.to_list defs) ~f:(fun (d : I.fixdef) -> d.ty :: types d.body)
  | I.Cast (e, from, target, _) -> from :: target :: types e
  | I.Tuple es -> List.concat_map es ~f:types
  | I.Parray (es, x) -> List.concat_map (x :: es) ~f:types
  | I.Fail _ | I.Dummy | I.Uint _ | I.Float _ | I.String _ -> []
;;

(* Oxlint's consistent-function-scoping rejects a local function that
   captures nothing, as one that loops instead of calling itself may. *)
let lifts scope e =
  (match e with
   | I.Lambda _ | I.Fix _ -> true
   | I.Local _
   | I.Global _
   | I.Apply _
   | I.Let _
   | I.Construct _
   | I.Match _
   | I.Unpack _
   | I.Fail _
   | I.Dummy
   | I.Cast _
   | I.Uint _
   | I.Float _
   | I.String _
   | I.Parray _
   | I.Tuple _ -> false)
  && (not
        (refers
           ~local:(fun _ -> true)
           ~global:(fun r -> Table.Refset'.mem r scope.lifting.defining)
           e))
  && List.for_all (T.vars (types e)) ~f:(fun i -> i > scope.lifting.params)
;;

type source =
  | Argument of int
  | Scrutinee
  | Unbound

let source (br : I.branch) i =
  let n = List.length br.binders in
  match br.pattern with
  | I.Ctor (_, fields) ->
    (match I.position fields (n - i) with
     | Some k -> Argument k
     | None -> Unbound)
  | I.Default { binds_scrutinee = true } -> Scrutinee
  | I.Default { binds_scrutinee = false } -> Unbound
;;

let reads_variable (br : I.branch) =
  let n = List.length br.binders in
  List.existsi br.binders ~f:(fun i _ ->
    match source br i with
    | Unbound -> false
    | Argument _ | Scrutinee -> occurs (n - i) br.body)
;;

(* MiniML puts the default it factors identical branches into last, so
   [br] is the branch of a constructor of a type of several constructors,
   which the directive gives a test. *)
let inline_test scope (selectors : Ts_match.selector array) (br : I.branch) =
  match br.pattern with
  | I.Ctor (r, _) ->
    (match selectors.(ctor_index scope r).test with
     | Some test -> test
     | None -> CErrors.anomaly (Pp.str "Ts_expr.inline_test: a lone constructor is last."))
  | I.Default _ -> CErrors.anomaly (Pp.str "Ts_expr.inline_test: a default is last.")
;;

let inline_split (m : I.match_) =
  match List.rev m.branches with
  | last :: rev_tested -> List.rev rev_tested, last
  | [] -> CErrors.anomaly (Pp.str "Ts_expr.inline_split: a match has a branch.")
;;

let tests_scrutinee scope selectors (m : I.match_) =
  (not (List.exists m.branches ~f:reads_variable))
  &&
  match fst (inline_split m) with
  | [ br ] -> String.equal (inline_test scope selectors br) P.hole
  | [] | _ :: _ :: _ -> false
;;

(* A nested property path loses its narrowing inside a closure, even
   when its root is immutable. Bind the matched value before testing it
   so the branches and their closures share the narrowed constant. *)
let readable scope (m : I.match_) repr s =
  let captured_path =
    match s with
    | P.Var _ -> false
    | _ ->
      List.exists m.branches ~f:(fun (br : I.branch) ->
        Ts_anf.delays
          scope.env
          br.body
          ~arities:
            (List.map br.binders ~f:(fun _ -> 0)
             @ List.map scope.vars ~f:(fun v -> v.arity)))
  in
  let narrows_by_tag = List.length m.branches > 1 in
  match Ts_repr.forced repr s with
  | None when is_path s && not captured_path -> Some s
  | Some call_of_path when is_path s && (not narrows_by_tag) && not captured_path ->
    Some call_of_path
  | _ -> None
;;

let branch_scope scope repr s (br : I.branch) =
  let n = List.length br.binders in
  let pattern_var i (b : I.binder) =
    let expr =
      match br.pattern with
      | I.Ctor (r, fields) ->
        (match I.position fields (n - i) with
         | Some k -> Ts_repr.field repr ~index:(ctor_index scope r) s k
         | None -> erased)
      | I.Default { binds_scrutinee = true } -> s
      | I.Default { binds_scrutinee = false } -> erased
    in
    value_var expr b.ty
  in
  { scope with vars = List.rev_append (List.mapi br.binders ~f:pattern_var) scope.vars }
;;

let cell scope (m : I.match_) repr s =
  let t = ty scope (T.Glob (m.ind, m.tyargs)) in
  match Ts_repr.forced repr s with
  | Some cell -> cell, P.Name ("ReturnType", [ t ])
  | None -> s, t
;;

let unpack_scope scope s (u : I.unpack) =
  let n = List.length u.binders in
  let element i (b : I.binder) =
    let expr =
      match I.position u.positions (n - i) with
      | Some k -> P.Index (s, k)
      | None -> erased
    in
    value_var expr b.ty
  in
  { scope with vars = List.rev_append (List.mapi u.binders ~f:element) scope.vars }
;;

let pure e = { before = []; rest = Expr (e, None) }

let fill ctx x =
  match ctx with
  | Hole -> x
  | Around f -> f x
;;

let prepend stmts v = { v with before = stmts @ v.before }

let map f v =
  match v.rest with
  | Expr (e, _) | Jump (e, _) -> { v with rest = Expr (f e, None) }
  | Fork (fork, ctx) -> { v with rest = Fork (fork, Around (fun x -> f (fill ctx x))) }
  | Leave _ -> v
;;

let rec always_leaves v =
  match v.rest with
  | Leave _ -> true
  | Expr _ | Jump _ -> false
  | Fork (fork, _) ->
    (match fork.shape with
     | Cases (_, cases, _) -> List.for_all cases ~f:(fun (_, a) -> always_leaves a.value)
     | Tests (tested, last) ->
       List.for_all tested ~f:(fun (_, a) -> always_leaves a.value)
       && always_leaves last.value)
;;

let expression v =
  match v with
  | { before = []; rest = Expr (e, _) | Jump (e, _) } -> Some e
  | _ -> None
;;

let jumps v =
  match v.rest with
  | Jump _ -> true
  | Expr _ | Fork _ | Leave _ -> false
;;

let rec atom = function
  | P.Var _ | P.Helper _ | P.Text _ | P.Bytes _ | P.Bigint _ | P.Number _ -> true
  | P.Code s -> P.is_atom s
  | P.Field (e, _) | P.Index (e, _) -> atom e
  | _ -> false
;;

let pushable ctx =
  let hole = P.Var "" in
  let rec spine e =
    phys_equal e hole
    ||
    match e with
    | P.Call (f, _, args) -> along (f :: args)
    | P.Tuple es -> along es
    | P.Record fields -> along (List.map fields ~f:snd)
    | _ -> false
  and along es =
    match List.filter es ~f:(fun e -> phys_equal e hole || not (atom e)) with
    | [ e ] -> spine e
    | _ -> false
  in
  match ctx with
  | Hole -> true
  | Around f -> spine (f hole)
;;

let flat e =
  atom e
  ||
  match e with
  | P.Call (f, _, args) -> List.for_all (f :: args) ~f:atom
  | P.Tuple es -> List.for_all es ~f:atom
  | P.Record fields -> List.for_all fields ~f:(fun (_, e) -> atom e)
  | _ -> false
;;

let sink_stmt sink e =
  match sink with
  | Return | Loop _ -> P.Return e
  | Assign x -> P.Assign (x, e)
;;

let reads e =
  List.map (fst (P.reads (P.Value { P.name = ""; ty = None; value = e }))) ~f:fst
;;

let rec ends stmts = List.exists stmts ~f:ends_stmt

and ends_stmt = function
  | P.Return _ | P.Continue -> true
  | P.If (_, a, b) -> (not (List.is_empty b)) && ends a && ends b
  | P.Switch (_, cases) ->
    List.exists cases ~f:(fun (c : P.case) -> Option.is_none c.label)
    && List.for_all cases ~f:(fun (c : P.case) -> ends c.body)
  | P.Const _
  | P.Bind _
  | P.Let _
  | P.Variable _
  | P.Assign _
  | P.Cell_write _
  | P.Eval _
  | P.Bump _
  | P.Break
  | P.Loop _
  | P.While _ -> false
;;

let remember_local scope x =
  match scope.machine, scope.loop with
  | Some m, _ -> m.locals := x :: !(m.locals)
  | None, Some l -> l.locals := x :: !(l.locals)
  | None, None -> ()
;;

let rec run scope v sink =
  v.before
  @
  match v.rest, sink with
  | Leave stmts, _ -> stmts
  | Jump (e, es), Loop l -> jump scope l e es
  | Expr (_, Some fork), (Return | Loop _) -> lower fork Hole sink
  | (Expr (e, _) | Jump (e, _)), _ -> [ sink_stmt sink e ]
  | Fork (fork, ctx), _ when pushable ctx -> lower fork ctx sink
  | Fork (fork, ctx), _ ->
    let stmts, e = settle scope fork ctx in
    stmts @ [ sink_stmt sink e ]

and jump scope l e es =
  let passes_itself (k : kept) e =
    Option.is_some k.copy || P.equal_expr e (P.Var k.param)
  in
  match List.for_all2 l.kept es ~f:passes_itself with
  | Unequal_lengths | Ok false -> [ P.Return e ]
  | Ok true ->
    let updates =
      List.filter_map (List.zip_exn l.kept es) ~f:(fun ((k : kept), e) ->
        match k.copy with
        | Some x when not (P.equal_expr e (P.Var x)) -> Some (x, e, (k.binder, k.param_ty))
        | Some _ | None -> None)
    in
    simultaneous scope updates @ [ P.Continue ]

and simultaneous scope updates =
  let reads_copy (_, e, _) (x, _, _) = List.mem (reads e) x ~equal:String.equal in
  let rec order pending =
    let others (x, _, _) =
      List.filter pending ~f:(fun (x', _, _) -> not (String.equal x x'))
    in
    let free u = not (List.exists (others u) ~f:(fun u' -> reads_copy u' u)) in
    match pending, List.find pending ~f:free with
    | [], _ -> [], []
    | _, Some ((x, e, _) as u) ->
      let held, assigned = order (others u) in
      held, P.Assign (x, e) :: assigned
    | _, None ->
      let cyclic u = List.exists (others u) ~f:(reads_copy u) in
      let x, e, ((b, t) as k) =
        List.find_exn
          (List.filter pending ~f:(fun (_, e, _) -> not (atom e)) @ pending)
          ~f:cyclic
      in
      let next, _ = declare scope b in
      remember_local scope next;
      let held, assigned =
        order
          (List.map pending ~f:(fun ((x', _, _) as u) ->
             if String.equal x x' then x, P.Var next, k else u))
      in
      P.Const (next, Some t, e) :: held, assigned
  in
  let held, assigned = order updates in
  held @ assigned

and lower fork ctx sink =
  let arm a =
    run
      a.scope
      (match ctx with
       | Hole -> a.value
       | Around f -> map f a.value)
      sink
  in
  match fork.shape, sink with
  | Cases (d, cases, exhaustive), _ ->
    let default =
      match exhaustive with
      | Some s ->
        [ { P.label = None
          ; body = [ sink_stmt sink (P.Satisfies (s, P.Name ("never", []))) ]
          }
        ]
      | None -> []
    in
    let last = List.length cases - 1 in
    let case j (label, a) =
      let body = arm a in
      let closing =
        match sink with
        | Assign _ when (j < last || not (List.is_empty default)) && not (ends body) ->
          [ P.Break ]
        | Assign _ | Return | Loop _ -> []
      in
      { P.label; body = body @ closing }
    in
    [ P.Switch (d, List.mapi cases ~f:case @ default) ]
  | Tests (tested, last), (Return | Loop _) ->
    List.map tested ~f:(fun (t, a) -> P.If (t, arm a, [])) @ arm last
  | Tests (tested, last), Assign _ ->
    List.fold_right
      tested
      ~f:(fun (t, a) rest ->
        let body = arm a in
        if ends body then P.If (t, body, []) :: rest else [ P.If (t, body, rest) ])
      ~init:(arm last)

and settle scope fork ctx =
  if scope.block.top then CErrors.anomaly (Pp.str "Ts_expr.settle: the top has no block.");
  let r, _ = declare scope (base "result") in
  P.Let (r, fork.result) :: lower fork Hole (Assign r), fill ctx (P.Var r)
;;

let settled scope v =
  match v.rest with
  | Expr (e, _) | Jump (e, _) -> v.before, e
  | Fork (fork, ctx) ->
    let stmts, e = settle scope fork ctx in
    v.before @ stmts, e
  | Leave _ ->
    CErrors.anomaly (Pp.str "Ts_expr.settled: a step of a machine is an operand.")
;;

let all scope vs k =
  let last =
    List.foldi vs ~init:(-1) ~f:(fun i found v ->
      match v.rest with
      | Fork _ -> i
      | Expr _ | Jump _ | Leave _ -> found)
  in
  let parts =
    List.mapi vs ~f:(fun i v ->
      match v.rest with
      | Fork (fork, ctx) when i = last -> v.before, `Open (fork, ctx)
      | Fork _ | Expr _ | Jump _ | Leave _ ->
        let stmts, e = settled scope v in
        stmts, `Closed e)
  in
  let before = List.concat_map parts ~f:fst in
  let build x =
    k
      (List.map parts ~f:(function
         | _, `Closed e -> e
         | _, `Open (_, ctx) -> fill ctx x))
  in
  match
    List.find_map parts ~f:(function
      | _, `Open (fork, _) -> Some fork
      | _, `Closed _ -> None)
  with
  | Some fork -> { before; rest = Fork (fork, Around build) }
  | None -> { before; rest = Expr (build erased, None) }
;;

let define scope v name t =
  remember_local scope name;
  v.before
  @
  match v.rest with
  | _ when always_leaves v -> run scope { v with before = [] } Return
  | Leave stmts -> stmts
  | Expr (e, _) | Jump (e, _) -> [ P.Const (name, Some t, e) ]
  | Fork (fork, ctx) when pushable ctx -> P.Let (name, t) :: lower fork ctx (Assign name)
  | Fork (fork, ctx) ->
    let stmts, e = settle scope fork ctx in
    stmts @ [ P.Const (name, Some t, e) ]
;;

let rec bind_flat scope v name t body ~result =
  match v.rest with
  | _ when always_leaves v -> v
  | Fork (fork, ctx) when pushable ctx ->
    let arm a =
      { a with value = bind_flat a.scope (map (fill ctx) a.value) name t body ~result }
    in
    let shape =
      match fork.shape with
      | Cases (d, cases, exhaustive) ->
        Cases (d, List.map cases ~f:(fun (l, a) -> l, arm a), exhaustive)
      | Tests (tested, last) ->
        Tests (List.map tested ~f:(fun (c, a) -> c, arm a), arm last)
    in
    { before = v.before; rest = Fork ({ result; shape }, Hole) }
  | Expr _ | Jump _ | Fork _ | Leave _ -> { before = define scope v name t; rest = body }
;;

let is_global r r' = Table.Refset'.mem r (Table.Refset'.singleton r')

let own_tparams tys =
  List.for_alli tys ~f:(fun i t ->
    match t with
    | T.Var j -> j = i + 1
    | _ -> false)
;;

let calls_itself self ~arity head n ~local =
  n = arity
  &&
  match self, head with
  | Top r, I.Global (r', tys) -> is_global r r' && own_tparams tys
  | Named v, I.Local (k, []) ->
    (match local k with
     | Some v' -> phys_equal v v'
     | None -> false)
  | Top _, _ | Named _, _ -> false
;;

let calls_loop scope head n =
  match scope.loop with
  | Some l ->
    calls_itself l.self ~arity:l.arity head n ~local:(fun k -> Some (var scope k))
  | None -> false
;;

type seen =
  { reaches : int list
  ; param : int option
  ; arity : int
  ; outer : var option
  }

let unseen arity = { reaches = []; param = None; arity; outer = None }

(* A function that the body builds and that reads such a parameter, or a
   pattern variable of a match on it, would read a copy that the loop
   assigns later, which no-loop-func rejects, so the function does not
   loop then. *)
let loops scope ~self params body =
  let arity = List.length params in
  let varies = Array.create ~len:arity false in
  let captured = Array.create ~len:arity false in
  let tail_call = ref false in
  let lookup env k =
    match List.nth env (k - 1) with
    | Some s -> s
    | None ->
      let j = k - List.length env in
      if j <= arity
      then (
        let i = arity - j in
        match List.nth_exn params i with
        | Some _ -> { reaches = [ i ]; param = Some i; arity = 0; outer = None }
        | None -> unseen 0)
      else { (unseen (var scope j).arity) with outer = Some (var scope j) }
  in
  let reached env e =
    List.filter (List.init arity ~f:Fn.id) ~f:(fun i ->
      refers
        ~local:(fun k -> List.mem (lookup env k).reaches i ~equal:Int.equal)
        ~global:(fun _ -> false)
        e)
  in
  let rec walk env ~tail ~inside e =
    let here = walk env ~tail:false ~inside in
    match e with
    | I.Local (k, _) ->
      if inside then List.iter (lookup env k).reaches ~f:(fun i -> captured.(i) <- true)
    | I.Apply (head, args) ->
      if
        tail
        && calls_itself self ~arity head (List.length args) ~local:(fun k ->
          (lookup env k).outer)
      then (
        tail_call := true;
        List.iteri args ~f:(fun i (a : I.arg) ->
          match a.expr with
          | I.Local (k, _) when [%equal: int option] (lookup env k).param (Some i) -> ()
          | _ -> varies.(i) <- true));
      let builds =
        List.length args
        <
        match head with
        | I.Global (r, _) -> (Ts_env.term scope.env r).arity
        | I.Local (k, _) -> (lookup env k).arity
        | I.Fix (i, defs) -> I.arity defs.(i).body
        | _ -> 0
      in
      here head;
      List.iter args ~f:(fun (a : I.arg) ->
        walk env ~tail:false ~inside:(inside || builds) a.expr)
    | I.Lambda (_, bs, _, body) ->
      walk (List.map bs ~f:(fun _ -> unseen 0) @ env) ~tail:false ~inside:true body
    | I.Let (_, _, e1, e2, _) ->
      here e1;
      let arity =
        match e1 with
        | I.Fix (i, defs) -> I.arity defs.(i).body
        | e1 -> I.arity e1
      in
      walk (unseen arity :: env) ~tail ~inside e2
    | I.Construct (r, _, args) ->
      let delayed =
        match (Ts_env.ind scope.env (Ts_env.ctor scope.env r).ind).repr with
        | Ts_repr.Lazy _ -> true
        | Ts_repr.(Tagged _ | Record _ | Erased | Custom _) -> false
      in
      List.iter args ~f:(walk env ~tail:false ~inside:(inside || delayed))
    | I.Match m ->
      here m.scrutinee;
      let reaches = reached env m.scrutinee in
      let itself =
        match m.scrutinee with
        | I.Local (k, _) -> (lookup env k).param
        | _ -> None
      in
      let builds =
        match repr scope m with
        | Ts_repr.Custom { selectors = None; match_code = Some _; _ } -> true
        | Ts_repr.(Tagged _ | Lazy _ | Record _ | Erased | Custom _) -> false
      in
      List.iter m.branches ~f:(fun (br : I.branch) ->
        let param =
          match br.pattern with
          | I.Default { binds_scrutinee = true } -> itself
          | I.Default { binds_scrutinee = false } | I.Ctor _ -> None
        in
        walk
          (List.map br.binders ~f:(fun _ -> { (unseen 0) with reaches; param }) @ env)
          ~tail:(tail && not builds)
          ~inside:(inside || builds)
          br.body)
    | I.Unpack u ->
      here u.tuple;
      let reaches = reached env u.tuple in
      walk
        (List.map u.binders ~f:(fun _ -> { (unseen 0) with reaches }) @ env)
        ~tail
        ~inside
        u.body
    | I.Fix (_, defs) ->
      let env =
        Array.fold defs ~init:env ~f:(fun env (d : I.fixdef) ->
          unseen (I.arity d.body) :: env)
      in
      Array.iter defs ~f:(fun (d : I.fixdef) -> walk env ~tail:false ~inside d.body)
    | I.Cast (e, _, _, _) -> here e
    | I.Tuple es -> List.iter es ~f:here
    | I.Parray (es, x) -> List.iter (x :: es) ~f:here
    | I.Global _ | I.Fail _ | I.Dummy | I.Uint _ | I.Float _ | I.String _ -> ()
  in
  walk [] ~tail:true ~inside:false body;
  if !tail_call && not (Array.exists2_exn varies captured ~f:( && ))
  then Some varies
  else None
;;

let rec binders scope e =
  let ids bs = List.map bs ~f:(fun (b : I.binder) -> b.id) in
  let binders = binders scope in
  match e with
  | I.Lambda (_, bs, _, e) -> ids bs @ binders e
  | I.Let (b, _, e1, e2, _) -> (b.id :: binders e1) @ binders e2
  | I.Match m ->
    let declared (br : I.branch) =
      match repr scope m with
      | Ts_repr.Custom _ -> ids br.binders
      | Ts_repr.(Tagged _ | Lazy _ | Record _ | Erased) -> []
    in
    binders m.scrutinee
    @ List.concat_map m.branches ~f:(fun (br : I.branch) -> declared br @ binders br.body)
  | I.Unpack u -> binders u.tuple @ binders u.body
  | I.Fix (_, defs) ->
    List.concat_map (Array.to_list defs) ~f:(fun (d : I.fixdef) ->
      Miniml.Id d.name :: binders d.body)
  | I.Apply (f, args) ->
    binders f @ List.concat_map args ~f:(fun (a : I.arg) -> binders a.expr)
  | I.Construct (_, _, es) | I.Tuple es -> List.concat_map es ~f:binders
  | I.Cast (e, _, _, _) -> binders e
  | I.Parray (es, x) -> List.concat_map (x :: es) ~f:binders
  | I.Local _ | I.Global _ | I.Fail _ | I.Dummy | I.Uint _ | I.Float _ | I.String _ -> []
;;

let rec writes stmts =
  List.fold stmts ~init:([], false) ~f:(fun (xs, continues) s ->
    let ys, c =
      match s with
      | P.Assign (x, _) | P.Bump (x, _) -> [ x ], false
      | P.Continue -> [], true
      | P.If (_, a, b) -> writes (a @ b)
      | P.Switch (_, cases) ->
        writes (List.concat_map cases ~f:(fun (c : P.case) -> c.body))
      | P.Const _
      | P.Bind _
      | P.Let _
      | P.Variable _
      | P.Cell_write _
      | P.Eval _
      | P.Return _
      | P.Break
      | P.Loop _
      | P.While _ -> [], false
    in
    ys @ xs, continues || c)
;;

let picked defs i =
  let d : I.fixdef = defs.(i) in
  { I.id = Miniml.Id d.name; ty = d.ty }
;;

type recursive =
  { itself : self
  ; heads : Ts_anf.member list
  ; lambdas : (I.binder list * I.ty * I.expr) list
  ; entry : int
  }

let below k heads =
  List.map heads ~f:(fun (m : Ts_anf.member) ->
    match m.head with
    | Ts_anf.Local i -> { m with head = Ts_anf.Local (i + k) }
    | Ts_anf.Global _ -> m)
;;

exception Unsupported

let snapshot scope =
  let l = scope.lifting in
  let decls = l.decls in
  let taken = l.taken in
  let lifted = Ts_names.lifted scope.names in
  let rec blocks b =
    (b, b.declared, b.chosen)
    ::
    (match b.outer with
     | Some o -> blocks o
     | None -> [])
  in
  let saved = blocks scope.block in
  fun () ->
    let () = Fields_of_lifting.Direct.set_all_mutable_fields l ~decls ~taken in
    Ts_names.restore scope.names lifted;
    List.iter saved ~f:(fun (b, declared, chosen) ->
      Fields_of_block.Direct.set_all_mutable_fields b ~declared ~chosen)
;;

let level_var scope level = List.nth_exn scope.vars (List.length scope.vars - level)
let suffix k l = List.drop l (List.length l - k)
let names_read stmts = reads (P.Arrow ([], [], None, P.Block stmts))

let named_arrow scope tparams params result body =
  let value = P.Arrow (tparams, params, result, body) in
  let read = reads value in
  let params =
    List.map params ~f:(fun (x, t) ->
      if List.mem read x ~equal:String.equal || String.is_prefix x ~prefix:"_"
      then x, t
      else
        fst (declare_with scope (fun avoid -> fst (Ts_names.reserve avoid ("_" ^ x)))), t)
  in
  P.Arrow (tparams, params, result, body)
;;

let cell_array_of t = P.Raw [ P.Verbatim "["; P.Hole t; P.Verbatim "][]" ]

let column frames t =
  match List.find frames.columns ~f:(fun c -> P.equal_ty c.cty t) with
  | Some c -> c
  | None ->
    let array, _ = declare frames.storage (base "saved") in
    let cursor, _ = declare frames.storage (base "top") in
    let c = { cty = t; array; cursor } in
    frames.columns <- frames.columns @ [ c ];
    c
;;

let saved m level (v : var) =
  level > m.base
  &&
  match v.expr with
  | P.Code "undefined" -> false
  | P.Var x -> not (List.mem m.fixed x ~equal:String.equal)
  | _ -> true
;;

let site_of scope m key b body ~callee =
  let frames = m.frames in
  match List.find frames.sites ~f:(fun s -> phys_equal s.key key) with
  | Some s -> s
  | None ->
    let levels sc e =
      let n = List.length sc.vars in
      List.filter_map (Ts_anf.free e) ~f:(fun k ->
        if k = 1 then None else Some (n - k + 2))
    in
    let found =
      levels scope body
      @ List.concat_map m.chain ~f:(fun st -> levels st.let_scope st.let_body)
    in
    let unique = List.stable_dedup found ~compare:Int.compare in
    let saved_ty (v : var) =
      if v.arity = 0
      then ty scope v.ty
      else (
        let params, result = T.split v.arity v.ty in
        P.Fn
          { tparams = []
          ; params =
              List.mapi
                (List.filter params ~f:(fun t -> not (T.is_erased t)))
                ~f:(fun i t -> "_" ^ Int.to_string i, ty scope t)
          ; result = ty scope result
          })
    in
    let slots =
      List.filter_map unique ~f:(fun l ->
        let v = level_var scope l in
        if not (saved m l v)
        then None
        else if not (List.is_empty v.tparams)
        then raise Unsupported
        else Some (l, column frames (saved_ty v)))
    in
    let site =
      { key
      ; kind = List.length frames.sites
      ; site_owner = m.owner
      ; site_callee = callee
      ; slots
      ; site_scope = scope
      ; site_binder = b
      ; site_body = body
      ; site_steps = m.chain
      }
    in
    frames.sites <- frames.sites @ [ site ];
    site
;;

let push_column (c : column) e =
  [ P.Cell_write (c.array, c.cursor, e); P.Bump (c.cursor, 1) ]
;;

let push scope m site =
  let f = m.frames in
  [ P.Cell_write (f.kinds, f.depth, P.Number (Int.to_string site.kind))
  ; P.Bump (f.depth, 1)
  ]
  @ List.concat_map site.slots ~f:(fun (l, c) -> push_column c (level_var scope l).expr)
;;

let assignments scope m i es =
  let bs, _ = m.bodies.(i) in
  let updates =
    List.filter_map
      (List.zip_exn (List.zip_exn m.registers.(i) bs) es)
      ~f:(fun ((r, (b : I.binder)), e) ->
        match r with
        | Register x when not (P.equal_expr e (P.Var x)) ->
          Some (x, e, (b.id, ty scope b.ty))
        | Register _ | Parameter | Pushed _ | Dropped -> None)
  in
  let pushes =
    List.concat_map
      (List.zip_exn m.registers.(i) es)
      ~f:(fun (r, e) ->
        match r with
        | Pushed c -> push_column c e
        | Register _ | Parameter | Dropped -> [])
  in
  let which =
    match m.which with
    | Some w when not ([%equal: int option] m.current (Some i)) ->
      [ P.Assign (w, P.Number (Int.to_string i)) ]
    | Some _ | None -> []
  in
  pushes @ simultaneous scope updates @ which
;;

let rec map_stmts f stmts =
  List.concat_map stmts ~f:(fun s ->
    match s with
    | P.If (t, a, b) -> f (P.If (t, map_stmts f a, map_stmts f b))
    | P.Switch (d, cases) ->
      f
        (P.Switch
           ( d
           , List.map cases ~f:(fun (c : P.case) -> { c with body = map_stmts f c.body })
           ))
    | P.Loop body -> f (P.Loop (map_stmts f body))
    | P.While (x, body) -> f (P.While (x, map_stmts f body))
    | s -> f s)
;;

let prune_assignments unread locals =
  let discard e =
    match e with
    | P.Var _ | P.Text _ | P.Bytes _ | P.Bigint _ | P.Number _ | P.Helper _ | P.Arrow _
    | P.Code ("undefined" | "true" | "false" | "null" | "0" | "0n") -> []
    | P.Code _
    | P.Field _
    | P.Index _
    | P.Cell_read _
    | P.Tuple _
    | P.Call _
    | P.Cond _
    | P.Equals _
    | P.Not_equals _
    | P.Add _
    | P.Not _
    | P.Record _
    | P.Module_object _
    | P.Satisfies _ -> [ P.Eval e ]
  in
  map_stmts (function
    | P.Assign (x, e) when List.mem unread x ~equal:String.equal -> discard e
    | P.Const (x, _, e)
      when List.mem unread x ~equal:String.equal && List.mem locals x ~equal:String.equal
      -> discard e
    | P.Let (x, _) when List.mem unread x ~equal:String.equal -> []
    | ( P.Const _
      | P.Bind _
      | P.Let _
      | P.Variable _
      | P.Assign _
      | P.Cell_write _
      | P.Bump _
      | P.Eval _
      | P.Return _
      | P.Break
      | P.Continue
      | P.Switch _
      | P.If _
      | P.Loop _
      | P.While _ ) as s -> [ s ])
;;

let rec prune_storage bodies ~registers ~locals =
  let read = names_read (List.concat bodies) in
  let unread =
    List.filter (registers @ locals) ~f:(fun x ->
      not (List.mem read x ~equal:String.equal))
  in
  let pruned = List.map bodies ~f:(prune_assignments unread locals) in
  if [%equal: P.stmt list list] bodies pruned
  then pruned, unread
  else prune_storage pruned ~registers ~locals
;;

let additive_frames scope frames cases bodies =
  let realisers =
    List.filter_map frames.sites ~f:(fun site ->
      let reference =
        match site.site_body with
        | I.Construct (r, [], _) -> Some (r, Ts_names.value site.site_scope.names r)
        | I.Apply (I.Global (r, []), _) -> Some (r, global site.site_scope r)
        | _ -> None
      in
      Option.bind reference ~f:(fun (r, value) ->
        if Table.is_custom r && List.is_empty site.site_steps
        then Some (value, Ts_names.custom r)
        else None))
  in
  let known callee codes =
    List.exists realisers ~f:(fun (value, code) ->
      P.equal_expr value callee && List.mem codes code ~equal:String.equal)
  in
  let returned x = String.equal x frames.returned in
  let increment = function
    | [ P.Assign (target, P.Call (f, [], [ P.Var source ])) ] ->
      returned target && returned source && known f [ "((n: bigint): bigint => n + 1n)" ]
    | _ -> false
  in
  let summand c = function
    | [ P.Bump (cursor, -1)
      ; P.Const (x, Some t, P.Cell_read (P.Var array, index))
      ; P.Assign (target, P.Call (f, [], [ P.Var a; P.Var b ]))
      ] ->
      String.equal cursor c.cursor
      && String.equal index c.cursor
      && String.equal array c.array
      && P.equal_ty t (P.Name ("bigint", []))
      && returned target
      && ((String.equal a x && returned b) || (returned a && String.equal b x))
      && known
           f
           [ "((n: bigint, m: bigint): bigint => n + m)"
           ; "((x: bigint, y: bigint): bigint => x + y)"
           ]
    | _ -> false
  in
  let transform =
    match cases, frames.columns with
    | [ case ], [] when increment case ->
      Some
        (fun pending ->
          map_stmts (function
            | P.Bump (x, 1) when String.equal x frames.depth ->
              [ P.Assign (pending, P.Add (P.Var pending, P.Bigint "1")) ]
            | stmt -> [ stmt ]))
    | [ case ], [ c ] when summand c case ->
      Some
        (fun pending ->
          map_stmts (function
            | P.Cell_write (array, index, e)
              when String.equal array c.array && String.equal index c.cursor ->
              [ P.Assign (pending, P.Add (P.Var pending, e)) ]
            | P.Bump (cursor, 1) when String.equal cursor c.cursor -> []
            | stmt -> [ stmt ]))
    | _ -> None
  in
  let open Option.Let_syntax in
  let%bind transform = transform in
  let pending, _ = declare scope (base "pending") in
  let bodies = List.map bodies ~f:(transform pending) in
  let obsolete =
    frames.depth :: List.concat_map frames.columns ~f:(fun c -> [ c.array; c.cursor ])
  in
  if
    List.exists
      (names_read (List.concat bodies))
      ~f:(fun x -> List.mem obsolete x ~equal:String.equal)
  then None
  else
    Some
      ( [ P.Variable (pending, P.Bigint "0") ]
      , bodies
      , [ P.Return (P.Add (P.Var frames.returned, P.Var pending)) ] )
;;

let hint = function
  | P.Var x | P.Field (_, x) -> x
  | _ -> "saved"
;;

let names_inside scope bodies =
  List.fold
    (List.concat_map bodies ~f:(binders scope))
    ~init:scope.avoid
    ~f:(fun avoid id -> Ts_names.add avoid (fst (Ts_names.fresh scope.avoid id)))
;;

let declare_copy scope inside (b : I.binder) =
  declare_with scope (fun avoid ->
    fst (Ts_names.fresh (Ts_names.merge avoid inside) b.id))
;;

(* The conditional [test ? a : c], unless a branch is one, or its test or
   the negation of it when the branches are the boolean literals, as
   no-unneeded-ternary asks. *)
let ternary test a c =
  match a, c with
  | P.Code "true", P.Code "false" -> Some test
  | P.Code "false", P.Code "true" -> Some (P.negated test)
  | P.Cond _, _ | _, P.Cond _ -> None
  | _ -> Some (P.Cond (test, a, c))
;;

let rec translate scope e : value =
  match machine_step scope e with
  | Some v -> v
  | None -> translate_term scope e

and translate_term scope e : value =
  match e with
  | I.Let (b, tparams, e1, e2, _) when lifts scope e1 ->
    translate { scope with vars = lift scope b tparams e1 :: scope.vars } e2
  | I.Let (b, tparams, ((I.Lambda _ | I.Fix _) as e1), e2, _) ->
    let stmts, scope' = local_binding scope b tparams e1 in
    prepend stmts (translate scope' e2)
  | I.Let (b, _, e1, e2, t) -> let_in scope (translate scope e1) b e2 t
  | I.Fix (i, defs) when lifts scope e ->
    pure (reference scope (lift scope (picked defs i) [] e) [])
  | I.Fix (i, defs) ->
    let stmts, scope' = fix_group scope defs in
    prepend stmts (pure (reference scope' (var scope' (Array.length defs - i)) []))
  | I.Apply ((I.Fix (i, defs) as fix), args) when lifts scope fix ->
    let args = arguments scope args in
    let v = lift scope (picked defs i) [] fix in
    apply { scope with vars = v :: scope.vars } (I.Local (1, [])) args
  | I.Apply (I.Fix (i, defs), args) ->
    let args = arguments scope args in
    let stmts, scope' = fix_group scope defs in
    prepend stmts (apply scope' (I.Local (Array.length defs - i, [])) args)
  | I.Match m -> match_ scope m
  | I.Unpack u -> unpack scope u
  | I.Tuple es -> all scope (List.map es ~f:(translate scope)) (fun es -> P.Tuple es)
  | I.Apply (I.Dummy, _) -> pure erased
  | I.Apply (head, args) -> apply scope head (arguments scope args)
  | I.Lambda (vs, bs, result, body) -> pure (lambda scope vs bs result body)
  | I.Local (n, tys) -> pure (reference scope (var scope n) tys)
  | I.Global (r, tys) ->
    (match callee scope e with
     | Some c -> pure (eta scope c)
     | None when generic scope r ->
       pure (P.Call (global scope r, List.map tys ~f:(ty scope), []))
     | None -> pure (global scope r))
  | I.Construct (r, tys, args) ->
    let c = Ts_env.ctor scope.env r in
    let repr = (Ts_env.ind scope.env c.ind).repr in
    let tys = List.map tys ~f:(ty scope) in
    let positions = List.zip_exn c.args (List.map args ~f:(pins scope)) in
    let build scope =
      all
        scope
        (List.map args ~f:(translate scope))
        (Ts_repr.construct
           scope.names
           repr
           r
           ~index:c.index
           ~explicit:(not (inferable positions ~tvars:(T.vars c.args)))
           tys)
    in
    (match Ts_repr.delay scope.names repr r ~index:c.index tys with
     | Some suspend ->
       let inner = nested scope in
       pure (suspend (arrow_body (run inner (build inner) Return)))
     | None -> build scope)
  | I.Fail msg -> pure (P.Call (P.Helper P.Fail, [], [ P.Text msg ]))
  | I.Dummy -> pure erased
  | I.Cast (e, from, target, _) ->
    map
      (fun e -> P.Call (P.Helper P.Magic, [ ty scope from; ty scope target ], [ e ]))
      (translate scope e)
  | I.Uint i -> pure (P.Bigint (Int64.to_string (Uint63.to_int64 i)))
  | I.Float f -> pure (P.Number (number (Float64.to_float f)))
  | I.String s -> pure (P.Bytes (Pstring.to_string s))
  | I.Parray (elements, default) ->
    (match Ts_primitives.global Ts_primitives.Parray with
     | Some r when Table.is_custom r ->
       CErrors.user_err
         Pp.(
           str
             "A primitive array literal is extracted as the PArray<A> of the TypeScript \
              backend, which the Extract directive on "
           ++ Printer.pr_global r.glob
           ++ str
                " replaces. Remove the directive, or build the array with PrimArray.make.")
     | Some _ | None -> ());
    all
      scope
      (List.map (default :: elements) ~f:(translate scope))
      (function
        | default :: items -> P.Record [ "default", default; "items", P.Tuple items ]
        | [] -> CErrors.anomaly (Pp.str "Ts_expr.translate: an array has a default."))

and let_in scope v1 (b : I.binder) e2 t =
  if always_leaves v1
  then { before = []; rest = Leave (run scope v1 Return) }
  else (
    let name, scope' = bind scope b ~arity:0 ~tparams:[] in
    let v2 = translate scope' e2 in
    match expression v2 with
    | Some e when flat e ->
      bind_flat scope v1 name (ty scope b.ty) v2.rest ~result:(ty scope t)
    | Some _ | None -> prepend (define scope v1 name (ty scope b.ty)) v2)

and machine_step scope e =
  let open Option.Let_syntax in
  let%bind m = scope.machine in
  let depth = List.length scope.vars - m.base in
  let step f args =
    match Ts_anf.member_at m.members depth f with
    | Some i when List.length args = (List.nth_exn m.members i).arity -> Some i
    | Some _ | None -> None
  in
  let jump i stmts es =
    match m.current with
    | Some c when m.inline && c <> i && List.is_empty m.chain ->
      let bs, body = m.bodies.(i) in
      let copies =
        Ts_anf.delays
          scope.env
          body
          ~arities:
            (List.map bs ~f:(fun _ -> 0)
             @ List.map (suffix m.base scope.vars) ~f:(fun v -> v.arity))
      in
      let sc, vars, consts =
        List.fold2_exn
          bs
          es
          ~init:(scope, [], [])
          ~f:(fun (sc, vars, consts) (b : I.binder) e ->
            match e with
            | _ when T.is_erased b.ty -> sc, value_var erased b.ty :: vars, consts
            | P.Var _ when not copies -> sc, value_var e b.ty :: vars, consts
            | _ ->
              let x, sc = declare sc b.id in
              remember_local sc x;
              ( sc
              , value_var (P.Var x) b.ty :: vars
              , consts @ [ P.Const (x, Some (ty sc b.ty), e) ] ))
      in
      let sc =
        { sc with
          vars = vars @ suffix m.base scope.vars
        ; machine = Some { m with inline = false }
        }
      in
      prepend (stmts @ consts) (translate sc body)
    | Some _ | None ->
      { before = stmts; rest = Leave (assignments scope m i es @ m.leave) }
  in
  let target =
    match e with
    | I.Let (_, _, I.Apply (f, args), _, _) | I.Apply (f, args) -> step f args
    | _ -> None
  in
  match e, target with
  | I.Let (b, _, I.Apply (_, args), body, _), Some i ->
    let stmts, es = step_arguments scope args in
    let site = site_of scope m e b body ~callee:i in
    Some (jump i (stmts @ push scope m site) es)
  | I.Apply (_, args), Some i ->
    let result k = ty scope (List.nth_exn m.members k).result in
    if (not m.uniform) && not (P.equal_ty (result i) (result m.owner))
    then raise Unsupported;
    let stmts, es = step_arguments scope args in
    Some (jump i stmts es)
  | I.Let (b, _, e1, e2, t), _ when Ts_anf.steps_at scope.env m.members depth e1 ->
    let st = { let_binder = b; let_body = e2; let_type = t; let_scope = scope } in
    let v1 =
      translate { scope with machine = Some { m with chain = st :: m.chain } } e1
    in
    Some (let_in scope v1 b e2 t)
  | _ -> None

and step_arguments scope args =
  let v =
    all
      scope
      (List.map args ~f:(fun (a : I.arg) -> translate scope a.expr))
      (fun es -> P.Tuple es)
  in
  match settled scope v with
  | stmts, P.Tuple es -> stmts, es
  | _ -> CErrors.anomaly (Pp.str "Ts_expr.step_arguments: the arguments are a tuple.")

and arguments scope args =
  List.map args ~f:(fun (a : I.arg) ->
    ( { atomic = a.atomic; erased = erased_value a.expr; pins = pins scope a.expr }
    , translate scope a.expr ))

and apply scope head args =
  match callee scope head with
  | Some c when calls_loop scope head (List.length args) ->
    let infos, values = List.unzip args in
    let before, es = List.unzip (List.map values ~f:(settled scope)) in
    { before = List.concat before; rest = Jump (call scope c infos es, passed c es) }
  | Some c ->
    let args =
      if List.length args < c.arity then List.mapi args ~f:(once scope c) else args
    in
    let infos, values = List.unzip args in
    all scope values (call scope c infos)
  | None ->
    let infos, values = List.unzip args in
    all scope (translate scope head :: values) (function
      | f :: es -> curried f (List.zip_exn infos es)
      | [] -> CErrors.anomaly (Pp.str "Ts_expr.apply: an application has a head."))

and once scope c i ((a : argument), v) =
  if a.atomic || dropped c i
  then a, v
  else (
    let name, _ = declare scope (base "x") in
    let t = List.nth_exn (fst (T.split c.arity c.fn_ty)) i in
    a, { before = define scope v name (ty scope t); rest = Expr (P.Var name, None) })

and lambda scope vs bs result body =
  let tvars, names = Ts_names.generic scope.names scope.tvars vs in
  let scope = { scope with tvars } in
  let params, scope' = binds (nested scope) bs in
  match List.rev params with
  | [] -> CErrors.anomaly (Pp.str "Ts_expr.lambda: a lambda binds something.")
  | last :: rev_outer ->
    (match
       List.fold
         rev_outer
         ~init:
           (P.Arrow ([], Option.to_list last, Some (ty scope result), body_of scope' body))
         ~f:(fun inner p -> P.Arrow ([], Option.to_list p, None, P.Expr inner))
     with
     | P.Arrow (_, ps, r, b) -> P.Arrow (P.unbounded names, ps, r, b)
     | e -> e)

and body_of scope e =
  let v = translate scope e in
  match expression v with
  | Some e -> P.Expr e
  | None -> P.Block (run scope v Return)

and arrow_body = function
  | [ P.Return e ] -> P.Expr e
  | stmts -> P.Block stmts

and local_function scope ~group ~recursive tparams = function
  | I.Lambda (_, bs, result, body) ->
    let tvars, names = Ts_names.generic scope.names scope.tvars group in
    let named = List.zip_exn group names in
    let hidden =
      List.filter group ~f:(fun i -> not (List.mem tparams i ~equal:Int.equal))
    in
    let scope = { scope with tvars = Ts_names.hide tvars hidden } in
    let params, scope' = binds (nested scope) bs in
    let body = named_body scope' ~recursive bs params body ~plain:body_of in
    named_arrow
      scope'
      (P.unbounded
         (List.map tparams ~f:(fun i -> List.Assoc.find_exn named ~equal:Int.equal i)))
      (List.filter_opt params)
      (Some (ty scope result))
      body
  | _ -> CErrors.anomaly (Pp.str "Ts_expr.local_function: not a lambda chain.")

and named_body scope ~recursive bs params body ~plain =
  match recursive with
  | None -> plain scope body
  | Some r ->
    let self = r.itself in
    let varies = loops scope ~self params body in
    let looping () =
      match varies with
      | None -> plain scope body
      | Some varies -> looped scope ~self bs params varies body
    in
    let nb = List.length bs in
    let own = List.nth_exn r.heads r.entry in
    let alone =
      { r with heads = [ own ]; lambdas = [ List.nth_exn r.lambdas r.entry ]; entry = 0 }
    in
    let others = List.filter r.heads ~f:(fun h -> not (phys_equal h own)) in
    let by_itself () =
      if Option.is_some varies && Ts_anf.tails_only scope.env (below nb alone.heads) body
      then looping ()
      else Option.value_or_thunk (machine_body scope ~params alone) ~default:looping
    in
    if (not (List.is_empty others)) && Ts_anf.steps scope.env (below nb others) body
    then Option.value_or_thunk (machine_body scope ~params r) ~default:by_itself
    else by_itself ()

and looped scope ~self bs params varies body =
  let inside = names_inside scope [ body ] in
  let scope, kept =
    List.fold_mapi
      (List.zip_exn bs params)
      ~init:scope
      ~f:(fun i sc ((b : I.binder), p) ->
        match p with
        | None -> sc, None
        | Some (param, param_ty) ->
          let copy, sc =
            if varies.(i)
            then (
              let x, sc = declare_copy sc inside b in
              Some x, sc)
            else None, sc
          in
          sc, Some { param; copy; param_ty; binder = b.id })
  in
  let own, outer = List.split_n scope.vars (List.length bs) in
  let own =
    List.rev
      (List.map2_exn (List.rev own) kept ~f:(fun (v : var) -> function
         | Some { copy = Some x; _ } -> { v with expr = P.Var x }
         | Some { copy = None; _ } | None -> v))
  in
  let l =
    { self; arity = List.length bs; kept = List.filter_opt kept; locals = ref [] }
  in
  let scope = { scope with vars = own @ outer; loop = Some l } in
  let stmts = run scope (translate scope body) (Loop l) in
  let registers = List.filter_map l.kept ~f:(fun k -> k.copy) in
  let bodies, unread = prune_storage [ stmts ] ~registers ~locals:!(l.locals) in
  let stmts = List.hd_exn bodies in
  let assigned, continues = writes stmts in
  let declaration (k : kept) =
    match k.copy with
    | Some x when List.mem unread x ~equal:String.equal -> []
    | Some x when List.mem assigned x ~equal:String.equal ->
      [ P.Variable (x, P.Var k.param) ]
    | Some x -> [ P.Const (x, Some k.param_ty, P.Var k.param) ]
    | None -> []
  in
  let declarations = List.concat_map l.kept ~f:declaration in
  if continues
  then (
    let body =
      match List.rev stmts with
      | P.Continue :: rest -> List.rev rest
      | _ -> stmts
    in
    P.Block (declarations @ [ P.Loop body ]))
  else arrow_body (declarations @ stmts)

and local_binding scope (b : I.binder) tparams = function
  | I.Fix (i, defs) ->
    let stmts, scope' = fix_group scope defs in
    stmts, { scope' with vars = var scope' (Array.length defs - i) :: scope.vars }
  | e1 ->
    let def = local_function scope ~group:tparams ~recursive:None tparams e1 in
    let name, scope' = bind scope b ~arity:(I.arity e1) ~tparams in
    remember_local scope name;
    [ P.Const (name, None, def) ], scope'

and lift scope (b : I.binder) tparams e1 =
  let avoid = Ts_names.avoid scope.names in
  let top =
    { scope with
      vars = []
    ; tvars = Ts_names.params scope.names 0
    ; avoid
    ; block = block ~top:true avoid
    ; loop = None
    ; machine = None
    }
  in
  let stmts, top' = local_binding top b tparams e1 in
  lift_statements scope stmts;
  var top' 1

and group_function scope defs =
  let group =
    Array.fold defs ~init:[] ~f:(fun acc (d : I.fixdef) ->
      acc @ List.filter d.tparams ~f:(fun i -> not (List.mem acc i ~equal:Int.equal)))
  in
  let member j (d : I.fixdef) =
    match d.body with
    | I.Lambda (_, bs, result, body) ->
      Some
        ( { Ts_anf.head = Ts_anf.Local (Array.length defs - j)
          ; arity = List.length bs
          ; result
          ; accepts = (fun tys -> List.is_empty tys)
          }
        , (bs, result, body) )
    | _ -> None
  in
  let members = Array.to_list (Array.mapi defs ~f:member) in
  let mutual = Array.length defs > 1 in
  fun i (d : I.fixdef) ->
    let k = Array.length defs - i in
    let recursive =
      let open Option.Let_syntax in
      let%map own = member i d in
      let members, entry =
        match Option.all members with
        | Some members when mutual -> members, i
        | Some _ | None -> [ own ], 0
      in
      { itself = Named (var scope k)
      ; heads = List.map members ~f:fst
      ; lambdas = List.map members ~f:snd
      ; entry
      }
    in
    local_function scope ~group ~recursive d.tparams d.body

and fix_group scope defs =
  if
    Array.length defs > 1
    && Array.for_all defs ~f:(fun (d : I.fixdef) -> I.arity d.body > 0)
  then (
    let joined =
      String.concat_array
        ~sep:"_"
        (Array.map defs ~f:(fun (d : I.fixdef) -> Names.Id.to_string d.name))
    in
    let obj, scope = declare scope (base joined) in
    let scope', keys =
      Array.fold_map defs ~init:scope ~f:(fun sc (d : I.fixdef) ->
        let key, avoid = Ts_names.key sc.avoid d.name in
        let sc = { sc with avoid } in
        let member =
          { expr = P.Field (P.Var obj, key)
          ; arity = I.arity d.body
          ; ty = d.ty
          ; tparams = d.tparams
          }
        in
        { sc with vars = member :: sc.vars }, key)
    in
    let fields =
      Array.mapi defs ~f:(fun i d -> keys.(i), group_function scope' defs i d)
    in
    [ P.Const (obj, None, P.Record (Array.to_list fields)) ], scope')
  else fix_chain scope defs

and fix_chain scope defs =
  let scope', names =
    Array.fold_map defs ~init:scope ~f:(fun sc (d : I.fixdef) ->
      let name, sc =
        bind
          sc
          { I.id = Miniml.Id d.name; ty = d.ty }
          ~arity:(I.arity d.body)
          ~tparams:d.tparams
      in
      sc, name)
  in
  let definition i (d : I.fixdef) =
    let name = names.(i) in
    if I.arity d.body > 0
    then [ P.Const (name, None, group_function scope' defs i d) ]
    else define scope' (translate scope' d.body) name (ty scope d.ty)
  in
  List.concat (Array.to_list (Array.mapi defs ~f:definition)), scope'

and match_ scope (m : I.match_) =
  let repr = repr scope m in
  let has_args (br : I.branch) =
    match br.pattern with
    | I.Ctor (r, _) -> not (List.is_empty (Ts_env.ctor scope.env r).args)
    | I.Default _ -> false
  in
  let lowered (readable : P.expr -> P.expr option) =
    let stmts, s = settled scope (translate scope m.scrutinee) in
    prepend
      stmts
      (match readable s with
       | Some s' ->
         (match branches scope m repr s' with
          | { rest = Fork _; _ } when scope.block.top -> of_scrutinee scope m repr s
          | v -> v)
       | None -> bind_scrutinee scope m repr s)
  in
  match repr with
  | Ts_repr.Custom { selectors = Some selectors; _ } ->
    lowered (fun s -> Option.some_if (is_path s || tests_scrutinee scope selectors m) s)
  | Ts_repr.Custom { match_code = Some code; _ } -> custom_match scope code m
  | Ts_repr.Custom { match_code = None; _ } when List.exists m.branches ~f:has_args ->
    CErrors.user_err
      Pp.(
        str "Extract Inductive for "
        ++ Printer.pr_global m.ind.glob
        ++ str " needs a match function, its last argument, for TypeScript"
        ++ str " extraction, because a constructor has arguments.")
  | Ts_repr.(Tagged _ | Lazy _ | Record _ | Erased | Custom _) ->
    lowered (readable scope m repr)

and unpack scope (u : I.unpack) =
  let stmts, s = settled scope (translate scope u.tuple) in
  prepend
    stmts
    (if is_path s
     then translate (unpack_scope scope s u) u.body
     else (
       let name, scope' = declare scope (base "p") in
       prepend
         [ P.Const (name, Some (ty scope (T.Tuple u.elements)), s) ]
         (translate (unpack_scope scope' (P.Var name) u) u.body)))

and bind_scrutinee scope (m : I.match_) repr s =
  if scope.block.top
  then of_scrutinee scope m repr s
  else (
    let cell, cell_ty = cell scope m repr s in
    let name, scope' = declare scope (base "s") in
    prepend [ P.Const (name, Some cell_ty, cell) ] (branches scope' m repr (P.Var name)))

and of_scrutinee scope (m : I.match_) repr s =
  let param, inner = declare (enter scope) (base "s") in
  let v = branches inner m repr (P.Var param) in
  let cell, cell_ty = cell scope m repr s in
  let arrow =
    P.Arrow
      ( []
      , [ param, cell_ty ]
      , Some (ty scope m.result)
      , match expression v with
        | Some e -> P.Expr e
        | None -> P.Block (run (enter scope) v Return) )
  in
  let f, _ =
    declare_with scope (fun avoid ->
      fst (Ts_names.reserve avoid (scope.lifting.name ^ "Of")))
  in
  { before = [ P.Const (f, None, arrow) ]
  ; rest = Expr (P.Call (P.Var f, [], [ cell ]), None)
  }

and branches scope m repr s =
  match repr with
  | Ts_repr.Custom { selectors = Some selectors; _ } ->
    inline_branches scope m selectors s
  | Ts_repr.(Tagged _ | Lazy _ | Record _ | Erased | Custom _) ->
    labelled_branches scope m repr s

and labelled_branches scope (m : I.match_) repr s =
  let label (br : I.branch) =
    match br.pattern with
    | I.Ctor (r, _) -> Some (Ts_repr.label scope.names repr r ~index:(ctor_index scope r))
    | I.Default _ -> None
  in
  match m.branches with
  | [ br ] -> translate (branch_scope scope repr s br) br.body
  | brs ->
    let arm (br : I.branch) =
      let scope = branch_scope (enter scope) repr s br in
      { scope; value = translate scope br.body }
    in
    let arms = List.map brs ~f:(fun br -> label br, arm br) in
    let discriminant = Ts_repr.discriminant repr s in
    let conditional =
      let rec chain = function
        | [] -> CErrors.anomaly (Pp.str "Ts_expr.branches: a match has a branch.")
        | [ (_, e) ] | (None, e) :: _ -> e
        | (Some l, e) :: rest -> P.Cond (P.Equals (discriminant, l), e, chain rest)
      in
      let open Option.Let_syntax in
      let%bind expressions =
        Option.all
          (List.map arms ~f:(fun (l, a) ->
             Option.map (expression a.value) ~f:(fun e -> l, e)))
      in
      match chain expressions with
      | P.Cond (test, a, c) -> ternary test a c
      | e -> Some e
    in
    let last = List.length arms - 1 in
    let cases =
      List.mapi arms ~f:(fun j (l, a) ->
        match repr with
        | Ts_repr.Custom _ when j = last -> None, a
        | Ts_repr.(Tagged _ | Lazy _ | Record _ | Erased | Custom _) -> l, a)
    in
    let exhaustive =
      Option.some_if (List.for_all cases ~f:(fun (l, _) -> Option.is_some l)) s
    in
    let fork =
      { result = ty scope m.result; shape = Cases (discriminant, cases, exhaustive) }
    in
    { before = []
    ; rest =
        (match conditional with
         | Some e -> Expr (e, Some fork)
         | None -> Fork (fork, Hole))
    }

and inline_scope scope selectors s (br : I.branch) =
  let n = List.length br.binders in
  let expression i =
    match br.pattern, source br i with
    | I.Ctor (r, _), Argument k ->
      Some
        (P.with_scrutinee (List.nth_exn selectors.(ctor_index scope r).Ts_match.args k) s)
    | _, Scrutinee -> Some s
    | I.Default _, Argument _ | _, Unbound -> None
  in
  let bind i sc (b : I.binder) =
    match expression i with
    | Some e when is_path e -> sc, (value_var e b.ty, None)
    | Some e when occurs (n - i) br.body ->
      let name, sc = declare sc b.id in
      sc, (value_var (P.Var name) b.ty, Some (P.Const (name, Some (ty scope b.ty), e)))
    | Some _ | None -> sc, (value_var erased b.ty, None)
  in
  let scope', bound = List.fold_mapi br.binders ~init:scope ~f:bind in
  let vars, consts = List.unzip bound in
  { scope' with vars = List.rev_append vars scope.vars }, List.filter_opt consts

and inline_branches scope (m : I.match_) selectors s =
  let tested, fallthrough = inline_split m in
  let in_block scope (br : I.branch) =
    let scope', consts = inline_scope scope selectors s br in
    { scope = scope'; value = prepend consts (translate scope' br.body) }
  in
  match tested with
  | [] -> (in_block scope fallthrough).value
  | _ :: _ ->
    let tested =
      List.map tested ~f:(fun br ->
        P.with_scrutinee (inline_test scope selectors br) s, in_block (enter scope) br)
    in
    let last = in_block (enter scope) fallthrough in
    let conditional =
      match tested with
      | [ (t, a) ] ->
        (match expression a.value, expression last.value with
         | Some a, Some c -> ternary t a c
         | None, _ | _, None -> None)
      | _ -> None
    in
    let fork = { result = ty scope m.result; shape = Tests (tested, last) } in
    (match conditional with
     | Some e
       when not (List.exists tested ~f:(fun (_, a) -> jumps a.value) || jumps last.value)
       -> pure e
     | Some e -> { before = []; rest = Expr (e, Some fork) }
     | None -> { before = []; rest = Fork (fork, Hole) })

and custom_match scope code (m : I.match_) =
  let regular =
    List.for_alli m.branches ~f:(fun j (br : I.branch) ->
      let n = List.length br.binders in
      match br.pattern with
      | I.Ctor (r, fields) ->
        ctor_index scope r = j
        && [%equal: int option list] fields (List.init n ~f:(fun k -> Some (n - k)))
      | I.Default _ -> false)
  in
  if not regular
  then
    CErrors.user_err
      Pp.(
        str "Cannot mix the match function of Extract Inductive for "
        ++ Printer.pr_global m.ind.glob
        ++ str " with general patterns.");
  let branch (br : I.branch) =
    let params, scope' = binds (nested scope) br.binders in
    P.Arrow ([], List.filter_opt params, Some (ty scope m.result), body_of scope' br.body)
  in
  let branches = List.map m.branches ~f:branch in
  map
    (fun s ->
       P.Call (Ts_names.match_function scope.names m.ind code, [], branches @ [ s ]))
    (translate scope m.scrutinee)

and machine_body scope ~params r =
  let env = scope.env in
  let nb =
    let bs, _, _ = List.nth_exn r.lambdas r.entry in
    List.length bs
  in
  let outside = List.length scope.vars - nb in
  let outer = suffix outside scope.vars in
  let r, outside, outer =
    match Ts_anf.lift_fixes env r.heads r.lambdas with
    | Some (heads, lambdas) ->
      let bs, res, _ = List.nth_exn lambdas (List.length lambdas - 1) in
      let lifted =
        { expr = P.Var " lifted"
        ; arity = List.length bs
        ; ty = T.curried (List.map bs ~f:(fun (b : I.binder) -> b.ty)) res
        ; tparams = []
        }
      in
      { r with heads; lambdas }, outside + 1, lifted :: outer
    | None -> r, outside, outer
  in
  let lambdas =
    List.map r.lambdas ~f:(fun (bs, res, b) ->
      bs, res, Ts_anf.normalise env (below (List.length bs) r.heads) b)
  in
  let shape (bs, res, _) =
    ( List.map bs ~f:(fun (b : I.binder) ->
        if T.is_erased b.ty then None else Some (ty scope b.ty))
    , ty scope res )
  in
  let entry_lambda = List.nth_exn lambdas r.entry in
  let entry_bs, result, entry_body = entry_lambda in
  if
    not
      (List.exists lambdas ~f:(fun (bs, _, b) ->
         Ts_anf.steps env (below (List.length bs) r.heads) b))
  then None
  else (
    let undo = snapshot scope in
    let uniform =
      List.for_all lambdas ~f:(fun l ->
        [%equal: P.ty option list * P.ty] (shape l) (shape entry_lambda))
    in
    let attempt ~inline =
      try
        let single =
          match lambdas with
          | [ _ ] -> true
          | _ -> false
        in
        let calls = Ts_anf.calls env (below nb r.heads) entry_body in
        let invariant p =
          single
          && List.for_all calls ~f:(fun (_, d, (args : I.arg list)) ->
            match (List.nth_exn args p).expr with
            | I.Local (k, _) -> k - d = nb - p
            | _ -> false)
        in
        let inside = names_inside scope (List.map lambdas ~f:(fun (_, _, b) -> b)) in
        let scope_r, regs =
          List.fold_mapi
            (List.zip_exn entry_bs params)
            ~init:scope
            ~f:(fun p sc ((b : I.binder), param) ->
              match param with
              | None -> sc, Dropped
              | Some _ when invariant p -> sc, Parameter
              | Some _ ->
                let x, sc = declare_copy sc inside b in
                sc, Register x)
        in
        let param_name p =
          match List.nth_exn params p with
          | Some (name, _) -> name
          | None -> CErrors.anomaly (Pp.str "Ts_expr.machine_body: a kept parameter.")
        in
        let fixed =
          List.filter_mapi regs ~f:(fun p r ->
            match r with
            | Parameter -> Some (param_name p)
            | Register _ | Pushed _ | Dropped -> None)
        in
        let which, scope_r =
          if single
          then None, scope_r
          else (
            let w, sc = declare scope_r (base "which") in
            Some w, sc)
        in
        let returned, scope_r = declare scope_r (base "returned") in
        let depth, scope_r = declare scope_r (base "depth") in
        let kinds = " kinds" in
        let frames =
          { storage = scope_r; returned; depth; kinds; columns = []; sites = [] }
        in
        let registers =
          Array.of_list
            (List.mapi lambdas ~f:(fun j (bs, _, _) ->
               if uniform || j = r.entry
               then regs
               else
                 List.map bs ~f:(fun (b : I.binder) ->
                   if T.is_erased b.ty
                   then Dropped
                   else Pushed (column frames (ty scope b.ty)))))
        in
        let machine =
          { members = r.heads
          ; base = outside
          ; registers
          ; locals = ref []
          ; which
          ; current = None
          ; leave = [ P.Continue ]
          ; chain = []
          ; frames
          ; fixed
          ; bodies = Array.of_list (List.map lambdas ~f:(fun (bs, _, b) -> bs, b))
          ; inline
          ; owner = r.entry
          ; uniform
          }
        in
        let loop = enter scope_r in
        let member i (bs, _, body) =
          let sc = if single then loop else enter loop in
          let copies =
            Ts_anf.delays
              env
              body
              ~arities:(List.map bs ~f:(fun _ -> 0) @ List.map outer ~f:(fun v -> v.arity))
          in
          let sc, vars, consts =
            List.fold
              (List.mapi bs ~f:(fun p b -> p, b))
              ~init:(sc, [], [])
              ~f:(fun (sc, vars, consts) (p, (b : I.binder)) ->
                match List.nth_exn registers.(i) p with
                | Dropped -> sc, value_var erased b.ty :: vars, consts
                | Parameter -> sc, value_var (P.Var (param_name p)) b.ty :: vars, consts
                | Register x when copies ->
                  let c, sc = declare sc b.id in
                  remember_local { sc with machine = Some machine } c;
                  ( sc
                  , value_var (P.Var c) b.ty :: vars
                  , consts @ [ c, `Copy (P.Const (c, None, P.Var x)) ] )
                | Register x -> sc, value_var (P.Var x) b.ty :: vars, consts
                | Pushed col ->
                  let c, sc = declare sc b.id in
                  sc, value_var (P.Var c) b.ty :: vars, (c, `Pop col) :: consts)
          in
          let sc =
            { sc with
              vars = vars @ outer
            ; machine = Some { machine with current = Some i; owner = i }
            }
          in
          consts, sc, translate sc body, i
        in
        let translated = List.mapi lambdas ~f:member in
        let framed = not (List.is_empty frames.sites) in
        let result_column j =
          let _, res, _ = List.nth_exn lambdas j in
          column frames (ty scope res)
        in
        let deliver sc j produce =
          if not framed
          then produce sc Return
          else if uniform
          then produce sc (Assign returned)
          else (
            let x, sc = declare sc (base "returned") in
            let stmts = produce sc (Assign x) in
            let push e = push_column (result_column j) e in
            match List.rev stmts with
            | P.Assign (y, e) :: rest
              when String.equal x y
                   && not (List.mem (fst (writes rest)) x ~equal:String.equal) ->
              List.rev rest @ push e
            | _ when List.mem (fst (writes stmts)) x ~equal:String.equal ->
              (P.Let (x, (result_column j).cty) :: stmts) @ push (P.Var x)
            | _ -> stmts)
        in
        let prelude consts stmts =
          let read = names_read stmts in
          List.concat_map consts ~f:(fun (c, const) ->
            match const with
            | `Copy const -> if List.mem read c ~equal:String.equal then [ const ] else []
            | `Pop col ->
              P.Bump (col.cursor, -1)
              ::
              (if List.mem read c ~equal:String.equal
               then
                 [ P.Const (c, Some col.cty, P.Cell_read (P.Var col.array, col.cursor)) ]
               else []))
          @ stmts
        in
        let bodies =
          List.map translated ~f:(fun (consts, sc, v, i) ->
            prelude consts (deliver sc i (fun sc sink -> run sc v sink)))
        in
        let unwind = enter loop in
        let resuming, _ = declare loop (base "resuming") in
        let resumer =
          { machine with leave = [ P.Assign (resuming, P.Code "false"); P.Continue ] }
        in
        let resume site =
          let cs = enter unwind in
          let reads, slot_vars, cs =
            List.fold
              (List.rev site.slots)
              ~init:([], [], cs)
              ~f:(fun (reads, slot_vars, cs) (l, c) ->
                let x, cs = declare cs (base (hint (level_var site.site_scope l).expr)) in
                ( reads
                  @ [ P.Bump (c.cursor, -1)
                    ; P.Const (x, Some c.cty, P.Cell_read (P.Var c.array, c.cursor))
                    ]
                , (l, x) :: slot_vars
                , cs ))
          in
          let n = List.length site.site_scope.vars in
          let remapped =
            List.mapi site.site_scope.vars ~f:(fun j (v : var) ->
              match List.Assoc.find slot_vars ~equal:Int.equal (n - j) with
              | Some x -> { v with expr = P.Var x }
              | None -> v)
          in
          let at k chain sc =
            { site.site_scope with
              vars = suffix k remapped
            ; block = sc.block
            ; avoid = sc.avoid
            ; machine = Some { resumer with chain; owner = site.site_owner }
            }
          in
          let sc1 = at n site.site_steps cs in
          let incoming, sc1, wrap =
            if not uniform
            then (
              let x, sc1 = declare sc1 site.site_binder.id in
              let c = result_column site.site_callee in
              P.Var x, sc1, fun rest -> prelude [ x, `Pop c ] (reads @ rest))
            else if
              Ts_anf.delays
                env
                site.site_body
                ~arities:(0 :: List.map sc1.vars ~f:(fun v -> v.arity))
            then (
              let x, sc1 = declare sc1 site.site_binder.id in
              P.Var x, sc1, fun rest -> reads @ (P.Const (x, None, P.Var returned) :: rest))
            else P.Var returned, sc1, fun rest -> reads @ rest
          in
          let sc1 =
            { sc1 with vars = value_var incoming site.site_binder.ty :: sc1.vars }
          in
          let rec continue_with sc v = function
            | [] -> deliver sc site.site_owner (fun sc sink -> run sc v sink)
            | _ when always_leaves v -> run sc v Return
            | st :: rest ->
              let sc' = at (List.length st.let_scope.vars) rest sc in
              let v' = let_in sc' v st.let_binder st.let_body st.let_type in
              continue_with sc' v' rest
          in
          wrap (continue_with sc1 (translate sc1 site.site_body) site.site_steps)
        in
        let rec resume_all k acc =
          match List.nth frames.sites k with
          | Some site -> resume_all (k + 1) (acc @ [ resume site ])
          | None -> acc
        in
        let cases = if framed then resume_all 0 [] else [] in
        let same =
          List.mapi cases ~f:(fun k c ->
            Option.value_map
              (List.findi cases ~f:(fun _ c' -> [%equal: P.stmt list] c' c))
              ~default:k
              ~f:fst)
        in
        let distinct = List.dedup_and_sort same ~compare:Int.compare in
        let renumber k =
          fst (List.findi_exn distinct ~f:(fun _ -> Int.equal (List.nth_exn same k)))
        in
        let several =
          match distinct with
          | _ :: _ :: _ -> true
          | _ -> false
        in
        let frame_column =
          if uniform && framed && not several
          then
            List.find frames.columns ~f:(fun c ->
              List.for_all frames.sites ~f:(fun site ->
                List.count site.slots ~f:(fun (_, c') -> phys_equal c c') = 1))
          else None
        in
        let kinds_array =
          if several then fst (declare scope_r (base "frames")) else kinds
        in
        let kinds_of =
          map_stmts (function
            | P.Cell_write (a, _, _) when (not several) && String.equal a kinds -> []
            | P.Bump (x, _) when Option.is_some frame_column && String.equal x depth -> []
            | P.Cell_write (a, i, P.Number k) when String.equal a kinds ->
              [ P.Cell_write
                  (kinds_array, i, P.Number (Int.to_string (renumber (Int.of_string k))))
              ]
            | s -> [ s ])
        in
        let cases = List.map (List.map distinct ~f:(List.nth_exn cases)) ~f:kinds_of in
        let bodies = List.map bodies ~f:kinds_of in
        let assigns x stmts =
          let found = ref false in
          ignore
            (map_stmts
               (function
                 | P.Assign (y, _) as s when String.equal x y ->
                   found := true;
                   [ s ]
                 | s -> [ s ])
               stmts
             : P.stmt list);
          !found
        in
        let leaving = List.exists cases ~f:(assigns resuming) in
        let valued = List.exists cases ~f:(fun c -> not (ends c)) in
        let cases =
          if valued
          then cases
          else
            List.map
              cases
              ~f:
                (map_stmts (function
                   | P.Assign (x, _) when String.equal x resuming -> []
                   | s -> [ s ]))
        in
        (* A [switch] of one case per kind, the last the default, each ending
           in a [break] when it may finish, since a chain of [if]s whose
           branches end alike fails branches-sharing-code. *)
        let switch d branches =
          match branches with
          | [ b ] -> b
          | _ ->
            let last = List.length branches - 1 in
            [ P.Switch
                ( d
                , List.mapi branches ~f:(fun j b ->
                    if j = last
                    then { P.label = None; body = b }
                    else
                      { P.label = Some (P.Number (Int.to_string j))
                      ; body = (if ends b then b else b @ [ P.Break ])
                      }) )
            ]
        in
        let unwind_stmts () =
          let finish =
            if uniform
            then [ P.Return (P.Var returned) ]
            else (
              let c = result_column r.entry in
              [ P.Bump (c.cursor, -1); P.Return (P.Cell_read (P.Var c.array, c.cursor)) ])
          in
          let cursor =
            match frame_column with
            | Some c -> c.cursor
            | None -> depth
          in
          [ P.If (P.Equals (P.Var cursor, P.Number "0"), finish, []) ]
          @ (if Option.is_none frame_column then [ P.Bump (depth, -1) ] else [])
          @ switch (P.Cell_read (P.Var kinds_array, depth)) cases
        in
        let unwind_stmts =
          if not framed
          then []
          else if not valued
          then unwind_stmts ()
          else if leaving
          then
            [ P.Variable (resuming, P.Code "true"); P.While (resuming, unwind_stmts ()) ]
          else [ P.Loop (unwind_stmts ()) ]
        in
        let accumulation =
          if uniform && P.equal_ty (ty scope result) (P.Name ("bigint", []))
          then additive_frames scope_r frames cases bodies
          else None
        in
        let bodies, unwind_stmts =
          match accumulation with
          | Some (_, bodies, unwind_stmts) -> bodies, unwind_stmts
          | None -> bodies, unwind_stmts
        in
        let registers =
          List.filter_map regs ~f:(function
            | Register x -> Some x
            | Parameter | Pushed _ | Dropped -> None)
        in
        let pruned, unread =
          prune_storage (unwind_stmts :: bodies) ~registers ~locals:!(machine.locals)
        in
        let unwind_stmts = List.hd_exn pruned in
        let bodies = List.tl_exn pruned in
        let everything = List.concat bodies @ unwind_stmts in
        let assigned x = assigns x everything in
        let dispatch_members =
          match which with
          | Some w when assigned w -> switch (P.Var w) bodies
          | Some _ | None -> List.nth_exn bodies r.entry
        in
        let storage =
          match accumulation with
          | Some (storage, _, _) -> storage
          | None ->
            List.concat_map frames.columns ~f:(fun c ->
              [ P.Const (c.array, Some (cell_array_of c.cty), P.Tuple [])
              ; P.Variable (c.cursor, P.Number "0")
              ])
            @ (if several
               then
                 [ P.Const
                     ( kinds_array
                     , Some (cell_array_of (P.Name ("number", [])))
                     , P.Tuple [] )
                 ]
               else [])
            @
            if framed && Option.is_none frame_column
            then [ P.Variable (depth, P.Number "0") ]
            else []
        in
        let registers =
          List.filter_mapi regs ~f:(fun p r ->
            match r with
            | Register x when List.mem unread x ~equal:String.equal -> None
            | Register x when assigned x -> Some (P.Variable (x, P.Var (param_name p)))
            | Register x -> Some (P.Const (x, None, P.Var (param_name p)))
            | Parameter | Pushed _ | Dropped -> None)
        in
        let which_decl =
          match which with
          | Some w when assigned w -> [ P.Variable (w, P.Number (Int.to_string r.entry)) ]
          | Some _ | None -> []
        in
        let result_declaration, dispatch_members =
          let declaration =
            if framed && uniform then [ P.Let (returned, ty scope result) ] else []
          in
          match accumulation, List.rev dispatch_members with
          | Some _, P.Assign (x, e) :: rest
            when String.equal x returned
                 && (not (List.mem (fst (writes rest)) x ~equal:String.equal))
                 && not (List.mem (names_read rest) x ~equal:String.equal) ->
            [], List.rev rest @ [ P.Const (x, Some (ty scope result), e) ]
          | _ -> declaration, dispatch_members
        in
        let loop_body =
          if framed
          then result_declaration @ dispatch_members @ unwind_stmts
          else (
            match List.rev dispatch_members with
            | P.Continue :: rest -> List.rev rest
            | _ -> dispatch_members)
        in
        let loop = P.Loop loop_body in
        let stmts = storage @ registers @ which_decl @ [ loop ] in
        Some (P.Block stmts)
      with
      | Unsupported ->
        undo ();
        None
    in
    let pair =
      uniform
      &&
      match lambdas with
      | [ _; _ ] -> true
      | _ -> false
    in
    match attempt ~inline:pair with
    | None when pair -> attempt ~inline:false
    | body -> body)
;;

let function_body scope e = arrow_body (run scope (translate scope e) Return)

type zero_case =
  | Zero_first
  | Zero_last
  | Zero_default

type unary_order =
  { shape : Ts_repr.unary
  ; representation : Ts_repr.t
  ; input : I.ty
  ; result : I.ty
  ; on_left_zero : Miniml.global
  ; on_right_zero : Miniml.global
  ; right_zero_case : zero_case
  ; right_successor_id : Miniml.ml_ident
  }

let unary_order env ~self = function
  | I.Lambda ([], [ left; right ], result, I.Match outer)
    when List.is_empty (Ts_env.term env self).schema.tparams
         && T.equal left.ty right.ty
         && Poly.equal outer.scrutinee (I.Local (2, [])) ->
    (match left.ty with
     | T.Glob (ind, []) when is_global ind outer.ind && List.is_empty outer.tyargs ->
       let { Ts_env.repr; unary; nparams; _ } = Ts_env.ind env ind in
       let open Option.Let_syntax in
       let%bind shape = unary in
       let terminal = function
         | I.Construct (c, [], []) when not (Table.is_custom c) ->
           let ctor = Ts_env.ctor env c in
           (match (Ts_env.ind env ctor.ind).repr with
            | Ts_repr.Tagged _
              when List.is_empty ctor.args
                   && List.is_empty ctor.lifted
                   && T.equal result (T.Glob (ctor.ind, [])) -> Some c
            | _ -> None)
         | _ -> None
       in
       let branches (m : I.match_) =
         let zero (br : I.branch) ~default =
           List.is_empty br.binders
           &&
           match br.pattern with
           | I.Ctor (c, []) -> is_global c shape.zero
           | I.Default { binds_scrutinee = false } -> default
           | I.Ctor (_, _ :: _) | I.Default { binds_scrutinee = true } -> false
         in
         let successor (br : I.branch) =
           match br.pattern, br.binders with
           | I.Ctor (c, [ Some predecessor ]), [ binder ]
             when is_global c shape.successor
                  && predecessor = 1
                  && T.equal binder.ty left.ty -> Some binder.id
           | _ -> None
         in
         match m.branches with
         | [ a; b ] when zero a ~default:false ->
           Option.map (successor b) ~f:(fun id -> a, b, id, Zero_first)
         | [ a; b ] when zero b ~default:true ->
           let zero_case =
             match b.pattern with
             | I.Default _ -> Zero_default
             | I.Ctor _ -> Zero_last
           in
           Option.map (successor a) ~f:(fun id -> b, a, id, zero_case)
         | _ -> None
       in
       if nparams <> 0 || not (T.equal outer.result result)
       then None
       else (
         let%bind left_zero, left_successor, _, _ = branches outer in
         let%bind on_left_zero = terminal left_zero.body in
         match left_successor.body with
         | I.Match inner
           when is_global ind inner.ind
                && List.is_empty inner.tyargs
                && Poly.equal
                     inner.scrutinee
                     (I.Local (1 + List.length left_successor.binders, []))
                && T.equal inner.result result ->
           let%bind right_zero, right_successor, right_successor_id, right_zero_case =
             branches inner
           in
           let%bind on_right_zero = terminal right_zero.body in
           (match right_successor.body with
            | I.Apply (I.Global (callee, []), [ a; b ])
              when is_global self callee
                   && Poly.equal
                        a.expr
                        (I.Local (1 + List.length right_successor.binders, []))
                   && Poly.equal b.expr (I.Local (1, [])) ->
              Some
                { shape
                ; representation = repr
                ; input = left.ty
                ; result
                ; on_left_zero
                ; on_right_zero
                ; right_zero_case
                ; right_successor_id
                }
            | _ -> None)
         | _ -> None)
     | _ -> None)
  | _ -> None
;;

let unary_input env order = (Ts_env.ctor env order.shape.zero).ind

let cancel_unary_successor env ~orders = function
  | I.Lambda
      ( []
      , [ left; right ]
      , result
      , I.Apply
          ( I.Global (callee, [])
          , [ { expr = I.Construct (successor, [], [ I.Local (2, []) ]); _ }
            ; { expr = I.Local (1, []); _ }
            ] ) ) ->
    let open Option.Let_syntax in
    let%bind order = Table.Refmap'.find_opt callee orders in
    let term = Ts_env.term env callee in
    let input_ind = unary_input env order in
    let result_ind = (Ts_env.ctor env order.on_right_zero).ind in
    if
      Table.is_custom callee
      || term.arity <> 2
      || (not (List.is_empty term.schema.tparams))
      || (not (T.equal left.ty order.input && T.equal right.ty order.input))
      || (not (T.equal result (T.Glob (result_ind, []))))
      || not (is_global successor order.shape.successor)
    then None
    else
      let open Miniml in
      let zero_pattern =
        match order.right_zero_case with
        | Zero_default -> Pwild
        | Zero_first | Zero_last -> Pusual order.shape.zero
      in
      let zero_branch =
        [], zero_pattern, MLcons (Tglob (result_ind, []), order.on_right_zero, [])
      in
      let successor_branch =
        ( [ order.right_successor_id ]
        , Pusual order.shape.successor
        , MLapp (MLglob callee, [ MLrel 3; MLrel 1 ]) )
      in
      let branches =
        match order.right_zero_case with
        | Zero_first -> [| zero_branch; successor_branch |]
        | Zero_last | Zero_default -> [| successor_branch; zero_branch |]
      in
      Some
        (MLlam
           (left.id, MLlam (right.id, MLcase (Tglob (input_ind, []), MLrel 1, branches))))
  | _ -> None
;;

let cached_unary_order scope order fallback =
  let input = ty scope order.input in
  let value = P.Var "__unaryValue" in
  let successor = order.shape.successor in
  let index = ctor_index scope successor in
  let child =
    P.Arrow
      ( []
      , [ "__unaryValue", input ]
      , Some (P.Union [ input; P.Name ("undefined", []) ])
      , P.Expr
          (P.Cond
             ( P.Equals
                 ( Ts_repr.discriminant order.representation value
                 , Ts_repr.label scope.names order.representation successor ~index )
             , Ts_repr.field order.representation ~index value 0
             , erased )) )
  in
  P.Call
    ( P.Helper P.Unary_order
    , [ input; ty scope order.result ]
    , Ts_repr.unary_descriptor scope.names order.shape
      @ [ child
        ; Ts_names.value scope.names order.on_left_zero
        ; Ts_names.value scope.names order.on_right_zero
        ; fallback
        ] )
;;

let func scope ~tparams ~self ~fix e =
  let order =
    if List.is_empty tparams && List.length fix <= 1 && Table.Refmap'.is_empty scope.group
    then
      Option.bind (unary_order scope.env ~self e) ~f:(fun order ->
        let ind = (Ts_env.ctor scope.env order.shape.zero).ind in
        Option.some_if (Ts_env.ind scope.env ind).optimise_unary order)
    else None
  in
  match e with
  | I.Lambda (vs, bs, result, body) ->
    let params, scope' = binds scope bs in
    let generics r = List.length (Ts_env.term scope.env r).schema.tparams in
    let member r = function
      | I.Lambda (_, bs, result, body) when generics r = generics self ->
        Some
          ( { Ts_anf.head = Ts_anf.Global r
            ; arity = List.length bs
            ; result
            ; accepts = own_tparams
            }
          , (bs, result, body) )
      | _ -> None
    in
    let members = List.map fix ~f:(fun (r, e) -> member r e) in
    let members, entry =
      match Option.all members, List.findi fix ~f:(fun _ (r, _) -> is_global self r) with
      | Some members, Some (entry, _) -> members, entry
      | None, _ | Some _, None ->
        Option.to_list (member self (I.Lambda (vs, bs, result, body))), 0
    in
    let recursive =
      { itself = Top self
      ; heads = List.map members ~f:fst
      ; lambdas = List.map members ~f:snd
      ; entry
      }
    in
    let body =
      named_body scope' ~recursive:(Some recursive) bs params body ~plain:function_body
    in
    let fallback =
      named_arrow scope' tparams (List.filter_opt params) (Some (ty scope result)) body
    in
    (match order with
     | Some order ->
       ( Some (P.Fn { tparams; params = List.filter_opt params; result = ty scope result })
       , cached_unary_order scope order fallback )
     | None -> None, fallback)
  | _ ->
    CErrors.anomaly (Pp.str "Ts_expr.func: the body of a function is a lambda chain.")
;;

let constant scope ~tparams ~result e =
  P.Arrow (tparams, [], Some result, function_body scope e)
;;

let toplevel scope e =
  let scope = { scope with block = block ~top:true scope.avoid } in
  let stmts, e = settled scope (translate scope e) in
  lift_statements scope stmts;
  e
;;
