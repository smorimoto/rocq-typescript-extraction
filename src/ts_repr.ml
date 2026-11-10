open Import
open Names
open Extraction_plugin
open Miniml
module P = Ts_print

type custom =
  { match_code : string option
  ; selectors : Ts_match.selector array option
  }

type ctor =
  { fields : string list
  ; params : int list
  }

type t =
  | Tagged of ctor array
  | Record of string list
  | Lazy of ctor array
  | Erased
  | Custom of custom

let positional n = List.init n ~f:(fun k -> "arg" ^ Int.to_string k)
let discriminant_field = "tag"
let distinct names = not (List.contains_dup names ~compare:String.compare)

(* The kernel's environment has every module and module type declared at
   the top level or in a module, and the body of a functor or of a module
   type is reached through the one around it. A module sealed by a module
   type keeps its body apart from its type, and the body is where its
   inductives are. *)
let rec structure_body env mp =
  let rec fields = function
    | Declarations.NoFunctor body -> body
    | Declarations.MoreFunctor (_, _, inner) -> fields inner
  in
  let module_body mb =
    match Mod_declarations.mod_expr mb with
    | Mod_declarations.Struct (_, body) -> body
    | Mod_declarations.Abstract | Algebraic _ | FullStruct ->
      fields (Mod_declarations.mod_type mb)
  in
  let direct =
    match Environ.lookup_module mp env with
    | mb -> Some (module_body mb)
    | exception Stdlib.Not_found ->
      (match Environ.lookup_modtype mp env with
       | mtb -> Some (fields (Mod_declarations.mod_type mtb))
       | exception Stdlib.Not_found -> None)
  in
  match direct, mp with
  | Some _, _ -> direct
  | None, ModPath.MPdot (parent, l) ->
    let open Option.Let_syntax in
    let%bind body = structure_body env parent in
    (match%bind List.find body ~f:(fun (id, _) -> Id.equal id l) with
     | _, Declarations.SFBmodule mb -> Some (module_body mb)
     | _, Declarations.SFBmodtype mtb -> Some (fields (Mod_declarations.mod_type mtb))
     | _, (Declarations.SFBconst _ | SFBmind _ | SFBrules _) -> None)
  | None, ModPath.(MPfile _ | MPbound _) -> None
;;

(* The kernel's environment holds no inductive declared in a module type
   or in the body of a functor, which the fields of the module type or of
   the functor hold. *)
let mutual_inductive env kn =
  if Environ.mem_mind kn env
  then Some (Environ.lookup_mind kn env)
  else
    let open Option.Let_syntax in
    let%bind body = structure_body env (MutInd.modpath kn) in
    match%bind List.find body ~f:(fun (id, _) -> Id.equal id (MutInd.label kn)) with
    | _, Declarations.SFBmind mib -> Some mib
    | _, (Declarations.SFBconst _ | SFBrules _ | SFBmodule _ | SFBmodtype _) -> None
;;

(* The kernel keeps the binder names of a constructor's arguments after its
   parameters. MiniML drops logical and implicit arguments, so the names
   apply only when the counts agree. *)
let binder_fields ~scope (c : global) n =
  match c.glob with
  | GlobRef.ConstructRef ((kn, i), j) ->
    let env = Option.value (scope (MutInd.modpath kn)) ~default:(Global.env ()) in
    (match mutual_inductive env kn with
     | None -> positional n
     | Some mib ->
       let ctx, _ = Term.decompose_prod_decls mib.mind_packets.(i).mind_user_lc.(j - 1) in
       let args =
         List.filter
           (List.drop (List.rev ctx) (List.length mib.mind_params_ctxt))
           ~f:Context.Rel.Declaration.is_local_assum
       in
       let names =
         List.map args ~f:(fun d ->
           match Context.Rel.Declaration.get_name d with
           | Name id -> Ts_names.camel id
           | Anonymous -> "")
       in
       if
         List.length names = n
         && List.for_all names ~f:(fun f ->
           String.( <> ) f ""
           && String.( <> ) f discriminant_field
           && not (Ts_names.is_reserved f))
         && distinct names
       then names
       else positional n)
  | GlobRef.VarRef _ | GlobRef.ConstRef _ | GlobRef.IndRef _ -> positional n
;;

let ctors (p : ml_ind_packet) ~kernel ~signature ~scope =
  Array.mapi p.ip_consnames_ref ~f:(fun j c ->
    let args = p.ip_types.(j) in
    { fields = binder_fields ~scope (kernel c) (List.length args)
    ; params =
        Ts_type.vars
          (match signature c with
           | Some (k : Ts_kernel.ctor) -> k.args
           | None -> List.map args ~f:Ts_type.of_ml)
    })
