open Import
open Names
open Extraction_plugin
open Miniml
module P = Ts_print

module Refset = struct
  include Table.Refset'

  let of_list rs = List.fold rs ~init:empty ~f:(fun set r -> add r set)
end

let keywords = Ts_names.keywords
let file_suffix = ".ts"

type stats = { unchecked_casts : int }

type result =
  | Own of ModPath.t * global list
  | Typed of ModPath.t * global list

type functor_info =
  { params : (MBId.t * ml_module_type) list
  ; bound : (ModPath.t * ModPath.t) list
  ; tparams : global list
  ; result : result
  }

type where =
  { globals : Refset.t
  ; modules : ModPath.t list
  ; owner : string option
  ; api : bool
  ; sigs : Ts_sig.t
  ; interfaces : (ModPath.t, global list) Hashtbl.t
  ; functors : (ModPath.t, functor_info) Hashtbl.t
  ; applied : (ModPath.t, (ModPath.t * ModPath.t) list) Hashtbl.t
  ; objects : (ModPath.t, P.expr * P.ty) Hashtbl.t
  ; lambdas : (P.ty, string) Hashtbl.t
  ; pending : (string * P.type_decl) list ref
  }

let top_level sigs (globals, modules) =
  { globals = Refset.of_list globals
  ; modules
  ; owner = None
  ; api = false
  ; sigs
  ; interfaces = Hashtbl.create (module Ts_modpath_key) ~size:8
  ; functors = Hashtbl.create (module Ts_modpath_key) ~size:8
  ; applied = Hashtbl.create (module Ts_modpath_key) ~size:8
  ; objects = Hashtbl.create (module Ts_modpath_key) ~size:8
  ; lambdas = Hashtbl.create (module P.Ty_key) ~size:8
  ; pending = ref []
  }
;;

let asked_value where r = Option.is_none where.owner && Refset.mem r where.globals
let asked_type where r = where.api || Refset.mem r where.globals
let asked_member where r = where.api || Refset.mem r where.globals

let asked_module where mp =
  List.exists where.modules ~f:(ModPath.subpath mp)
  || Refset.exists (fun r -> ModPath.subpath mp (Table.modpath_of_r r)) where.globals
;;

let asked_exactly where mp = where.api || List.exists where.modules ~f:(ModPath.equal mp)

let within where mp ~owner =
  { where with
    owner = Some (Option.value where.owner ~default:owner)
  ; api = asked_exactly where mp
  }
;;

type binding =
  { member : string
  ; key : string
  ; value : P.value
  ; root : bool
  ; demanded : bool
  }

let module_binding where mp name value =
  { member = name
  ; key = name
  ; value
  ; root = Option.is_none where.owner && asked_module where mp
  ; demanded = true
  }
;;

let binding names r value ~root ~demanded =
  { member = Ts_names.member_name names r
  ; key = Ts_names.group_key names r
  ; value
  ; root
  ; demanded
  }
;;

type item =
  | Type of
      { name : string
      ; decl : P.type_decl
      ; builders : string list
      ; root : bool
      }
  | Value of binding
  | Lifted of P.value
  | Group of
      { holder : P.value
      ; members : binding list
      }
  | Module of
      { name : string
      ; root : bool
      ; body : body
      }
  | Nested of
      { name : string
      ; flat : string
      ; body : body
      }
  | Application of
      { binding : binding
      ; functor_ : P.expr
      ; tyargs : P.ty list
      ; ty : P.ty
      ; result : result
      }

and body =
  | Items of item list
  | Alias of P.expr

let concat placed =
  ( List.concat_map placed ~f:fst
  , List.fold placed ~init:0 ~f:(fun n (_, casts) -> n + casts) )
;;

let declared = function
  | Dind ind -> List.map (Array.to_list ind.ind_packets) ~f:(fun p -> p.ip_typename_ref)
  | Dtype (r, _, _) | Dterm (r, _, _) -> [ r ]
  | Dfix (rv, _, _) -> Array.to_list rv
;;

let rec bindings items =
  List.concat_map items ~f:(function
    | Type _ | Lifted _ -> []
    | Value b | Application { binding = b; _ } -> [ b ]
    | Group { members; _ } -> members
    | Module { body = Items items; _ } | Nested { body = Items items; _ } ->
      bindings items
    | Module { body = Alias _; _ } | Nested { body = Alias _; _ } -> [])
;;

let definition env names ~group ?inferred ?(fix = []) r body t =
  let { Ts_env.schema; arity } = Ts_env.term env r in
  let n = List.length schema.tparams in
  if Table.is_custom r
  then (
    let ty =
      if arity > 0
      then
        Ts_names.function_type
          names
          (Ts_names.signature names schema.tparams)
          schema.ty
          ~arity
      else Ts_names.ty names Ts_names.erased (Ts_type.of_ml t)
    in
    Some ty, P.Code (Ts_names.custom r), [], 0)
  else (
    let typed, ty, stats =
      match inferred with
      | Some inferred -> inferred
      | None -> Ts_infer.declaration env r body
    in
    let tvars, tparams =
      if arity > 0 || n > 0
      then Ts_names.signature names schema.tparams
      else Ts_names.erased, []
    in
    let scope =
      Ts_expr.in_group
        (Ts_expr.scope
           env
           names
           tvars
           ~name:(Ts_names.value_name names r)
           ~defining:(r :: List.map group ~f:fst))
        group
    in
    let ty, value =
      if arity > 0
      then Ts_expr.func scope ~tparams ~self:r ~fix typed
      else if n > 0
      then None, Ts_expr.constant scope ~tparams ~result:(Ts_expr.ty scope ty) typed
      else Some (Ts_expr.ty scope ty), Ts_expr.toplevel scope typed
    in
    ty, value, Ts_expr.lifted scope, stats.reconstruction_casts)
;;

let term env names where r body t =
  if Table.is_inline_custom r
  then [], 0
  else (
    let ty, value, lifted, casts = definition env names ~group:[] r body t in
    ( List.map lifted ~f:(fun v -> Lifted v)
      @ [ Value
            (binding
               names
               r
               { P.name = Ts_names.value_name names r; ty; value }
               ~root:(asked_value where r)
               ~demanded:(asked_member where r))
        ]
    , casts ))
;;

let group env names where name members =
  let key r = Ts_names.group_key names r in
  let reach = List.map members ~f:(fun (r, _, _) -> r, P.Field (P.Var name, key r)) in
  let inferred =
    List.map members ~f:(fun (r, body, _) ->
      if Table.is_custom r then None else Some (Ts_infer.declaration env r body))
  in
  let fix =
    match Option.all inferred with
    | None -> []
    | Some inferred ->
      List.map2_exn members inferred ~f:(fun (r, _, _) (typed, _, _) -> r, typed)
  in
  let defined =
    List.map2_exn members inferred ~f:(fun (r, body, t) inferred ->
      let _, value, lifted, casts =
        definition env names ~group:reach ?inferred ~fix r body t
      in
      r, value, lifted, casts)
  in
  let member (r, value, _, _) =
    binding
      names
      r
      { P.name = Ts_names.value_name names r; ty = None; value }
      ~root:(asked_value where r)
      ~demanded:(asked_member where r)
  in
  ( List.concat_map defined ~f:(fun (_, _, lifted, _) ->
      List.map lifted ~f:(fun v -> Lifted v))
    @ [ Group
          { holder =
              { P.name
              ; ty = None
              ; value = P.Record (List.map defined ~f:(fun (r, v, _, _) -> key r, v))
              }
          ; members = List.map defined ~f:member
          }
      ]
  , List.fold defined ~init:0 ~f:(fun n (_, _, _, c) -> n + c) )
;;

let type_decl_name = function
  | P.Alias { name; _ }
  | P.Interface { name; _ }
  | P.Lambda { name; _ }
  | P.Kind { name; _ } -> name
;;

let inductive_packet env names where ind i (p : ml_ind_packet) =
  if p.ip_logical
  then []
  else (
    let { Ts_env.repr; optimise_unary; _ } = Ts_env.ind env p.ip_typename_ref in
    let d =
      Ts_repr.declare
        ~freeze:optimise_unary
        ~signature:(Ts_env.signature env)
        ~fields:(Ts_env.fields env)
        names
        ind
        i
        repr
    in
    let root = asked_type where p.ip_typename_ref in
    let demanded =
      match repr with
      | Ts_repr.Custom _ -> root
      | Ts_repr.Tagged _ | Ts_repr.Record _ | Ts_repr.Lazy _ | Ts_repr.Erased -> true
    in
    let values =
      List.map d.values ~f:(fun (c, value) ->
        Value
          (binding
             names
             c
             value
             ~root:(asked_value where p.ip_typename_ref || asked_value where c)
             ~demanded))
    in
    let builders =
      match where.owner, d.values with
      | _, [] -> []
      | Some owner, _ -> [ owner ]
      | None, values -> List.map values ~f:(fun (_, (v : P.value)) -> v.name)
    in
    let rec types = function
      | [] -> []
      | [ decl ] -> [ Type { name = type_decl_name decl; decl; builders; root } ]
      | decl :: rest ->
        Type { name = type_decl_name decl; decl; builders = []; root } :: types rest
    in
    types d.types @ values)
;;

let parray_interface names where r =
  let name = Ts_names.type_name names r in
  let tvars = Ts_names.named names [ Ts_primitives.parameter ] in
  let element = Ts_names.ty names tvars (Ts_type.Var 1) in
  Type
    { name
    ; decl =
        P.Interface
          { name
          ; tparams = P.unbounded (Ts_names.tparams tvars)
          ; fields =
              [ "default", element
              ; "items", P.Raw [ P.Verbatim "readonly "; P.Hole element; P.Verbatim "[]" ]
              ]
          }
    ; builders = []
    ; root = asked_type where r
    }
;;

(* No value has a [unique symbol] type, so a consumer cannot forge one,
   and a function from the parameters to themselves keeps every
   parameter invariant, so two instances stay apart. *)
let brand tparams =
  let variance t =
    [ "variance", P.Fn { tparams = []; params = [ "_", t ]; result = t } ]
  in
  ("brand", P.Name ("unique symbol", []))
  ::
  (match List.map tparams ~f:(fun p -> P.Name (p, [])) with
   | [] -> []
   | [ t ] -> variance t
   | ts -> variance (P.Tuple ts))
;;

let type_alias env names where r vl t =
  let name = Ts_names.type_name names r in
  let decl =
    match Ts_env.alias env r with
    | Some (a : Ts_type.schema) when not (Table.is_custom r) ->
      let hinted =
        List.mapi a.tparams ~f:(fun i (p : Ts_type.tparam) ->
          match List.nth vl i with
          | Some id -> { p with hint = Some id }
          | None -> p)
      in
      let tvars, tparams = Ts_names.signature names hinted in
      P.Alias
        { name
        ; tparams = tparams @ P.unbounded (Ts_names.implicit_params names r)
        ; def = Ts_names.ty names tvars a.ty
        }
    | Some _ | None ->
      if Table.is_custom r
      then (
        let tparams, def = Table.find_type_custom r in
        P.Alias
          { name
          ; tparams = P.unbounded tparams
          ; def = P.Raw [ P.Verbatim (Ts_names.qualify_code names r ~params:tparams def) ]
          })
      else (
        let tvars = Ts_names.named names vl in
        let tparams = Ts_names.tparams tvars @ Ts_names.implicit_params names r in
        if phys_equal t Taxiom
        then P.Interface { name; tparams = P.unbounded tparams; fields = brand tparams }
        else
          P.Alias
            { name
            ; tparams = P.unbounded tparams
            ; def = Ts_names.ty names tvars (Ts_type.of_ml t)
            })
  in
  Type { name; decl; builders = []; root = asked_type where r }
;;

let fixpoints env names where rv av tv =
  let members = Ts_names.group_members rv av in
  let name =
    match members with
    | first :: _ :: _ -> Ts_names.group_name names first
    | [] | [ _ ] -> None
  in
  let grouped i = Option.is_some name && List.mem members rv.(i) ~equal:phys_equal in
  let alone =
    Array.to_list
      (Array.mapi rv ~f:(fun i r ->
         match av.(i) with
         | _ when grouped i -> [], 0
         | MLexn "UNUSED" when not (Table.is_custom r) -> [], 0
         | body -> term env names where r body tv.(i)))
  in
  match name with
  | None -> concat alone
  | Some name ->
    let indices = List.filter (List.init (Array.length rv) ~f:Fn.id) ~f:grouped in
    let member i = rv.(i), av.(i), tv.(i) in
    concat (alone @ [ group env names where name (List.map indices ~f:member) ])
;;

let typed (r : global) f =
  match f () with
  | declared -> declared
  | exception Ts_type.Lost ->
    CErrors.user_err
      Pp.(
        str "TypeScript extraction cannot type "
        ++ GlobRef.print r.glob
        ++ str
             ": extraction lost a type in it that the kernel does not give, and \
              TypeScript has no type for it without unknown.")
;;

let lower_decl env names where = function
  | Dind ind ->
    let packets = Array.to_list ind.ind_packets in
    List.concat_mapi packets ~f:(inductive_packet env names where ind), 0
  | Dtype (r, _, _)
    when Table.is_inline_custom r || Option.is_some (Ts_primitives.builtin r) -> [], 0
  | Dtype (r, _, _)
    when [%equal: Ts_primitives.t option]
           (Ts_primitives.owned r)
           (Some Ts_primitives.Parray) -> [ parray_interface names where r ], 0
  | Dtype (r, _, Tunknown) when Option.is_none (Ts_env.alias env r) -> [], 0
  | Dtype (r, vl, t) -> [ type_alias env names where r vl t ], 0
  | Dterm (_, _, t) when Option.is_some where.owner && Ts_type.is_erased (Ts_type.of_ml t)
    -> [], 0
  | Dterm (r, body, t) -> term env names where r body t
  | Dfix (rv, av, tv) -> fixpoints env names where rv av tv
;;

let lower env names where d =
  typed (List.hd_exn (declared d)) (fun () -> lower_decl env names where d)
;;

let alias_types names where mp =
  List.map (Ts_names.alias_types names mp) ~f:(fun (a : Ts_names.aliased) ->
    let tvars = Ts_names.named names a.params in
    let args = List.mapi a.params ~f:(fun i _ -> Ts_type.Var (i + 1)) in
    Type
      { name = a.name
      ; decl =
          P.Alias
            { name = a.name
            ; tparams = P.unbounded (Ts_names.tparams tvars)
            ; def = Ts_names.ty names tvars (Ts_type.Glob (a.declared, args))
            }
      ; builders = []
      ; root = asked_type where a.under
      })
;;

let module_ names where mp name body =
  match where.owner with
  | None -> Module { name; root = asked_module where mp; body }
  | Some _ -> Nested { name; flat = Ts_names.flat_name names mp; body }
;;

let mentioned params d =
  let roots = List.map (snd (P.reads d)) ~f:fst in
  List.filter params ~f:(fun (_, n) -> List.mem roots n ~equal:String.equal)
;;

let type_args params = List.map params ~f:(fun (_, n) -> P.Name (n, []))

let abstracts_of_parameters sigs names params =
  let abstracts =
    List.map params ~f:(fun (id, mt) ->
      let at = ModPath.MPbound id in
      at, mt, Ts_sig.parameter_abstracts sigs ~at mt)
  in
  ( abstracts
  , Ts_names.type_params names (List.concat_map abstracts ~f:(fun (_, _, a) -> a)) )
;;

let fields_interface params name fields =
  match fields with
  | [] ->
    ( P.Alias
        { name
        ; tparams = []
        ; def = P.Name ("Record", [ P.Name ("never", []); P.Name ("never", []) ])
        }
    , [] )
  | fields ->
    let decl = P.Interface { name; tparams = []; fields } in
    let kept = mentioned params (P.Type decl) in
    P.Interface { name; tparams = P.unbounded (List.map kept ~f:snd); fields }, kept
;;

let member_type member (v : P.value) =
  let rec arrow = function
    | P.Arrow (tparams, params, Some result, _) -> P.Fn { tparams; params; result }
    | P.Arrow (tparams, params, None, P.Expr inner) ->
      P.Fn { tparams; params; result = arrow inner }
    | _ ->
      CErrors.anomaly
        Pp.(
          str "Typescript.member_type: the member " ++ str member ++ str " has no type.")
  in
  match v.ty with
  | Some t -> t
  | None -> arrow v.value
;;

let take_lambdas where =
  let pending = !(where.pending) in
  where.pending := [];
  List.map pending ~f:(fun (name, decl) ->
    Type { name; decl; builders = []; root = false })
;;

let lambda names where ~base ~head def =
  let name =
    Hashtbl.find_or_add where.lambdas def ~default:(fun () ->
      let identifier n =
        (not (String.is_empty n))
        && String.for_all n ~f:(fun c -> Char.is_alphanum c || Char.equal c '_')
      in
      let head =
        match Option.bind head ~f:(Ts_names.type_name_opt names), def with
        | Some n, _ -> n
        | None, P.Name (n, _) ->
          let n = List.last_exn (String.split n ~on:'.') in
          if identifier n then n else ""
        | None, _ -> ""
      in
      let name = Ts_names.lambda_name names (head ^ "Lambda") in
      where.pending := !(where.pending) @ [ name, P.Lambda { name; base; def } ];
      name)
  in
  P.Name (name, [])
;;