;;

let record_fields projs =
  let base k proj =
    let f =
      match proj with
      | Some r -> Ts_names.camel (Table.label_of_r r)
      | None -> ""
    in
    if String.equal f "" then "arg" ^ Int.to_string k else f
  in
  let unique k used proj =
    let base = base k proj in
    let rec go i =
      let f = if i < 0 then base else base ^ Int.to_string i in
      if List.mem used f ~equal:String.equal then go (i + 1) else f
    in
    let f = go (-1) in
    f :: used, f
  in
  List.folding_mapi projs ~init:[] ~f:unique
;;

let selectors (p : ml_ind_packet) =
  let r = p.ip_typename_ref in
  Option.map (Ts_match.find r) ~f:(fun selectors ->
    let directive =
      Pp.(str "TypeScript Extract Match for " ++ Printer.pr_global r.glob)
    in
    Array.iteri selectors ~f:(fun j (sel : Ts_match.selector) ->
      let kept = List.length p.ip_types.(j)
      and given = List.length sel.args in
      if kept <> given
      then
        CErrors.user_err
          Pp.(
            directive
            ++ str " gives "
            ++ int given
            ++ str " expressions for the arguments of "
            ++ Printer.pr_global p.ip_consnames_ref.(j).glob
            ++ str ", but extraction keeps "
            ++ int kept
            ++ str ".");
      List.iter
        (Option.to_list sel.test @ sel.args)
        ~f:(fun code ->
          if not (Ts_print.balanced code)
          then
            CErrors.user_err
              Pp.(
                str "The TypeScript code "
                ++ qstring code
                ++ str " of "
                ++ directive
                ++ str " does not balance its brackets and quotes.")));
    selectors)
;;

let decide
      ?(kernel = Fn.id)
      ?(signature = fun _ -> None)
      ?(scope = fun _ -> None)
      (ind : ml_ind)
      i
  =
  let p = ind.ind_packets.(i) in
  let selectors = selectors p in
  if Table.is_custom p.ip_typename_ref
  then Custom { match_code = Ts_names.custom_match p; selectors }
  else (
    if Option.is_some selectors
    then
      CErrors.user_err
        Pp.(
          str "TypeScript Extract Match for "
          ++ Printer.pr_global p.ip_typename_ref.glob
          ++ str " needs Extract Inductive "
          ++ Printer.pr_global p.ip_typename_ref.glob
          ++ str ", which maps the type the tests read.");
    match ind.ind_kind with
    | Singleton -> Erased
    | Record projs -> Record (record_fields projs)
    | Coinductive -> Lazy (ctors p ~kernel ~signature ~scope)
    | Standard -> Tagged (ctors p ~kernel ~signature ~scope))
;;

type unary =
  { zero : global
  ; successor : global
  ; predecessor : string
  }

let unary ?(signature = fun _ -> None) (p : ml_ind_packet) repr =
  let args j c =
    match signature c with
    | Some (k : Ts_kernel.ctor) when List.is_empty k.lifted -> Some k.args
    | Some _ -> None
    | None -> Some (List.map p.ip_types.(j) ~f:Ts_type.of_ml)
  in
  match repr with
  | Tagged cs
    when List.is_empty p.ip_vars
         && Array.length cs = 2
         && (not (Table.is_custom p.ip_typename_ref))
         && Array.for_all p.ip_consnames_ref ~f:(fun c -> not (Table.is_custom c)) ->
    let shapes = Array.mapi p.ip_consnames_ref ~f:args in
    let pair zero successor =
      match shapes.(zero), shapes.(successor), cs.(zero), cs.(successor) with
      | ( Some []
        , Some [ Ts_type.Glob (r, []) ]
        , { fields = []; params = [] }
        , { fields = [ predecessor ]; params = [] } )
        when Table.Refset'.mem r (Table.Refset'.singleton p.ip_typename_ref) ->
        Some
          { zero = p.ip_consnames_ref.(zero)
          ; successor = p.ip_consnames_ref.(successor)
          ; predecessor
          }
      | _ -> None
    in
    Option.first_some (pair 0 1) (pair 1 0)
  | Tagged _ | Record _ | Lazy _ | Erased | Custom _ -> None
;;

let unary_descriptor names shape =
  List.map
    [ discriminant_field
    ; Ts_names.tag names shape.zero
    ; Ts_names.tag names shape.successor
    ; shape.predecessor
    ]
    ~f:(fun s -> P.Text s)