let kind_argument env names where ~arity ~owner ?head subst =
  match subst (Tglob (owner, [])) with
  | Tglob (g, []) as t when Ts_names.is_abstract names g ->
    Ts_names.ty names Ts_names.erased (Ts_type.of_ml t)
  | t ->
    let args = List.init arity ~f:(fun i -> Tvar (i + 1)) in
    let head =
      Option.first_some
        head
        (match t with
         | Tglob (g, _) -> Some g
         | Tarr _ | Tvar _ | Tvar' _ | Tmeta _ | Tdummy _ | Tunknown | Taxiom -> None)
    in
    lambda
      names
      where
      ~base:(Ts_names.kind_ref names owner Ts_names.type_lambda)
      ~head
      (Ts_names.ty
         names
         (Ts_names.slots arity)
         (Ts_type.of_ml (subst (Tglob (owner, args)))))
;;

let kind_helpers = function
  | 0 -> []
  | arity ->
    let unknown = P.Name ("unknown", []) in
    let declared name decl = Type { name; decl; builders = []; root = false } in
    let tvars =
      List.filter
        (List.init 26 ~f:(fun i -> Char.to_string (Char.of_int_exn (Char.to_int 'A' + i))))
        ~f:(fun v -> String.( <> ) v "F")
    in
    declared
      Ts_names.type_lambda
      (P.Interface
         { name = Ts_names.type_lambda
         ; tparams = []
         ; fields =
             List.init arity ~f:(fun i -> Ts_names.kind_slot i, unknown)
             @ [ "type", unknown ]
         })
    :: List.init arity ~f:(fun i ->
      let name = Ts_names.kind_name (i + 1) in
      declared
        name
        (P.Kind
           { name
           ; base = Ts_names.type_lambda
           ; slots =
               List.init (i + 1) ~f:(fun j -> Ts_names.kind_slot j, List.nth_exn tvars j)
           }))
;;

let signature_type ?subst env names where ~at mt =
  let origin =
    match mt with
    | MTident mp when Hashtbl.mem where.interfaces mp -> mp
    | MTfunsig _ -> at
    | MTident _ | MTsig _ | MTwith _ -> Ts_sig.origin where.sigs mt
  in
  let params =
    match Hashtbl.find where.interfaces origin with
    | Some params -> params
    | None ->
      CErrors.anomaly
        (Pp.str "Typescript.signature_type: a module type used before it is placed.")
  in
  let subst = Option.value subst ~default:(Ts_sig.rebase_type ~from:origin ~to_:at) in
  P.Name
    ( Ts_names.signature_ref names origin
    , List.map params ~f:(fun g ->
        match Ts_sig.arity where.sigs g with
        | 0 ->
          Ts_names.ty
            names
            Ts_names.erased
            (Ts_type.of_ml (Ts_env.expand env (subst (Tglob (g, [])))))
        | arity -> kind_argument env names where ~arity ~owner:g subst) )
;;

let sealed_result ?subst env names where ~at sealed =
  let origin = Ts_sig.origin where.sigs sealed in
  ( signature_type ?subst env names where ~at sealed
  , Typed
      ( origin
      , List.map
          (Hashtbl.find_exn where.interfaces origin)
          ~f:(Ts_sig.rebase ~from:origin ~to_:at) ) )
;;

let signature_types env names where d =
  List.filter_map
    (fst (lower env names where d))
    ~f:(function
      | Type t -> Some (Type { t with builders = [] })
      | Value _ | Lifted _ | Group _ | Module _ | Nested _ | Application _ -> None)
;;

let rec interface env names where ~params ~name p members =
  let sigs = where.sigs in
  let pruned = Ts_sig.pruned sigs p in
  let listed r = (not pruned) || Ts_sig.used sigs r in
  let member (l, spec) =
    let at = ModPath.MPdot (p, l) in
    match spec with
    | Spec (Sval (r, _)) when not (listed r) -> [], []
    | Smodule _ when pruned && not (Ts_sig.used_under sigs at) -> [], []
    | Spec (Sval (r, _)) ->
      let { Ts_env.schema; arity } = Ts_env.term env r in
      let ((tvars, tparams) as signature) = Ts_names.signature names schema.tparams in
      let ty =
        typed r (fun () ->
          if arity > 0
          then Ts_names.function_type names signature schema.ty ~arity
          else if not (List.is_empty tparams)
          then P.Fn { tparams; params = []; result = Ts_names.ty names tvars schema.ty }
          else Ts_names.ty names tvars schema.ty)
      in
      [], [ Ts_names.member_name names r, ty ]
    | Spec (Sind ind) ->
      let fields =
        List.concat_mapi
          (Array.to_list ind.ind_packets)
          ~f:(fun i (packet : ml_ind_packet) ->
            if packet.ip_logical
            then []
            else (
              let repr = (Ts_env.ind env packet.ip_typename_ref).repr in
              List.filter_map
                (Ts_repr.declare
                   ~signature:(Ts_env.signature env)
                   ~fields:(Ts_env.fields env)
                   names
                   ind
                   i
                   repr)
                  .values
                ~f:(fun (c, v) ->
                  if listed c
                  then (
                    let member = Ts_names.member_name names c in
                    Some (member, member_type member v))
                  else None)))
      in
      signature_types env names where (Dind ind), fields
    | Spec (Stype (r, vl, Some t)) ->
      signature_types env names where (Dtype (r, vl, t)), []
    | Spec (Stype (_, _, None)) -> [], []
    | Smodule nested ->
      let items =
        match nested with
        | MTsig _ | MTfunsig _ -> signature ~outer:params env names where at nested
        | MTident _ | MTwith _ -> []
      in
      items, [ Ts_names.module_name names at, signature_type env names where ~at nested ]
    | Smodtype nested -> signature ~outer:params env names where at nested, []
  in
  let fields = List.map members ~f:member in
  let items = List.concat_map fields ~f:fst
  and fields = List.concat_map fields ~f:snd in
  let decl, kept = fields_interface params name fields in
  items, decl, kept

and signature ?(outer = []) env names where p mt =
  let sigs = where.sigs in
  let name = Ts_names.signature_name names p in
  let declared decl = Type { name; decl; builders = []; root = false } in
  let keep params decl =
    let kept = mentioned params (P.Type decl) in
    Hashtbl.set where.interfaces ~key:p ~data:(List.map kept ~f:fst);
    kept
  in
  match Ts_sig.functor_signature sigs mt, mt with
  | Some { parameters; result }, _ ->
    let abstracts, tparams = abstracts_of_parameters sigs names parameters in
    let parameters_of, results =
      Ts_sig.signature_abstracts sigs ~at:p { parameters; result }
    in
    let rtparams = Ts_names.type_params names results in
    let params = outer @ tparams in
    let names = Ts_names.in_scope names (params @ rtparams) in
    let inline = inline_parameters env names where ~outer:params abstracts in
    let applied =
      List.map parameters_of ~f:(fun (a : Ts_sig.abstract) -> Tglob (a.global, []))
    in
    let result_items, result_ty, result =
      signature_result env names where ~params ~results ~applied p result
    in
    let arrow kept =
      signature_arrow env names where ~result_ty (List.map kept ~f:snd) abstracts
    in
    let kept =
      mentioned tparams (P.Type (P.Alias { name; tparams = []; def = arrow tparams }))
    in
    let def = arrow kept in
    Hashtbl.set
      where.functors
      ~key:p
      ~data:{ params = parameters; bound = []; tparams = List.map kept ~f:fst; result };
    let decl = P.Alias { name; tparams = []; def } in
    let tparams = P.unbounded (List.map (keep (outer @ rtparams) decl) ~f:snd) in
    inline @ result_items @ [ declared (P.Alias { name; tparams; def }) ]
  | None, (MTident _ | MTwith _ | MTfunsig _ | MTsig _) ->
    let members = Ts_sig.resolve sigs ~at:p mt in
    let params =
      outer @ Ts_names.type_params names (Ts_sig.abstracts sigs ~at:p members)
    in
    let names = Ts_names.in_scope names params in
    (match mt with
     | MTident _ | MTwith _ | MTfunsig _ ->
       let def = signature_type env names where ~at:p mt in
       let decl = P.Alias { name; tparams = []; def } in
       let tparams = P.unbounded (List.map (keep params decl) ~f:snd) in
       [ declared (P.Alias { name; tparams; def }) ]
     | MTsig _ ->
       let items, decl, kept = interface env names where ~params ~name p members in
       Hashtbl.set where.interfaces ~key:p ~data:(List.map kept ~f:fst);
       items @ [ declared decl ])

and signature_result env names where ~params ~results ~applied p result =
  let left =
    Refset.of_list (List.map results ~f:(fun (a : Ts_sig.abstract) -> a.global))
  in
  match result with
  | MTsig _ as result ->
    let result_name = Ts_names.result_name names p in
    let result_params =
      List.map results ~f:(fun (a : Ts_sig.abstract) ->
        a.global, Ts_names.type_name names a.global)
    in
    let items, decl, kept =
      interface
        env
        names
        where
        ~params:(result_params @ params)
        ~name:result_name
        p
        (Ts_sig.resolve where.sigs ~at:p result)
    in
    let subst = function
      | Tglob (g, args) when Refset.mem g left -> Tglob (g, applied @ args)
      | t -> t
    in
    let tyarg g =
      Ts_names.ty
        names
        Ts_names.erased
        (Ts_type.of_ml (Ts_env.expand env (subst (Tglob (g, [])))))
    in
    ( items @ [ Type { name = result_name; decl; builders = []; root = false } ]
    , P.Name (result_name, List.map (List.map kept ~f:fst) ~f:tyarg)
    , Own (p, List.map kept ~f:fst) )
  | (MTident _ | MTwith _) as result ->
    let sigs = where.sigs in
    let origin = Ts_sig.origin sigs result in
    let subst t =
      match Ts_sig.rebase_type ~from:origin ~to_:p t with
      | Tglob (g, args) when Refset.mem g left -> Tglob (g, applied @ args)
      | t -> t
    in
    let ty, result = sealed_result ~subst env names where ~at:p result in
    [], ty, result
  | MTfunsig _ ->
    CErrors.anomaly (Pp.str "Typescript.signature: a functor signature has a result.")

(* A parameter is named apart from the type parameters, which
   no-redeclare asks. *)
and signature_arrow env names where ~result_ty tparams abstracts =
  let rec arrow avoid tparams' = function
    | [] -> result_ty
    | (at, mt, _) :: rest ->
      (match at with
       | ModPath.MPbound id ->
         let x, avoid = Ts_names.reserve avoid (Ts_names.pascal (MBId.to_id id)) in
         P.Fn
           { tparams = P.unbounded tparams'
           ; params = [ x, signature_type env names where ~at mt ]
           ; result = arrow avoid [] rest
           }
       | ModPath.MPfile _ | ModPath.MPdot _ ->
         CErrors.anomaly (Pp.str "Typescript.signature: a parameter is bound."))
  in
  arrow (Ts_names.apart tparams) tparams abstracts

and inline_parameters env names where ~outer abstracts =
  List.concat_map abstracts ~f:(fun (at, mt, _) ->
    match mt with
    | MTsig (p, _) when ModPath.equal p at -> signature ~outer env names where at mt
    | MTsig _ | MTident _ | MTwith _ | MTfunsig _ -> [])
;;

let bound_methods names (params : (ModPath.t * string) list) sel =
  let seen = ref Refset.empty
  and order = ref [] in
  let rec ast a =
    (match a with
     | MLglob r ->
       let mp = Table.modpath_of_r r in
       if
         List.exists params ~f:(fun (p, _) -> ModPath.subpath p mp)
         && Ts_names.is_method (Ts_names.member_name names r)
         && not (Refset.mem r !seen)
       then (
         seen := Refset.add r !seen;
         order := r :: !order)
     | MLrel _
     | MLapp _
     | MLlam _
     | MLletin _
     | MLcons _
     | MLtuple _
     | MLcase _
     | MLfix _
     | MLexn _
     | MLdummy _
     | MLaxiom _
     | MLmagic _
     | MLuint _
     | MLfloat _
     | MLstring _
     | MLparray _ -> ());
    Mlutil.ast_iter ast a
  in
  List.iter sel ~f:(fun (_, se) ->
    match se with
    | SEdecl (Dterm (r, a, _)) -> if not (Table.is_custom r) then ast a
    | SEdecl (Dfix (rv, av, _)) ->
      Array.iteri av ~f:(fun i a -> if not (Table.is_custom rv.(i)) then ast a)
    | SEdecl (Dind _ | Dtype _) | SEmodule _ | SEmodtype _ -> ());
  List.rev !order
;;

let rec body_values sel =
  List.concat_map sel ~f:(fun (_, se) ->
    match se with
    | SEdecl (Dterm (r, _, t)) ->
      if Table.is_inline_custom r || Ts_type.is_erased (Ts_type.of_ml t)
      then []
      else [ `Value r ]
    | SEdecl (Dfix (rv, av, _)) ->
      let members = Ts_names.group_members rv av in
      List.map members ~f:(fun r -> `Value r)
      @
        (match members with
        | first :: _ :: _ -> [ `Holder first ]
        | [] | [ _ ] -> [])
    | SEdecl (Dind ind) ->
      List.concat_map (Array.to_list ind.ind_packets) ~f:(fun (p : ml_ind_packet) ->
        if p.ip_logical || Table.is_custom p.ip_typename_ref
        then []
        else (
          match ind.ind_kind with
          | Standard | Coinductive ->
            List.map (Array.to_list p.ip_consnames_ref) ~f:(fun c -> `Value c)
          | Record _ | Singleton -> []))
    | SEmodule { ml_mod_expr = MEstruct (_, sel); _ } -> body_values sel
    | SEdecl (Dtype _)
    | SEmodule { ml_mod_expr = MEapply _ | MEident _ | MEfunctor _; _ }
    | SEmodtype _ -> [])
;;

type field =
  | Member of binding * P.ty
  | Submodule of
      { member : string
      ; local : string
      ; ty : P.ty
      ; fields : field list
      }
  | Aliased of
      { member : string
      ; value : P.expr
      ; ty : P.ty
      }

let rec sealed_object sigs names ~declared ~defined listed defined_as fields =
  let member declared defined =
    let member = Ts_names.member_name names defined in
    List.find_map fields ~f:(function
      | Member (b, _) when String.equal b.member member ->
        Some (Ts_names.member_name names declared, P.Var b.value.name)
      | Member _ | Submodule _ | Aliased _ -> None)
  in
  List.concat
    (List.map2_exn listed defined_as ~f:(fun (l, d) (_, b) ->
       match d, b with
       | Spec (Sval (d, _)), Spec (Sval (b, _)) -> Option.to_list (member d b)
       | Spec (Sind d), Spec (Sind b) ->
         List.concat
           (Array.to_list
              (Array.map2_exn
                 d.ind_packets
                 b.ind_packets
                 ~f:(fun (d : ml_ind_packet) (b : ml_ind_packet) ->
                   if d.ip_logical
                   then []
                   else
                     List.filter_map
                       (Array.to_list
                          (Array.zip_exn d.ip_consnames_ref b.ip_consnames_ref))
                       ~f:(fun (d, b) -> member d b))))
       | Smodule d, Smodule b ->
         let declared = ModPath.MPdot (declared, l)
         and defined = ModPath.MPdot (defined, l) in
         let name = Ts_names.module_name names defined in
         List.filter_map fields ~f:(function
           | Submodule { member; fields; _ } when String.equal member name ->
             Some
               ( Ts_names.module_name names declared
               , P.Record
                   (sealed_object
                      sigs
                      names
                      ~declared
                      ~defined
                      (Ts_sig.resolve sigs ~at:declared d)
                      (Ts_sig.resolve sigs ~at:defined b)
                      fields) )
           | Member (b, _) when String.equal b.member name ->
             Some (Ts_names.module_name names declared, P.Var b.value.name)
           | Aliased { member; value; _ } when String.equal member name ->
             Some (Ts_names.module_name names declared, value)
           | Submodule _ | Member _ | Aliased _ -> None)
       | Spec (Stype _ | Sval _ | Sind _), _ | Smodule _, _ | Smodtype _, _ -> []))
;;

let defines = function
  | P.Const (x, _, _) | P.Variable (x, _) -> [ x ]
  | P.Bind (fields, _) -> List.map fields ~f:snd
  | P.Let _
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
  | P.While _ -> []
;;

let needed_statements stmts returned =
  let reads e =
    List.map (fst (P.reads (P.Value { P.name = ""; ty = None; value = e }))) ~f:fst
  in
  let needed = reads returned in
  let uses = function
    | P.Const (_, _, e) | P.Bind (_, e) | P.Variable (_, e) | P.Eval e -> reads e
    | P.Let _
    | P.Assign _
    | P.Cell_write _
    | P.Bump _
    | P.Return _
    | P.Break
    | P.Continue
    | P.Switch _
    | P.If _
    | P.Loop _
    | P.While _ -> []
  in
  let rec close needed =
    let needed' =
      List.fold stmts ~init:needed ~f:(fun acc stmt ->
        if
          (match stmt with
           | P.Eval _ -> true
           | P.Const _
           | P.Bind _
           | P.Let _
           | P.Variable _
           | P.Assign _
           | P.Cell_write _
           | P.Bump _
           | P.Return _
           | P.Break
           | P.Continue
           | P.Switch _
           | P.If _
           | P.Loop _
           | P.While _ -> false)
          || List.exists (defines stmt) ~f:(Set.mem acc)
        then List.fold (uses stmt) ~init:acc ~f:Set.add
        else acc)
    in
    if Set.equal needed' needed then needed else close needed'
  in
  let needed = close (Set.of_list (module String) needed) in
  List.filter_map stmts ~f:(fun stmt ->
    match stmt with
    | P.Const (x, _, _) | P.Variable (x, _) ->
      if Set.mem needed x then Some stmt else None
    | P.Bind (fields, e) ->
      (match List.filter fields ~f:(fun (_, x) -> Set.mem needed x) with
       | [] -> None
       | fields -> Some (P.Bind (fields, e)))
    | P.Let _
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
    | P.While _ -> Some stmt)
;;

let result_type sigs names ~instance = function
  | Own (own, params) ->
    let name =
      match Ts_sig.functor_ sigs own with
      | Some _ -> Ts_names.signature_ref names own
      | None -> Ts_names.result_ref names own
    in
    P.Name (name, List.map params ~f:instance)
  | Typed (origin, args) ->
    P.Name (Ts_names.signature_ref names origin, List.map args ~f:instance)