;;

type declared =
  { types : P.type_decl list
  ; values : (global * P.value) list
  }

let pick params tys = List.map params ~f:(fun v -> List.nth_exn tys (v - 1))

(* TypeScript narrows a const of a union type to the type of its
   initialiser, so a constructor function of a union type builds a value
   of the union, with never for the type parameters it does not mention,
   and a match on a const it initialises typechecks. A
   constant constructor is typed with its interface, which mentions no
   type parameter, so it is assignable to every instance of the union
   whatever the variance of the other constructors. A constructor of a
   type that is not a union builds its interface, as does the cell of a
   coinductive type, which the thunk around it keeps from narrowing. *)
let constructors
      names
      (p : ml_ind_packet)
      tvars
      ~signature
      (cs : ctor array)
      ~of_union
      ~freeze
  =
  let tps = Ts_names.tparams tvars in
  let implicit c = Ts_names.implicit_params names c in
  let own j c =
    match signature c with
    | Some (k : Ts_kernel.ctor) ->
      let tvars, decls =
        Ts_names.signature
          names
          (List.map p.ip_vars ~f:(fun id -> { Ts_type.hint = Some id; bound = None })
           @ k.lifted)
      in
      ( pick cs.(j).params decls
      , List.map k.args ~f:(Ts_names.ty names tvars)
      , k.lifted
      , tvars )
    | None ->
      ( P.unbounded (pick cs.(j).params tps)
      , List.map p.ip_types.(j) ~f:(fun t -> Ts_names.ty names tvars (Ts_type.of_ml t))
      , []
      , tvars )
  in
  let owns = Array.mapi p.ip_consnames_ref ~f:own in
  let fn_tparams j =
    let tparams, _, _, _ = owns.(j) in
    tparams
  in
  let tparams j c =
    List.map (fn_tparams j) ~f:(fun (t : P.tparam) -> t.name) @ implicit c
  in
  let interface j c =
    P.Name
      (Ts_names.interface_ref names c, List.map (tparams j c) ~f:(fun v -> P.Name (v, [])))
  in
  let lifts j =
    let _, _, lifted, _ = owns.(j) in
    not (List.is_empty lifted)
  in
  let built j c =
    if of_union && not (lifts j)
    then (
      let own = tparams j c in
      P.Name
        ( Ts_names.type_ref names p.ip_typename_ref
        , List.map tps ~f:(fun v ->
            P.Name ((if List.mem own v ~equal:String.equal then v else "never"), []))
          @ List.map (implicit p.ip_typename_ref) ~f:(fun v -> P.Name (v, [])) ))
    else interface j c
  in
  let instances j c =
    let _, _, lifted, tvars = owns.(j) in
    if List.is_empty lifted
    then [ interface j c ]
    else (
      let nb = List.length p.ip_vars in
      let choices =
        List.map lifted ~f:(fun (l : Ts_type.tparam) ->
          match l.bound with
          | Some (Ts_type.Glob (r, [])) -> Ts_kernel.constructors r
          | Some _ | None ->
            CErrors.anomaly (Pp.str "Ts_repr.constructors: a bound is an enumeration."))
      in
      List.map (List.Cartesian_product.all choices) ~f:(fun picked ->
        let arg v =
          if v <= nb
          then P.Name (List.nth_exn tps (v - 1), [])
          else
            Ts_names.ty names tvars (Ts_type.Glob (List.nth_exn picked (v - nb - 1), []))
        in
        P.Name
          ( Ts_names.interface_ref names c
          , List.map cs.(j).params ~f:arg
            @ List.map (implicit c) ~f:(fun v -> P.Name (v, [])) )))
  in
  let union =
    match List.concat (Array.to_list (Array.mapi p.ip_consnames_ref ~f:instances)) with
    | [] -> P.Name ("never", [])
    | [ member ] -> member
    | members -> P.Union members
  in
  let constructor j c =
    let { fields; _ } = cs.(j) in
    let _, types, _, _ = owns.(j) in
    let tag = Ts_names.tag names c in
    let decl =
      P.Interface
        { name = Ts_names.interface_name names c
        ; tparams = fn_tparams j @ P.unbounded (implicit c)
        ; fields = (discriminant_field, P.Literal tag) :: List.zip_exn fields types
        }
    in
    let name = Ts_names.value_name names c in
    let tagged = discriminant_field, P.Text tag in
    let args =
      List.folding_map fields ~init:(Ts_names.avoid names) ~f:(fun avoid f ->
        let p, avoid = Ts_names.reserve avoid f in
        avoid, p)
    in
    let frozen = freeze in
    let freeze e =
      if frozen then P.Call (P.Field (P.Var "Object", "freeze"), [], [ e ]) else e
    in
    let value =
      match fields with
      | [] -> { P.name; ty = Some (interface j c); value = freeze (P.Record [ tagged ]) }
      | fields ->
        let params = List.zip_exn args types in
        let result = built j c in
        let build =
          P.Arrow
            ( fn_tparams j
            , params
            , Some result
            , P.Expr
                (P.Record (tagged :: List.map2_exn fields args ~f:(fun f a -> f, P.Var a)))
            )
        in
        if frozen
        then
          { P.name
          ; ty = Some (P.Fn { tparams = []; params; result })
          ; value = P.Call (P.Helper P.Unary_constructor, [ result ], [ build ])
          }
        else { P.name; ty = None; value = build }
    in
    decl, (c, value)
  in
  let declarations, values =
    List.unzip (Array.to_list (Array.mapi p.ip_consnames_ref ~f:constructor))
  in
  declarations, values, union