;;

let rec application_parts = function
  | MEapply (f, MEident a) ->
    let head, args = application_parts f in
    head, args @ [ a ]
  | MEident f -> f, []
  | MEapply (_, (MEapply _ | MEfunctor _ | MEstruct _)) | MEfunctor _ | MEstruct _ ->
    CErrors.anomaly (Pp.str "Typescript.application: an argument is a module name.")
;;

let applied_functor where f args =
  let rec through mp =
    match Hashtbl.find where.applied mp, mp with
    | Some outer, _ -> outer
    | None, ModPath.MPdot (parent, _) -> through parent
    | None, (ModPath.MPfile _ | ModPath.MPbound _) -> []
  in
  let rec reached mp =
    match Ts_sig.step where.sigs mp with
    | Some (mp', (from, to_)) when not (Hashtbl.mem where.functors mp) ->
      let placed, reaching = reached mp' in
      placed, (to_, from) :: reaching
    | Some _ | None -> mp, []
  in
  let placed, reaching =
    match f with
    | ModPath.MPbound id ->
      (match Ts_sig.parameter where.sigs id with
       | Some mt -> Ts_sig.origin where.sigs mt, []
       | None -> f, [])
    | ModPath.MPfile _ | ModPath.MPdot _ -> reached f
  in
  let outer = through f @ reaching in
  let info =
    match Hashtbl.find where.functors placed with
    | Some info -> info
    | None ->
      CErrors.anomaly
        (Pp.str "Typescript.application: a functor applied before it is placed.")
  in
  let remaining = List.drop info.params (List.length info.bound) in
  if List.length args > List.length remaining
  then CErrors.anomaly (Pp.str "Typescript.application: more arguments than parameters.");
  let applied, rest = List.split_n remaining (List.length args) in
  info, outer, applied, rest
;;

let argument_object names ~at:mp a =
  match mp with
  | ModPath.MPdot (parent, _)
    when (not (Table.is_modfile parent))
         && ModPath.subpath parent a
         && Ts_names.same_file names a -> P.Var (Ts_names.flat_name names a)
  | ModPath.MPdot _ | ModPath.MPfile _ | ModPath.MPbound _ -> Ts_names.module_ref names a
;;

let instantiate_bindings pending args =
  let rec chase mp =
    match mp with
    | ModPath.MPbound _ ->
      (match List.Assoc.find args ~equal:Poly.equal mp with
       | Some mp' when not (ModPath.equal mp' mp) -> chase mp'
       | Some _ | None -> mp)
    | ModPath.MPfile _ | ModPath.MPdot _ -> mp
  in
  List.map pending ~f:(fun (from, to_) -> from, chase to_)
;;