;;

let declare
      ?(freeze = false)
      ?(signature = fun _ -> None)
      ?(fields = fun _ -> [])
      names
      (ind : ml_ind)
      i
      repr
  =
  let p = ind.ind_packets.(i) in
  let tvars = Ts_names.named names p.ip_vars in
  let tps = Ts_names.tparams tvars @ Ts_names.implicit_params names p.ip_typename_ref in
  let ty t = Ts_names.ty names tvars (Ts_type.of_ml t) in
  let self () = Ts_names.type_name names p.ip_typename_ref in
  let alias def = P.Alias { name = self (); tparams = P.unbounded tps; def } in
  match repr with
  | Tagged cs ->
    let interfaces, values, union =
      constructors
        names
        p
        tvars
        ~signature
        cs
        ~of_union:(Array.length cs > 1)
        ~freeze:(freeze && Option.is_some (unary ~signature p repr))
    in
    { types = interfaces @ [ alias union ]; values }
  | Lazy cs ->
    let interfaces, values, union =
      constructors names p tvars ~signature cs ~of_union:false ~freeze:false
    in
    { types = interfaces @ [ alias (P.Fn { tparams = []; params = []; result = union }) ]
    ; values
    }
  | Record names_of_fields ->
    let args =
      match p.ip_types with
      | [| args |] -> args
      | _ -> CErrors.anomaly (Pp.str "Ts_repr.declare: a record has one constructor.")
    in
    let tparams, types =
      match signature p.ip_consnames_ref.(0), fields p.ip_typename_ref with
      | Some (k : Ts_kernel.ctor), (_ :: _ as type_fields) ->
        let tvars, decls =
          Ts_names.signature
            names
            (List.map p.ip_vars ~f:(fun id -> { Ts_type.hint = Some id; bound = None })
             @ type_fields)
        in
        ( decls @ P.unbounded (Ts_names.implicit_params names p.ip_typename_ref)
        , List.map k.args ~f:(Ts_names.ty names tvars) )
      | Some k, [] when List.is_empty k.lifted ->
        P.unbounded tps, List.map k.args ~f:(Ts_names.ty names tvars)
      | Some _, [] | None, _ -> P.unbounded tps, List.map args ~f:ty
    in
    { types =
        [ P.Interface
            { name = self (); tparams; fields = List.zip_exn names_of_fields types }
        ]
    ; values = []
    }
  | Erased ->
    (match p.ip_types with
     | [| [ t ] |] -> { types = [ alias (ty t) ]; values = [] }
     | _ ->
       CErrors.anomaly
         (Pp.str "Ts_repr.declare: a singleton has one constructor of one argument."))
  | Custom _ ->
    { types = []
    ; values =
        List.map (Ts_names.realisers p) ~f:(fun (r, code) ->
          ( r
          , { P.name = Ts_names.value_name names r
            ; ty = None
            ; value = P.Code (Ts_names.qualify_code names r ~params:[] code)
            } ))
    }
;;