let implemented env sigs ~params r args =
  let abstracts =
    List.concat_map params ~f:(fun (id, mt) ->
      Ts_sig.parameter_abstracts sigs ~at:(ModPath.MPbound id) mt)
  in
  let given, own = List.split_n args (List.length abstracts) in
  let replaced =
    List.fold2_exn
      (List.take abstracts (List.length given))
      given
      ~init:Table.Refmap'.empty
      ~f:(fun m (a : Ts_sig.abstract) t -> Table.Refmap'.add a.global t m)
  in
  let rec replace seen = function
    | Tglob (g, args) ->
      if Refset.mem g seen
      then Tglob (g, List.map args ~f:(replace seen))
      else (
        let seen = Refset.add g seen in
        let args = List.map args ~f:(replace seen) in
        match args, Table.Refmap'.find_opt g replaced with
        | [], Some t -> replace seen t
        | _ ->
          let extra =
            List.filter_map (Ts_sig.implicit sigs g) ~f:(fun i ->
              Option.map (Table.Refmap'.find_opt i replaced) ~f:(replace seen))
          in
          Tglob (g, args @ extra))
    | Tarr (a, b) -> Tarr (replace seen a, replace seen b)
    | Tmeta { contents = Some t; _ } -> replace seen t
    | (Tmeta { contents = None; _ } | Tvar _ | Tvar' _ | Tdummy _ | Tunknown | Taxiom) as
      t -> t
  in
  replace Refset.empty (Ts_env.expand env (Tglob (r, own)))
;;

let instantiation env sigs ~at:mp ~arguments =
  let canonical = Ts_sig.canon_path sigs mp in
  let rec subst = function
    | Tglob (g, args) ->
      let args = List.map args ~f:subst in
      let gp = Table.modpath_of_r g in
      (match List.find arguments ~f:(fun (at, _) -> ModPath.subpath at gp) with
       | Some (from, to_) ->
         (match Ts_sig.arity sigs g, Ts_sig.functor_ sigs to_ with
          | arity, Some { params; body = Structure _ } when arity > 0 ->
            implemented env sigs ~params (Ts_sig.rebase ~from ~to_ g) args
          | _ -> Tglob (Ts_sig.rebase ~from ~to_ g, args))
       | None ->
         (match Ts_sig.fixed sigs g with
          | Some (_, def) -> subst (Mlutil.type_subst_list args def)
          | None -> Tglob (Ts_sig.rebase ~from:canonical ~to_:mp g, args)))
    | Tarr (a, b) -> Tarr (subst a, subst b)
    | Tmeta { contents = Some t; _ } -> subst t
    | (Tmeta { contents = None; _ } | Tvar _ | Tvar' _ | Tdummy _ | Tunknown | Taxiom) as
      t -> t
  in
  subst
;;

let application_call names ~functor_ ~tyargs ~tparams args rest =
  let locals =
    List.folding_map
      rest
      ~init:(List.fold tparams ~init:(Ts_names.avoid names) ~f:Ts_names.add)
      ~f:(fun avoid (at, _, _) ->
        match at with
        | ModPath.MPbound id ->
          let n, avoid = Ts_names.reserve avoid (Ts_names.pascal (MBId.to_id id)) in
          avoid, (at, n)
        | ModPath.MPfile _ | ModPath.MPdot _ ->
          CErrors.anomaly (Pp.str "Typescript.application: a parameter is bound."))
  in
  let call =
    match args @ List.map locals ~f:(fun (_, n) -> P.Var n) with
    | [] -> CErrors.anomaly (Pp.str "Typescript.application: a functor has a parameter.")
    | first :: rest ->
      List.fold
        rest
        ~init:(P.Call (functor_, tyargs, [ first ]))
        ~f:(fun call a -> P.Call (call, [], [ a ]))
  in
  locals, call
;;

let partial_application ~flat tparams typed ~result_ty call =
  let rec arrow tparams = function
    | [] -> CErrors.anomaly (Pp.str "Typescript.application: a parameter is left.")
    | [ (x, t) ] -> P.Arrow (P.unbounded tparams, [ x, t ], Some result_ty, P.Expr call)
    | (x, t) :: rest ->
      P.Arrow (P.unbounded tparams, [ x, t ], None, P.Expr (arrow [] rest))
  in
  let rec fn tparams = function
    | [] -> result_ty
    | (x, t) :: rest ->
      P.Fn { tparams = P.unbounded tparams; params = [ x, t ]; result = fn [] rest }
  in
  let value =
    { P.name = flat; ty = None; value = arrow (List.map tparams ~f:snd) typed }
  in
  let kept = mentioned tparams (P.Value value) in
  arrow (List.map kept ~f:snd) typed, fn (List.map kept ~f:snd) typed, kept
;;

let application_alias names where ~flat ~api ~instance ~name ~declared ?fixed r vl =
  let sigs = where.sigs in
  let tvars = Ts_names.named names vl in
  let origin = Ts_sig.reaches sigs r in
  let def =
    match fixed with
    | Some def -> def tvars
    | None ->
      P.Name
        ( declared origin
        , List.map (Ts_names.tparams tvars) ~f:(fun n -> P.Name (n, []))
          @ List.map (Ts_sig.implicit sigs origin) ~f:instance )
  in
  Type
    { name
    ; decl =
        P.Alias
          { name
          ; tparams =
              P.unbounded (Ts_names.tparams tvars @ Ts_names.implicit_params names r)
          ; def
          }
    ; builders = [ flat ]
    ; root = api || Refset.mem r where.globals
    }
;;

let packet_aliases names where ~flat ~api ~instance ind (p : ml_ind_packet) =
  if p.ip_logical || Table.is_custom p.ip_typename_ref
  then []
  else (
    let alias = application_alias names where ~flat ~api ~instance in
    let interfaces =
      match ind.ind_kind with
      | Standard | Coinductive ->
        List.map (Array.to_list p.ip_consnames_ref) ~f:(fun c ->
          alias
            ~name:(Ts_names.interface_name names c)
            ~declared:(Ts_names.interface_ref names)
            c
            p.ip_vars)
      | Record _ | Singleton -> []
    in
    interfaces
    @ [ alias
          ~name:(Ts_names.type_name names p.ip_typename_ref)
          ~declared:(Ts_names.type_ref names)
          p.ip_typename_ref
          p.ip_vars
      ])
;;

let application_aliases names where ~at:mp ~flat ~api ~instance ~instance_type members =
  let sigs = where.sigs in
  let alias r vl ~fixed =
    application_alias
      names
      where
      ~flat
      ~api
      ~instance
      ~name:(Ts_names.type_name names r)
      ~declared:(Ts_names.type_ref names)
      ?fixed
      r
      vl
  in
  let rec aliased ~from ~target members =
    List.concat_map members ~f:(fun (l, spec) ->
      let stands r = Ts_sig.rebase ~from ~to_:target r in
      let one r vl ~def =
        let args = List.mapi vl ~f:(fun i _ -> Tvar (i + 1)) in
        let t = Option.value def ~default:(Tglob (stands r, args)) in
        [ alias r vl ~fixed:(Some (fun tvars -> instance_type tvars t)) ]
      in
      match spec with
      | Spec (Sind ind) ->
        List.concat_map (Array.to_list ind.ind_packets) ~f:(fun (p : ml_ind_packet) ->
          if p.ip_logical || Table.is_custom (stands p.ip_typename_ref)
          then []
          else one p.ip_typename_ref p.ip_vars ~def:None)
      | Spec (Stype (r, vl, def)) ->
        if
          Table.is_inline_custom (stands r)
          || Option.is_some (Ts_primitives.builtin (stands r))
        then []
        else (
          match def, Ts_sig.fixed sigs r with
          | Some def, _ | None, Some (_, def) -> one r vl ~def:(Some def)
          | None, None -> one r vl ~def:None)
      | Smodule nested ->
        let from = ModPath.MPdot (from, l) in
        aliased
          ~from
          ~target:(ModPath.MPdot (target, l))
          (Ts_sig.resolve sigs ~at:from nested)
      | Spec (Sval _) | Smodtype _ -> [])
  in
  let rec aliases ~at members =
    List.concat_map members ~f:(fun (l, spec) ->
      match spec with
      | Spec (Sind ind) ->
        List.concat_map
          (Array.to_list ind.ind_packets)
          ~f:(packet_aliases names where ~flat ~api ~instance ind)
      | Spec (Stype (r, vl, def)) ->
        if Table.is_inline_custom r || Option.is_some (Ts_primitives.builtin r)
        then []
        else (
          let fixed =
            match def, Ts_sig.fixed sigs r with
            | Some def, Some _ | None, Some (_, def) ->
              Some (fun tvars -> Ts_names.ty names tvars (Ts_type.of_ml def))
            | Some _, None | None, None -> None
          in
          [ alias r vl ~fixed ])
      | Spec (Sval _) | Smodtype _ -> []
      | Smodule nested ->
        let at = ModPath.MPdot (at, l) in
        let members = Ts_sig.resolve sigs ~at nested in
        (match Ts_sig.alias sigs (Ts_sig.canon_path sigs at) with
         | Some target -> aliased ~from:at ~target members
         | None -> aliases ~at members))
  in
  aliases ~at:mp members
;;

let application_result sigs ~at:mp ~bound result =
  let canonical = Ts_sig.canon_path sigs mp in
  let rebased g =
    let gp = Table.modpath_of_r g in
    match List.find bound ~f:(fun (at, _) -> ModPath.subpath at gp) with
    | Some (from, to_) -> Ts_sig.rebase ~from ~to_ g
    | None -> Ts_sig.rebase ~from:canonical ~to_:mp g
  in
  match result with
  | Own (own, globals) -> Own (own, List.map globals ~f:rebased)
  | Typed (origin, globals) -> Typed (origin, List.map globals ~f:rebased)
;;

let application env names where mp me mt =
  let sigs = where.sigs in
  let f, args = application_parts me in
  let info, outer, applied, rest = applied_functor where f args in
  let bound =
    info.bound @ List.map2_exn applied args ~f:(fun (id, _) a -> ModPath.MPbound id, a)
  in
  let outer = instantiate_bindings outer bound in
  let members = Ts_sig.resolve sigs ~at:mp mt in
  let name = Ts_names.module_name names mp
  and flat = Ts_names.flat_name names mp in
  let api = asked_exactly where mp in
  let abstracts, tparams = abstracts_of_parameters sigs names rest in
  let names = Ts_names.in_scope names tparams in
  Hashtbl.set where.applied ~key:mp ~data:(outer @ bound);
  let arguments = outer @ bound @ List.map abstracts ~f:(fun (at, _, _) -> at, at) in
  let left =
    match f with
    | ModPath.MPbound id ->
      (match Ts_sig.parameter sigs id with
       | Some mt ->
         (match Ts_sig.functor_signature sigs mt with
          | Some s ->
            let p = Ts_sig.origin sigs mt in
            List.fold
              (snd (Ts_sig.signature_abstracts sigs ~at:p s))
              ~init:Table.Refmap'.empty
              ~f:(fun m (a : Ts_sig.abstract) ->
                Table.Refmap'.add a.global (Ts_sig.rebase ~from:p ~to_:mp a.global) m)
          | None -> Table.Refmap'.empty)
       | None -> Table.Refmap'.empty)
    | ModPath.MPfile _ | ModPath.MPdot _ -> Table.Refmap'.empty
  in
  let subst = instantiation env sigs ~at:mp ~arguments in
  let instance_type tvars t =
    Ts_names.ty names tvars (Ts_type.of_ml (Ts_env.expand env (subst t)))
  in
  let instance g =
    match Table.Refmap'.find_opt g left, Ts_sig.arity sigs g with
    | Some b, _ -> Ts_names.ty names Ts_names.erased (Ts_type.Glob (b, []))
    | None, 0 -> instance_type (Ts_names.params names 0) (Tglob (g, []))
    | None, arity ->
      let gp = Table.modpath_of_r g in
      let head =
        Option.map
          (List.find arguments ~f:(fun (at, _) -> ModPath.subpath at gp))
          ~f:(fun (from, to_) -> Ts_sig.rebase ~from ~to_ g)
      in
      kind_argument env names where ~arity ~owner:g ?head subst
  in
  let tyargs = List.map info.tparams ~f:instance in
  let functor_ = Ts_names.module_ref names f in
  let locals, call =
    application_call
      names
      ~functor_
      ~tyargs
      ~tparams:(List.map tparams ~f:snd)
      (List.map args ~f:(argument_object names ~at:mp))
      abstracts
  in
  let result_ty = result_type sigs names ~instance info.result in
  let value, ty =
    match abstracts with
    | [] -> call, result_ty
    | abstracts ->
      let typed =
        List.map2_exn abstracts locals ~f:(fun (at, mt, _) (_, x) ->
          x, signature_type env names where ~at mt)
      in
      let value, ty, kept = partial_application ~flat tparams typed ~result_ty call in
      Hashtbl.set
        where.functors
        ~key:mp
        ~data:{ info with bound; tparams = List.map kept ~f:fst };
      value, ty
  in
  let aliases =
    application_aliases names where ~at:mp ~flat ~api ~instance ~instance_type members
  in
  let binding = module_binding where mp name { P.name = flat; ty = None; value } in
  let result = application_result sigs ~at:mp ~bound:(outer @ bound) info.result in
  aliases @ [ Application { binding; functor_; tyargs; ty; result } ], 0
;;

let rec bound_path = function
  | ModPath.MPbound _ -> true
  | ModPath.MPdot (mp, _) -> bound_path mp
  | ModPath.MPfile _ -> false
;;

let rec captures_type sigs ~body = function
  | Tglob (g, args) ->
    let gp = Table.modpath_of_r g in
    bound_path gp
    || (ModPath.subpath body gp && not (List.is_empty (Ts_sig.implicit sigs g)))
    || List.exists args ~f:(captures_type sigs ~body)
  | Tarr (a, b) -> captures_type sigs ~body a || captures_type sigs ~body b
  | Tmeta { contents = Some t; _ } -> captures_type sigs ~body t
  | Tmeta { contents = None; _ } | Tvar _ | Tvar' _ | Tdummy _ | Tunknown | Taxiom ->
    false
;;

let referenced asts =
  let globals = ref []
  and types = ref [] in
  let rec ast a =
    (match a with
     | MLglob r -> globals := r :: !globals
     | MLcons (t, r, _) ->
       globals := r :: !globals;
       types := t :: !types
     | MLcase (t, _, _) -> types := t :: !types
     | MLrel _
     | MLapp _
     | MLlam _
     | MLletin _
     | MLtuple _
     | MLfix _
     | MLexn _
     | MLdummy _
     | MLaxiom _
     | MLmagic _
     | MLuint _
     | MLfloat _
     | MLstring _
     | MLparray _ -> ());
    Mlutil.ast_iter ast a
  in
  Array.iter asts ~f:ast;
  !globals, !types
;;

let rec hoisting_candidates sel =
  List.concat_map sel ~f:(fun (_, se) ->
    match se with
    | SEdecl (Dterm (r, a, (Tarr _ as t))) ->
      if Table.is_custom r
      then [ [ r ], [], [] ]
      else (
        let globals, types = referenced [| a |] in
        [ [ r ], globals, t :: types ])
    | SEdecl (Dfix (rv, av, tv)) ->
      let members = Ts_names.group_members rv av in
      if List.is_empty members || Array.exists av ~f:(fun a -> Mlutil.nb_lams a = 0)
      then []
      else (
        let globals, types = referenced av in
        [ members, globals, Array.to_list tv @ types ])
    | SEmodule { ml_mod_expr = MEstruct (_, sel); _ } -> hoisting_candidates sel
    | SEdecl (Dterm _ | Dind _ | Dtype _)
    | SEmodule { ml_mod_expr = MEapply _ | MEident _ | MEfunctor _; _ }
    | SEmodtype _ -> [])
;;

(* Each is declared at the top level of the file, under the functor's
   name, as the consistent-function-scoping rule asks of a function that
   captures nothing, and the body returns it as a member. *)
let hoisted_functions sigs ~body sel =
  let in_body r = ModPath.subpath body (Table.modpath_of_r r) in
  let groups = hoisting_candidates sel in
  let bound r = bound_path (Table.modpath_of_r r) in
  let rec close kept =
    let stays r =
      in_body r && (not (Refset.mem r kept)) && not (Table.is_inline_custom r)
    in
    let kept' =
      Refset.of_list
        (List.concat_map groups ~f:(fun (members, refs, tys) ->
           if
             List.for_all members ~f:(fun r -> Refset.mem r kept)
             && (not (List.exists refs ~f:stays))
             && (not (List.exists refs ~f:bound))
             && not (List.exists tys ~f:(captures_type sigs ~body))
           then members
           else []))
    in
    if Refset.equal kept' kept then kept else close kept'
  in
  close (Refset.of_list (List.concat_map groups ~f:(fun (members, _, _) -> members)))
;;

let hoisted_constructors sigs ~body sel =
  let rec go constructors sel =
    List.fold sel ~init:constructors ~f:(fun constructors (_, se) ->
      match se with
      | SEdecl (Dind ind) ->
        Array.fold
          ind.ind_packets
          ~init:constructors
          ~f:(fun constructors (p : ml_ind_packet) ->
            if
              p.ip_logical || not (List.is_empty (Ts_sig.implicit sigs p.ip_typename_ref))
            then constructors
            else
              Array.foldi
                p.ip_consnames_ref
                ~init:constructors
                ~f:(fun j constructors c ->
                  let args = p.ip_types.(j) in
                  if
                    (not (List.is_empty args))
                    && not (List.exists args ~f:(captures_type sigs ~body))
                  then Refset.add c constructors
                  else constructors))
      | SEmodule { ml_mod_expr = MEstruct (_, sel); _ } -> go constructors sel
      | SEdecl (Dterm _ | Dtype _ | Dfix _)
      | SEmodule { ml_mod_expr = MEapply _ | MEident _ | MEfunctor _; _ }
      | SEmodtype _ -> constructors)
  in
  go Refset.empty sel
;;

let hoisted sigs ~body sel =
  Refset.union (hoisted_functions sigs ~body sel) (hoisted_constructors sigs ~body sel)
;;

type body_locals =
  { objects : (ModPath.t * string) list
  ; nested : (ModPath.t * string) list
  ; modules : (ModPath.t * string) list
  ; top_bound : (global * string) list
  ; members : (global * string) list
  ; holders : (global * string) list
  }

let reserve avoid s =
  let n, avoid = Ts_names.reserve avoid s in
  avoid, n
;;

let staying_members names ~body ~objects ~hoisted avoid sel =
  let short =
    Ts_names.in_body
      names
      ~body
      ~params:objects
      ~locals:[]
      ~holders:[]
      ~hoisted:(Refset.elements hoisted)
      ~modules:[]
  in
  let named =
    List.folding_map
      (List.filter (body_values sel) ~f:(function `Value r | `Holder r ->
           not (Refset.mem r hoisted)))
      ~init:avoid
      ~f:(fun avoid v ->
        match v with
        | `Value r ->
          let avoid, n = reserve avoid (Ts_names.value_name short r) in
          avoid, `Value (r, n)
        | `Holder r ->
          let avoid, n =
            reserve avoid (Option.value (Ts_names.group_name short r) ~default:"group")
          in
          avoid, `Holder (r, n))
  in
  List.partition_map named ~f:(function
    | `Value (r, n) -> Either.First (r, n)
    | `Holder (r, n) -> Either.Second (r, n))
;;

(* The locals of the body also avoid the type parameters [tparams] of the
   arrow, since no-redeclare rejects a parameter named like one. *)
let body_locals names ~body ~params ~hoisted ~tparams sel =
  let avoid, objects =
    List.fold_map
      params
      ~init:(List.fold tparams ~init:(Ts_names.avoid names) ~f:Ts_names.add)
      ~f:(fun avoid (id, _) ->
        let avoid, n = reserve avoid (Ts_names.pascal (MBId.to_id id)) in
        avoid, (ModPath.MPbound id, n))
  in
  let avoid, modules =
    List.fold_map sel ~init:avoid ~f:(fun avoid (l, se) ->
      match se with
      | SEmodule { ml_mod_expr = MEstruct _ | MEapply _ | MEfunctor _; _ } ->
        let p = ModPath.MPdot (body, l) in
        let avoid, n = reserve avoid (Ts_names.module_name names p) in
        avoid, Some (p, n)
      | SEmodule { ml_mod_expr = MEident _; _ } | SEdecl _ | SEmodtype _ -> avoid, None)
  in
  let modules = List.filter_opt modules in
  let nested =
    List.filter_map sel ~f:(fun (l, se) ->
      match se with
      | SEmodule { ml_mod_expr = MEapply _ | MEfunctor _; _ } ->
        let p = ModPath.MPdot (body, l) in
        Some (p, List.Assoc.find_exn modules ~equal:Poly.equal p)
      | SEmodule { ml_mod_expr = MEstruct _ | MEident _; _ } | SEdecl _ | SEmodtype _ ->
        None)
  in
  let avoid, top_bound =
    List.fold_map
      (bound_methods names (objects @ nested) sel)
      ~init:avoid
      ~f:(fun avoid r ->
        let avoid, n = reserve avoid (Ts_names.member_name names r) in
        avoid, (r, n))
  in
  let members, holders = staying_members names ~body ~objects ~hoisted avoid sel in
  { objects; nested; modules; top_bound; members = top_bound @ members; holders }
;;

let bind_members names locals p x =
  let rec object_of mp =
    match mp with
    | ModPath.MPdot (parent, _) when not (ModPath.equal mp p) ->
      P.Field (object_of parent, Ts_names.module_name names mp)
    | ModPath.MPdot _ | ModPath.MPfile _ | ModPath.MPbound _ -> P.Var x
  in
  let add sources (r, n) =
    let mp = Table.modpath_of_r r
    and field = Ts_names.member_name names r, n in
    if not (ModPath.subpath p mp)
    then sources
    else if List.exists sources ~f:(fun (mp', _) -> ModPath.equal mp mp')
    then
      List.map sources ~f:(fun (mp', fields) ->
        mp', if ModPath.equal mp mp' then fields @ [ field ] else fields)
    else sources @ [ mp, [ field ] ]
  in
  List.map (List.fold locals.top_bound ~init:[] ~f:add) ~f:(fun (mp, fields) ->
    P.Bind (fields, object_of mp))
;;

let result_interface generics name fields =
  fields_interface
    generics
    name
    (List.map fields ~f:(function
       | Member (b, ty) -> b.member, ty
       | Submodule { member; ty; _ } | Aliased { member; ty; _ } -> member, ty))
;;

let returned_fields fields =
  List.map fields ~f:(function
    | Member (b, _) -> b.member, P.Var b.value.name
    | Submodule { member; local; _ } -> member, P.Var local
    | Aliased { member; value; _ } -> member, value)
;;

let generalised generics item =
  match item with
  | Value ({ value = { ty = Some (P.Fn f); value = P.Code _; _ } as v; _ } as b) ->
    let kept =
      mentioned generics (P.Type (P.Alias { name = ""; tparams = []; def = P.Fn f }))
    in
    Value
      { b with
        value =
          { v with
            ty =
              Some
                (P.Fn { f with tparams = P.unbounded (List.map kept ~f:snd) @ f.tparams })
          }
      }
  | Value _ | Type _ | Lifted _ | Group _ | Module _ | Nested _ | Application _ -> item
;;

let generic_arrow ~flat ~own typed ~result_ty inner =
  let rec arrow tparams = function
    | [] -> CErrors.anomaly (Pp.str "Typescript.functor_: a functor has a parameter.")
    | [ (x, t) ] -> P.Arrow (P.unbounded tparams, [ x, t ], Some result_ty, inner)
    | (x, t) :: rest ->
      P.Arrow (P.unbounded tparams, [ x, t ], None, P.Expr (arrow [] rest))
  in
  let value = { P.name = flat; ty = None; value = arrow (List.map own ~f:snd) typed } in
  let read_values, read_types = P.reads (P.Value value) in
  let kept =
    List.filter own ~f:(fun (_, n) ->
      List.mem (List.map read_types ~f:fst) n ~equal:String.equal)
  in
  let used x = List.exists read_values ~f:(fun (root, _) -> String.equal root x) in
  let typed = List.map typed ~f:(fun (x, t) -> (if used x then x else "_" ^ x), t) in
  { value with value = arrow (List.map kept ~f:snd) typed }, kept
;;

let functor_result env names where ~mp ~body ~generics mt fields =
  let sigs = where.sigs in
  let rec result = function
    | MTfunsig (_, _, mt) -> result mt
    | (MTsig _ | MTident _ | MTwith _) as mt -> mt
  in
  let result_name = Ts_names.signature_name names mp in
  match result mt with
  | MTsig _ ->
    let decl, kept = result_interface generics result_name fields in
    ( P.Name (result_name, type_args kept)
    , [ Type { name = result_name; decl; builders = []; root = false } ]
    , Own (mp, List.map kept ~f:fst)
    , P.Record (returned_fields fields) )
  | (MTident _ | MTwith _ | MTfunsig _) as sealed ->
    let origin = Ts_sig.origin sigs sealed in
    let ty, result = sealed_result env names where ~at:body sealed in
    ( ty
    , []
    , result
    , P.Record
        (sealed_object
           sigs
           names
           ~declared:origin
           ~defined:body
           (Ts_sig.resolve sigs ~at:origin sealed)
           (Ts_sig.resolve sigs ~at:body sealed)
           fields) )
;;

let applied_body env names inside ~generic ~at:mp me =
  match application env names inside mp me (MTsig (mp, [])) with
  | [ Application { binding = applied; ty; result; _ } ], _ ->
    let value, kept = generic ~result_ty:ty (P.Expr applied.value.value) in
    value, kept, result
  | _ -> CErrors.anomaly (Pp.str "Typescript.functor_: a body that is an application.")
;;

let module_result env names where ~mp ~generics ~params mt target =
  let sigs = where.sigs in
  let parameters, result =
    match Ts_sig.functor_signature sigs mt with
    | Some { parameters; result } -> parameters, result
    | None -> CErrors.anomaly (Pp.str "Typescript.functor_: a functor has a signature.")
  in
  if List.length parameters > List.length params
  then (
    let written mp =
      match Nametab.shortest_qualid_of_module mp with
      | q -> Libnames.string_of_qualid q
      | exception Stdlib.Not_found -> ModPath.to_string mp
    in
    CErrors.user_err
      Pp.(
        str "The functor "
        ++ str (written mp)
        ++ str " is defined as the functor "
        ++ str (written target)
        ++ str ", and a functor that returns a functor has no TypeScript form."));
  let typed sealed =
    let ty, result = sealed_result env names where ~at:target sealed in
    [], ty, result
  in
  match result, target with
  | (MTident _ | MTwith _), _ -> typed result
  | MTsig _, ModPath.MPbound id ->
    let sealed =
      match
        Option.first_some
          (List.Assoc.find params ~equal:MBId.equal id)
          (Ts_sig.parameter sigs id)
      with
      | Some mt -> mt
      | None ->
        CErrors.anomaly
          (Pp.str "Typescript.module_result: a parameter has no module type.")
    in
    typed sealed
  | MTsig (p, _), (ModPath.MPfile _ | ModPath.MPdot _) ->
    let name = Ts_names.signature_name names mp in
    let items, decl, kept =
      interface
        env
        names
        where
        ~params:generics
        ~name
        p
        (Ts_sig.resolve sigs ~at:p result)
    in
    ( items @ [ Type { name; decl; builders = []; root = false } ]
    , P.Name (name, type_args kept)
    , Own (mp, List.map kept ~f:fst) )
  | MTfunsig _, _ ->
    CErrors.anomaly (Pp.str "Typescript.functor_: a functor signature has a result.")
;;

type lowering =
  { env : Ts_env.t
  ; names : Ts_names.t
  ; outside : Ts_names.t
  ; where : where
  ; inside : where
  ; hoisted : Refset.t
  ; generics : (global * string) list
  ; locals : body_locals
  }

(* One that reads none goes to the top level, as the
   consistent-function-scoping rule asks of a function that captures
   nothing, and a functor nested in the body passes it on to the body
   around it, which may keep it. *)
let reads_body low stmts (v : P.value) =
  let locals =
    Set.of_list
      (module String)
      (List.map (low.locals.objects @ low.locals.nested) ~f:snd
       @ List.map (low.locals.members @ low.locals.holders) ~f:snd
       @ List.concat_map stmts ~f:defines)
  in
  let values, types = P.reads (P.Value v) in
  List.exists values ~f:(fun (x, _) -> Set.mem locals x)
  || List.exists types ~f:(fun (t, _) ->
    List.exists low.generics ~f:(fun (_, n) -> String.equal n t))
;;

let aliased_object low target =
  let rec placed mp =
    match Hashtbl.find low.where.objects mp, mp with
    | (Some _ as o), _ -> o
    | None, ModPath.MPdot (parent, _) ->
      Option.map (placed parent) ~f:(fun (value, ty) ->
        let member = Ts_names.module_name low.names mp in
        P.Field (value, member), P.Indexed (ty, member))
    | None, (ModPath.MPfile _ | ModPath.MPbound _) -> None
  in
  let rec path = function
    | P.Var x -> x, []
    | P.Field (e, f) ->
      let root, members = path e in
      root, members @ [ f ]
    | _ -> CErrors.anomaly (Pp.str "Typescript.aliased_object: a module is a path.")
  in
  match placed target with
  | Some o -> o
  | None ->
    let value = Ts_names.module_ref low.names target in
    let root, members = path value in
    value, P.Typeof (root, members)
;;

let rec functor_ ?(outer = []) env names where mp mt =
  let sigs = where.sigs in
  let { Ts_sig.params; body = functor_body } =
    match Ts_sig.functor_ sigs mp with
    | Some f -> f
    | None ->
      CErrors.anomaly (Pp.str "Typescript.functor_: a functor the module types miss.")
  in
  let body, sel =
    match functor_body with
    | Ts_sig.Structure (body, sel) -> body, sel
    | Ts_sig.Applied _ -> mp, []
  in
  let name = Ts_names.module_name names mp
  and flat = Ts_names.flat_name names mp in
  let abstracts, own = abstracts_of_parameters sigs names params in
  let generics = outer @ own in
  let names = Ts_names.in_scope names own in
  let hoisted = hoisted sigs ~body sel in
  let locals =
    body_locals names ~body ~params ~hoisted ~tparams:(List.map generics ~f:snd) sel
  in
  let outside = names in
  let names =
    Ts_names.in_body
      names
      ~body
      ~params:locals.objects
      ~locals:locals.members
      ~holders:locals.holders
      ~hoisted:(Refset.elements hoisted)
      ~modules:locals.modules
  in
  let inside = within where mp ~owner:flat in
  let inline = inline_parameters env outside where ~outer:generics abstracts in
  let typed =
    List.map2_exn abstracts locals.objects ~f:(fun (at, mt, _) (_, x) ->
      let ty = signature_type env names where ~at mt in
      Hashtbl.set where.objects ~key:at ~data:(P.Var x, ty);
      x, ty)
  in
  let generic = generic_arrow ~flat ~own typed in
  let binding = module_binding where mp name in
  let items, value, kept, result, casts =
    match functor_body with
    | Ts_sig.Applied (MEident target) ->
      let items, result_ty, result =
        module_result env names where ~mp ~generics ~params mt target
      in
      let value =
        match List.Assoc.find locals.objects ~equal:ModPath.equal target with
        | Some x -> P.Var x
        | None -> Ts_names.module_ref names target
      in
      let value, kept = generic ~result_ty (P.Expr value) in
      items, value, kept, result, 0
    | Ts_sig.Applied me ->
      let value, kept, result = applied_body env names inside ~generic ~at:mp me in
      [], value, kept, result, 0
    | Ts_sig.Structure _ ->
      let low = { env; names; outside; where; inside; hoisted; generics; locals } in
      let (types, stmts, fields), casts = lower_body low ~at:body sel in
      let binds =
        List.concat_map locals.objects ~f:(fun (p, x) -> bind_members names locals p x)
      in
      let result_ty, result_items, result, returned =
        functor_result env names where ~mp ~body ~generics mt fields
      in
      let inner =
        match needed_statements (binds @ stmts) returned with
        | [] -> P.Expr returned
        | stmts -> P.Block (stmts @ [ P.Return returned ])
      in
      let value, kept = generic ~result_ty inner in
      types @ result_items, value, kept, result, casts
  in
  Hashtbl.set
    where.functors
    ~key:mp
    ~data:{ params; bound = []; tparams = List.map kept ~f:fst; result };
  inline @ items @ [ Value (binding value) ], casts

and lower_body low ~at sel =
  List.fold
    sel
    ~init:(([], [], []), 0)
    ~f:(fun (((types, _, _), _) as acc) e ->
      let (types', stmts', fields'), casts' = lower_element low ~at acc e in
      let added = List.drop types' (List.length types) in
      (types @ take_lambdas low.where @ added, stmts', fields'), casts')

and lower_element low ~at ((types, stmts, fields), casts) (l, se) =
  let p = ModPath.MPdot (at, l) in
  let lowered items casts' =
    fold_items low (types, stmts, fields) items, casts + casts'
  in
  match se with
  | SEdecl (Dind ind as d)
    when Array.exists ind.ind_packets ~f:(fun (p : ml_ind_packet) ->
           Table.is_custom p.ip_typename_ref) ->
    let items, casts' = lower low.env low.outside low.inside d in
    (types @ items, stmts, fields), casts + casts'
  | SEdecl d
    when (not (List.is_empty (declared d)))
         && List.for_all (declared d) ~f:(fun r -> Refset.mem r low.hoisted) ->
    let items, casts' = lower low.env low.names low.inside d in
    let members =
      List.map (bindings items) ~f:(fun b -> Member (b, member_type b.member b.value))
    in
    ( (types @ List.map items ~f:(generalised low.generics), stmts, fields @ members)
    , casts + casts' )
  | SEdecl d ->
    let items, casts' = lower low.env low.names low.inside d in
    lowered items casts'
  | SEmodule { ml_mod_expr = MEapply _ as me; ml_mod_type } ->
    let items, casts' = application low.env low.names low.inside p me ml_mod_type in
    List.iter items ~f:(function
      | Application { binding = b; ty; _ } ->
        Hashtbl.set low.where.objects ~key:p ~data:(P.Var b.value.name, ty)
      | Type _ | Value _ | Lifted _ | Group _ | Module _ | Nested _ -> ());
    lowered items casts'
  | SEmodule { ml_mod_expr = MEstruct (mp, sel); _ } ->
    let (types', stmts', fields'), casts' = lower_body low ~at:mp sel in
    let name = Ts_names.module_name low.names mp
    and local = Ts_names.flat_name low.names mp
    and interface = Ts_names.signature_name low.names mp in
    let decl, kept = result_interface low.generics interface fields' in
    let ty = P.Name (interface, type_args kept) in
    Hashtbl.set low.where.objects ~key:mp ~data:(P.Var local, ty);
    ( ( types @ types' @ [ Type { name = interface; decl; builders = []; root = false } ]
      , stmts
        @ stmts'
        @ [ P.Const (local, None, P.Module_object (returned_fields fields')) ]
      , fields @ [ Submodule { member = name; local; ty; fields = fields' } ] )
    , casts + casts' )
  | SEmodule { ml_mod_expr = MEident target; _ } ->
    let value, ty = aliased_object low target in
    ( ( types
      , stmts
      , fields @ [ Aliased { member = Ts_names.module_name low.names p; value; ty } ] )
    , casts )
  | SEmodule { ml_mod_expr = MEfunctor _; ml_mod_type } ->
    let items, casts' =
      functor_ ~outer:low.generics low.env low.names low.inside p ml_mod_type
    in
    let bubbled, arrow =
      match List.rev items with
      | Value arrow :: rest -> List.rev rest, arrow
      | _ ->
        CErrors.anomaly
          (Pp.str "Typescript.functor_: a nested functor returns its arrow.")
    in
    Hashtbl.set
      low.where.objects
      ~key:p
      ~data:(P.Var arrow.value.name, member_type arrow.member arrow.value);
    fold_items low (types @ bubbled, stmts, fields) [ Value arrow ], casts + casts'
  | SEmodtype mt ->
    lowered (signature ~outer:low.generics low.env low.names low.where p mt) 0

and fold_items low acc items =
  List.fold items ~init:acc ~f:(fun (types, stmts, fields) item ->
    match item with
    | Type _ -> types @ [ item ], stmts, fields
    | Lifted v when not (reads_body low stmts v) -> types @ [ item ], stmts, fields
    | Lifted v -> types, stmts @ [ P.Const (v.name, v.ty, v.value) ], fields
    | Value ({ value = { value = P.Arrow _; _ }; _ } as b)
      when String.contains b.value.name '$' && not (reads_body low stmts b.value) ->
      types @ [ Value b ], stmts, fields @ [ Member (b, member_type b.member b.value) ]
    | Value b ->
      ( types
      , stmts @ [ P.Const (b.value.name, b.value.ty, b.value.value) ]
      , fields @ [ Member (b, member_type b.member b.value) ] )
    | Group { holder; members } ->
      ( types
      , stmts
        @ [ P.Const (holder.name, None, holder.value)
          ; P.Bind (List.map members ~f:(fun m -> m.key, m.value.name), P.Var holder.name)
          ]
      , fields @ List.map members ~f:(fun m -> Member (m, member_type m.member m.value)) )
    | Application { binding = b; ty; _ } ->
      let p =
        List.find low.locals.nested ~f:(fun (_, x) -> String.equal x b.value.name)
      in
      ( types
      , stmts
        @ [ P.Const (b.value.name, None, b.value.value) ]
        @ Option.value_map p ~default:[] ~f:(fun (p, x) ->
          bind_members low.names low.locals p x)
      , fields @ [ Member (b, ty) ] )
    | Module _ | Nested _ ->
      CErrors.anomaly (Pp.str "Typescript.functor_: a body lowers to values and types."))
;;

let rec place env names where mp sel =
  concat
    (List.map sel ~f:(fun e ->
       let items, casts = place_element env names where mp e in
       take_lambdas where @ items, casts))

and place_element env names where parent (l, se) =
  let mp = ModPath.MPdot (parent, l) in
  match se with
  | SEdecl d -> lower env names where d
  | SEmodule { ml_mod_expr = MEstruct (mp, sel); _ } ->
    let name = Ts_names.module_name names mp in
    let inside = within where mp ~owner:name in
    let items, casts = place env names inside mp sel in
    [ module_ names where mp name (Items items) ], casts
  | SEmodule { ml_mod_expr = MEident target; _ } ->
    let name = Ts_names.module_name names mp in
    let inside = { where with api = asked_exactly where mp } in
    ( alias_types names inside mp
      @ [ module_ names where mp name (Alias (Ts_names.module_ref names target)) ]
    , 0 )
  | SEmodule { ml_mod_expr = MEfunctor _; ml_mod_type } ->
    functor_ env names where mp ml_mod_type
  | SEmodule { ml_mod_expr = MEapply _ as me; ml_mod_type } ->
    application env names where mp me ml_mod_type
  | SEmodtype mt -> signature env names where mp mt, 0
;;

type space =
  | Values
  | Types
[@@deriving compare, hash, sexp_of]

module Key = struct
  type t =
    { file : string
    ; space : space
    ; name : string
    }
  [@@deriving compare, hash, sexp_of]
end

type mark =
  | Written
  | Exported
[@@deriving equal]

type needs =
  { refers : (Key.t * mark) list
  ; api : Key.t list
  ; root : bool
  ; whole : Key.t list
  }

let leaf ~refers ~api ~root = { refers; api; root; whole = [] }

let rec aliased items =
  List.concat_map items ~f:(function
    | Type _ | Value _ | Lifted _ | Group _ | Application _ -> []
    | Module { body = Items items; _ } | Nested { body = Items items; _ } -> aliased items
    | Module { body = Alias target; _ } | Nested { body = Alias target; _ } -> [ target ])
;;

let read names ~file =
  let files = Ts_names.imports names in
  let bound =
    List.concat_map (Ts_names.bindings names) ~f:(fun ((alias, mods), fields) ->
      List.map fields ~f:(fun (member, local) -> local, (alias, mods @ [ member ])))
  in
  let rec go space (root, members) =
    match List.Assoc.find files ~equal:String.equal root, members with
    | Some file, name :: rest ->
      ({ Key.file; space; name }, Exported)
      ::
      (match space, rest with
       | Values, _ :: _ ->
         [ { Key.file; space; name = String.concat ~sep:"$" members }, Written ]
       | Values, [] | Types, _ -> [])
    | Some _, [] | None, _ ->
      (match space, List.Assoc.find bound ~equal:String.equal root with
       | Values, Some path -> go Values path
       | (Values | Types), _ -> [ { Key.file; space; name = root }, Written ])
  in
  go
;;

let nodes names ~file items =
  let read = read names ~file in
  let own space name = { Key.file; space; name } in
  let refers d =
    let values, types = P.reads d in
    List.concat_map values ~f:(read Values) @ List.concat_map types ~f:(read Types)
  in
  let signature v =
    List.concat_map (P.signature v) ~f:(fun p -> List.map (read Types p) ~f:fst)
  in
  let object_of target = refers (P.Value { name = ""; ty = None; value = target }) in
  let module_object name ~root items =
    let members = bindings items in
    let targets = List.concat_map (aliased items) ~f:object_of in
    let member_key b = own Values b.value.name in
    ( own Values name
    , { refers =
          List.filter_map members ~f:(fun b ->
            if b.demanded then Some (member_key b, Written) else None)
          @ targets
      ; api =
          List.concat_map members ~f:(fun b -> signature b.value)
          @ List.map targets ~f:fst
      ; root
      ; whole = List.map members ~f:member_key
      } )
  in
  let rec go = function
    | Type { name; decl; builders; root } ->
      let refers = refers (P.Type decl) in
      [ ( own Types name
        , leaf
            ~refers
            ~api:(List.map refers ~f:fst @ List.map builders ~f:(own Values))
            ~root )
      ]
    | Nested { flat; body = Items items; _ } ->
      module_object flat ~root:false items :: List.concat_map items ~f:go
    | Value { value; root; _ } ->
      [ ( own Values value.name
        , leaf ~refers:(refers (P.Value value)) ~api:(signature value) ~root )
      ]
    | Lifted value ->
      [ own Values value.name, leaf ~refers:(refers (P.Value value)) ~api:[] ~root:false ]
    | Application { binding = { value; root; _ }; functor_; tyargs; _ } ->
      let argument t =
        List.concat_map
          (snd (P.reads (P.Type (P.Alias { name = ""; tparams = []; def = t }))))
          ~f:(fun p -> List.map (read Types p) ~f:fst)
      in
      ( own Values value.name
      , leaf
          ~refers:(refers (P.Value value))
          ~api:(List.map (object_of functor_) ~f:fst @ List.concat_map tyargs ~f:argument)
          ~root )
      :: List.concat_map (Ts_names.methods_of names value.name) ~f:(fun (_, fields) ->
        List.map fields ~f:(fun (_, local) ->
          ( own Values local
          , leaf ~refers:[ own Values value.name, Written ] ~api:[] ~root:false )))
    | Group { holder; members } ->
      (own Values holder.name, leaf ~refers:(refers (P.Value holder)) ~api:[] ~root:false)
      :: List.map members ~f:(fun m ->
        ( own Values m.value.name
        , leaf
            ~refers:[ own Values holder.name, Written ]
            ~api:(signature m.value)
            ~root:m.root ))
    | Module { name; root; body = Items items } ->
      module_object name ~root items :: List.concat_map items ~f:go
    | Module { name; root; body = Alias target } ->
      let refers = object_of target in
      [ own Values name, leaf ~refers ~api:(List.map refers ~f:fst) ~root ]
    | Nested { body = Alias _; _ } -> []
  in
  List.concat_map items ~f:go
;;

let mark nodes =
  let table = Hashtbl.create (module Key) ~size:64 in
  List.iter nodes ~f:(fun (k, n) -> Hashtbl.set table ~key:k ~data:n);
  let marks = Hashtbl.create (module Key) ~size:64 in
  let opened = Hashtbl.create (module Key) ~size:64 in
  let rec set k m ~from_ref =
    match Hashtbl.find table k with
    | None -> ()
    | Some n ->
      let before = Hashtbl.find marks k in
      let settled =
        match before, m with
        | Some Exported, _ | Some Written, Written -> true
        | Some Written, Exported | None, _ -> false
      in
      if not settled
      then (
        Hashtbl.set marks ~key:k ~data:m;
        if Option.is_none before
        then List.iter n.refers ~f:(fun (d, m) -> set d m ~from_ref:true);
        if equal_mark m Exported
        then List.iter n.api ~f:(fun d -> set d Exported ~from_ref:true));
      if from_ref && not (Hashtbl.mem opened k)
      then (
        Hashtbl.add_exn opened ~key:k ~data:();
        List.iter n.whole ~f:(fun d -> set d Written ~from_ref:true))
  in
  List.iter nodes ~f:(fun (k, n) -> if n.root then set k Exported ~from_ref:false);
  Hashtbl.find marks
;;

let emit names marked ~file items =
  let marked space name = marked { Key.file; space; name } in
  let exported = function
    | Exported -> true
    | Written -> false
  in
  let field b = b.member, P.Var b.value.name in
  let group (holder : P.value) kept =
    let destructuring ~wanted =
      match List.filter kept ~f:(fun (_, m) -> Bool.equal (exported m) wanted) with
      | [] -> []
      | kept ->
        [ { P.exported = wanted
          ; decl =
              P.Members
                { fields = List.map kept ~f:(fun (b, _) -> b.key, b.value.name)
                ; source = holder.name, []
                }
          }
        ]
    in
    ({ P.exported = false; decl = P.Value holder } :: destructuring ~wanted:true)
    @ destructuring ~wanted:false
  in
  let rec go items =
    let one = function
      | Type { name; decl; _ } ->
        ( Option.to_list
            (Option.map (marked Types name) ~f:(fun m ->
               { P.exported = exported m; decl = P.Type decl }))
        , [] )
      | Value b ->
        (match marked Values b.value.name with
         | None -> [], []
         | Some m -> [ { P.exported = exported m; decl = P.Value b.value } ], [ field b ])
      | Application { binding = b; _ } ->
        (match marked Values b.value.name with
         | None -> [], []
         | Some m ->
           let bound =
             List.filter_map
               (Ts_names.methods_of names b.value.name)
               ~f:(fun (source, fields) ->
                 match
                   List.filter fields ~f:(fun (_, local) ->
                     Option.is_some (marked Values local))
                 with
                 | [] -> None
                 | fields ->
                   Some { P.exported = false; decl = P.Members { fields; source } })
           in
           { P.exported = exported m; decl = P.Value b.value } :: bound, [ field b ])
      | Lifted v ->
        ( Option.to_list
            (Option.map (marked Values v.name) ~f:(fun _ ->
               { P.exported = false; decl = P.Value v }))
        , [] )
      | Group { holder; members } ->
        (match
           List.filter_map members ~f:(fun b ->
             Option.map (marked Values b.value.name) ~f:(fun m -> b, m))
         with
         | [] -> [], []
         | kept -> group holder kept, List.map kept ~f:(fun (b, _) -> field b))
      | Module { name; body; _ } ->
        let decls, object_ =
          match body with
          | Items items ->
            let decls, fields = go items in
            decls, P.Module_object fields
          | Alias target -> [], target
        in
        ( (match marked Values name with
           | Some m ->
             decls
             @ [ { P.exported = exported m
                 ; decl = P.Value { name; ty = None; value = object_ }
                 }
               ]
           | None -> decls)
        , [] )
      | Nested { name; flat; body = Items items } ->
        let decls, fields = go items in
        (match marked Values flat with
         | Some m ->
           ( decls
             @ [ { P.exported = exported m
                 ; decl =
                     P.Value { name = flat; ty = None; value = P.Module_object fields }
                 }
               ]
           , [ name, P.Var flat ] )
         | None -> decls, [ name, P.Module_object fields ])
      | Nested { name; body = Alias target; _ } -> [], [ name, target ]
    in
    let emitted = List.map items ~f:one in
    List.concat_map emitted ~f:fst, List.concat_map emitted ~f:snd
  in
  fst (go items)
;;

let header () =
  match Table.file_comment () with
  | "" -> None
  | s -> Some s
;;

let requested struc (globals, modules) =
  List.map globals ~f:(Ts_alias.global struc) @ globals, modules
;;

let prepare_unary env struc =
  let rec elements sel = List.concat_map sel ~f:(fun (_, se) -> element se)
  and element = function
    | SEdecl (Dterm (r, body, _)) -> [ r, body, [| r |] ]
    | SEdecl (Dfix (rs, bodies, _)) ->
      Array.to_list (Array.mapi rs ~f:(fun i r -> r, bodies.(i), rs))
    | SEmodule { ml_mod_expr; _ } -> expression ml_mod_expr
    | SEdecl (Dind _ | Dtype _) | SEmodtype _ -> []
  and expression = function
    | MEstruct (_, sel) -> elements sel
    | MEfunctor (_, _, body) -> expression body
    | MEident _ | MEapply _ -> []
  in
  let definitions = List.concat_map struc ~f:(fun (_, sel) -> elements sel) in
  let arithmetic (r, body, recursive) =
    let term = Ts_env.term env r in
    let params, result = Ts_type.split term.arity term.schema.ty in
    match result with
    | Ts_type.Glob (({ glob = GlobRef.IndRef _; _ } as ind), [])
      when (not (Table.is_custom r)) && List.exists params ~f:(Ts_type.equal result) ->
      let open Option.Let_syntax in
      let%bind _ = (Ts_env.ind env ind).unary in
      let members = Refset.of_list (Array.to_list recursive) in
      let recurses = ref false in
      let rec inspect = function
        | MLfix _ -> recurses := true
        | MLglob r when Refset.mem r members -> recurses := true
        | ast -> Mlutil.ast_iter inspect ast
      in
      inspect body;
      Option.some_if !recurses ind
    | _ -> None
  in
  let blocked = List.filter_map definitions ~f:arithmetic in
  let candidate (r, body, recursive) =
    let term = Ts_env.term env r in
    if
      Table.is_custom r
      || term.arity <> 2
      || (not (List.is_empty term.schema.tparams))
      || Array.length recursive <> 1
    then None
    else (
      match Ts_infer.declaration env r body with
      | e, _, _ -> Some (r, e)
      | exception Ts_type.Lost -> None)
  in
  let candidates = List.filter_map definitions ~f:candidate in
  let blocked = Refset.of_list blocked in
  let orders, inputs =
    List.fold
      candidates
      ~init:(Table.Refmap'.empty, [])
      ~f:(fun (orders, inputs) (r, e) ->
        match Ts_expr.unary_order env ~self:r e with
        | Some order when not (Refset.mem (Ts_expr.unary_input env order) blocked) ->
          Table.Refmap'.add r order orders, Ts_expr.unary_input env order :: inputs
        | Some _ | None -> orders, inputs)
  in
  let replacements =
    List.fold candidates ~init:Table.Refmap'.empty ~f:(fun replacements (r, e) ->
      match Ts_expr.cancel_unary_successor env ~orders e with
      | Some body -> Table.Refmap'.add r body replacements
      | None -> replacements)
  in
  let body r original =
    Option.value (Table.Refmap'.find_opt r replacements) ~default:original
  in
  let rec rewrite_elements sel =
    List.map sel ~f:(fun (label, se) -> label, rewrite_element se)
  and rewrite_element = function
    | SEdecl (Dterm (r, original, ty)) -> SEdecl (Dterm (r, body r original, ty))
    | SEdecl (Dfix (rs, bodies, tys)) ->
      SEdecl
        (Dfix (rs, Array.mapi bodies ~f:(fun i original -> body rs.(i) original), tys))
    | SEmodule m -> SEmodule { m with ml_mod_expr = rewrite_expression m.ml_mod_expr }
    | (SEdecl (Dind _ | Dtype _) | SEmodtype _) as se -> se
  and rewrite_expression = function
    | MEstruct (mp, sel) -> MEstruct (mp, rewrite_elements sel)
    | MEfunctor (id, mt, body) -> MEfunctor (id, mt, rewrite_expression body)
    | (MEident _ | MEapply _) as me -> me
  in
  ( Ts_env.optimise_unary env inputs
  , List.map struc ~f:(fun (mp, sel) -> mp, rewrite_elements sel) )
;;

let prepare state ~separate struc =
  let struc = Ts_known.reduce (Ts_alias.resolve struc) ~separate in
  let sigs = Ts_sig.create struc in
  let env, struc = prepare_unary (Ts_env.create state sigs struc) struc in
  let sigs = Ts_sig.create struc in
  struc, sigs, env, Ts_names.create state sigs struc
;;

let structure state ~requested:asked struc =
  let struc, sigs, env, names = prepare state ~separate:false struc in
  let where = top_level sigs (requested struc asked) in
  let names = Ts_names.bind_methods names (List.concat_map struc ~f:snd) in
  let items, casts =
    concat (List.map struc ~f:(fun (mp, sel) -> place env names where mp sel))
  in
  let items =
    kind_helpers
      (List.fold struc ~init:0 ~f:(fun n (mp, _) -> max n (Ts_sig.kinds sigs mp)))
    @ items
  in
  let marked = mark (nodes names ~file:"" items) in
  let decls = emit names marked ~file:"" items in
  P.program { header = header (); imports = []; decls }, { unchecked_casts = casts }
;;

let files state ~requested:asked struc =
  let struc, sigs, env, names = prepare state ~separate:true struc in
  let where = top_level sigs (requested struc asked) in
  let place_file (mp, sel) =
    match mp with
    | ModPath.MPfile dp ->
      let names = Ts_names.in_file names mp sel in
      Hashtbl.clear where.lambdas;
      let items, casts = place env names where mp sel in
      let items = kind_helpers (Ts_sig.kinds sigs mp) @ items in
      (Ts_names.file_name names dp, names, items), casts
    | ModPath.MPdot _ | ModPath.MPbound _ ->
      CErrors.anomaly (Pp.str "Typescript.files: a separate extraction has files only.")
  in
  let placed, casts = List.unzip (List.map struc ~f:place_file) in
  let marked =
    mark (List.concat_map placed ~f:(fun (file, names, items) -> nodes names ~file items))
  in
  (* A file with no declaration is not written, since an empty file fails
     the lint. *)
  let print (file, names, items) =
    match emit names marked ~file items with
    | [] -> None
    | decls ->
      let roots decls =
        let values, types =
          List.unzip (List.map decls ~f:(fun (t : P.top) -> P.reads t.decl))
        in
        let names paths =
          Set.of_list (module String) (List.map (List.concat paths) ~f:fst)
        in
        names values, names types
      in
      let values, types = roots decls in
      let used = Set.union values types in
      let bindings =
        List.filter_map (Ts_names.bindings names) ~f:(fun (source, fields) ->
          match List.filter fields ~f:(fun (_, local) -> Set.mem used local) with
          | [] -> None
          | fields -> Some { P.exported = false; decl = P.Members { fields; source } })
      in
      let bound_values, bound_types = roots bindings in
      let values = Set.union values bound_values
      and types = Set.union types bound_types in
      (* A file referred to in type positions only is imported as types,
         which consistent-type-imports asks. *)
      let imports =
        List.filter_map (Ts_names.imports names) ~f:(fun (alias, file) ->
          if Set.mem values alias
          then Some { P.alias; file; type_only = false }
          else if Set.mem types alias
          then Some { P.alias; file; type_only = true }
          else None)
      in
      Some (file, P.program { header = header (); imports; decls = bindings @ decls })
  in
  List.filter_map placed ~f:print, { unchecked_casts = List.fold casts ~init:0 ~f:( + ) }
;;

let declaration state struc r =
  let struc, sigs, env, names = prepare state ~separate:false struc in
  let r = Ts_alias.global struc r in
  let d = Modutil.get_decl_in_structure r struc in
  let items, casts = lower env names (top_level sigs (declared d, [])) d in
  let decls = emit names (mark (nodes names ~file:"" items)) ~file:"" items in
  P.program { header = None; imports = []; decls }, { unchecked_casts = casts }
;;