let integer_constructor code args =
  let decimal s =
    let digits = if String.is_prefix s ~prefix:"-" then String.drop_prefix s 1 else s in
    if (not (String.is_empty digits)) && String.for_all digits ~f:Char.is_digit
    then (
      let value = Z.of_string s in
      if String.equal (Z.to_string value) s then Some value else None)
    else None
  in
  let literal ~bigint = function
    | P.Bigint s when bigint -> decimal s
    | P.Number s when not bigint -> decimal s
    | P.Code s when bigint -> Option.bind (String.chop_suffix s ~suffix:"n") ~f:decimal
    | P.Code s -> decimal s
    | P.Var _
    | P.Helper _
    | P.Text _
    | P.Bytes _
    | P.Bigint _
    | P.Number _
    | P.Field _
    | P.Index _
    | P.Cell_read _
    | P.Tuple _
    | P.Call _
    | P.Arrow _
    | P.Cond _
    | P.Equals _
    | P.Not_equals _
    | P.Add _
    | P.Not _
    | P.Record _
    | P.Module_object _
    | P.Satisfies _ -> None
  in
  let realise ~bigint f =
    match args with
    | [ arg ] ->
      let open Option.Let_syntax in
      let%bind value = literal ~bigint arg in
      let result = f value in
      if bigint
      then Some (P.Bigint (Z.to_string result))
      else (
        let bound = Z.of_string "9007199254740991" in
        if Z.leq (Z.abs value) bound && Z.leq (Z.abs result) bound
        then (
          let negative_zero =
            Z.equal value Z.zero && String.equal code "((p: number): number => -p)"
          in
          Some (P.Number (if negative_zero then "-0" else Z.to_string result)))
        else None)
    | _ -> None
  in
  let double x = Z.shift_left x 1 in
  let odd x = Z.succ (double x) in
  match code with
  | "((p: bigint): bigint => 2n * p + 1n)" -> realise ~bigint:true odd
  | "((p: bigint): bigint => 2n * p)" -> realise ~bigint:true double
  | "((p: bigint): bigint => p)" -> realise ~bigint:true Fn.id
  | "((p: bigint): bigint => -p)" -> realise ~bigint:true Z.neg
  | "((p: number): number => 2 * p + 1)" -> realise ~bigint:false odd
  | "((p: number): number => 2 * p)" -> realise ~bigint:false double
  | "((p: number): number => p)" -> realise ~bigint:false Fn.id
  | "((p: number): number => -p)" -> realise ~bigint:false Z.neg
  | _ -> None
;;

let construct names repr ctor ~index ~explicit tyargs args =
  let tagged (c : ctor) =
    match args with
    | [] -> Ts_names.value names ctor
    | args ->
      P.Call
        (Ts_names.value names ctor, (if explicit then pick c.params tyargs else []), args)
  in
  match repr with
  | Tagged cs | Lazy cs -> tagged cs.(index)
  | Record fields -> P.Record (List.zip_exn fields args)
  | Custom _ ->
    (match args with
     | [] -> Ts_names.value names ctor
     | args ->
       (match integer_constructor (Ts_names.custom ctor) args with
        | Some literal -> literal
        | None -> P.Call (Ts_names.value names ctor, [], args)))
  | Erased ->
    CErrors.anomaly (Pp.str "Ts_repr.construct: a singleton has no constructor.")
;;

let delay names repr ctor ~index tyargs =
  match repr with
  | Lazy cs ->
    let cell =
      P.Name
        ( Ts_names.interface_ref names ctor
        , pick cs.(index).params tyargs @ Ts_names.implicit_args names ctor )
    in
    Some (fun body -> P.Call (P.Helper P.Lazy, [], [ P.Arrow ([], [], Some cell, body) ]))
  | Tagged _ | Record _ | Erased | Custom _ -> None
;;

let forced repr s =
  match repr with
  | Lazy _ -> Some (P.Call (s, [], []))
  | Tagged _ | Record _ | Erased | Custom _ -> None
;;

let discriminant repr s =
  match repr with
  | Tagged _ | Lazy _ -> P.Field (s, discriminant_field)
  | Custom _ -> s
  | Record _ | Erased ->
    CErrors.anomaly (Pp.str "Ts_repr.discriminant: a single-constructor type.")
;;

let label names repr ctor ~index =
  match repr with
  | Custom _ -> Ts_names.value names ctor
  | Tagged _ | Lazy _ -> P.Text (Ts_names.tag names ctor)
  | Record _ | Erased ->
    CErrors.anomaly (Pp.str "Ts_repr.label: a single-constructor type.")
;;

let field repr ~index s k =
  match repr with
  | Tagged cs | Lazy cs -> P.Field (s, List.nth_exn cs.(index).fields k)
  | Record fields -> P.Field (s, List.nth_exn fields k)
  | Erased | Custom _ -> CErrors.anomaly (Pp.str "Ts_repr.field: no fields to read.")
;;
