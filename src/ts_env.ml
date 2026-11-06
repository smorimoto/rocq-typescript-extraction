open Import
open Names
open Extraction_plugin
open Miniml
module Refmap = Table.Refmap'
module Refset = Table.Refset'

type term =
  { schema : Ts_type.schema
  ; arity : int
  }

type ind =
  { repr : Ts_repr.t
  ; unary : Ts_repr.unary option
  ; optimise_unary : bool
  ; nparams : int
  }

type ctor =
  { ind : global
  ; index : int
  ; args : Ts_type.t list
  ; lifted : Ts_type.tparam list
  }

type t =
  { terms : term Refmap.t
  ; refined : Refset.t
  ; inds : ind Refmap.t
  ; ctors : ctor Refmap.t
  ; abbrevs : ml_type Refmap.t
  ; kernel : Ts_kernel.t
  ; resolve : global -> global
  }

let rec expand_ml resolve abbrevs = function
  | Tmeta { contents = Some t; _ } -> expand_ml resolve abbrevs t
  | Tglob (r, args) ->
    let r = resolve r in
    (match Refmap.find_opt r abbrevs with
     | Some body -> expand_ml resolve abbrevs (Mlutil.type_subst_list args body)
     | None -> Tglob (r, List.map args ~f:(expand_ml resolve abbrevs)))
  | Tarr (a, b) -> Tarr (expand_ml resolve abbrevs a, expand_ml resolve abbrevs b)
  | (Tvar _ | Tvar' _ | Tmeta _ | Tdummy _ | Tunknown | Taxiom) as t -> t
;;

let rec expand_type resolve abbrevs = function
  | Ts_type.Glob (r, args) ->
    let r = resolve r in
    (match Refmap.find_opt r abbrevs with
     | Some body -> expand_type resolve abbrevs (Ts_type.subst args (Ts_type.of_ml body))
     | None -> Ts_type.Glob (r, List.map args ~f:(expand_type resolve abbrevs)))
  | Ts_type.Arrow (a, b) ->
    Ts_type.Arrow (expand_type resolve abbrevs a, expand_type resolve abbrevs b)
  | Ts_type.Tuple ts -> Ts_type.Tuple (List.map ts ~f:(expand_type resolve abbrevs))
  | Ts_type.Union ts -> Ts_type.Union (List.map ts ~f:(expand_type resolve abbrevs))
  | Ts_type.Cond { on; arms } ->
    Ts_type.Cond
      { on = expand_type resolve abbrevs on
      ; arms = List.map arms ~f:(fun (c, t) -> resolve c, expand_type resolve abbrevs t)
      }
  | Ts_type.Forall (vs, t) -> Ts_type.Forall (vs, expand_type resolve abbrevs t)
  | (Ts_type.Var _ | Ts_type.Meta _ | Ts_type.Erased | Ts_type.Never) as t -> t
;;

let map_params ps ~f =
  List.map ps ~f:(fun (p : Ts_type.tparam) -> { p with bound = Option.map p.bound ~f })
;;

let map_schema (s : Ts_type.schema) ~f =
  { Ts_type.tparams = map_params s.tparams ~f; ty = f s.ty }
;;

let map_ctor (c : Ts_kernel.ctor) ~f =
  { Ts_kernel.lifted = map_params c.lifted ~f; args = List.map c.args ~f }
;;

let expand_with resolve abbrevs t = Ts_type.of_ml (expand_ml resolve abbrevs t)
let expand env t = expand_ml env.resolve env.abbrevs t

type source =
  | Decl of
      { in_module : bool
      ; decl : ml_decl
      }
  | Members of ModPath.t * ml_module_sig

let rec sources sigs ~parent sel =
  let in_module =
    match parent with
    | MPfile _ -> false
    | MPdot _ | MPbound _ -> true
  in
  List.concat_map sel ~f:(fun (l, se) ->
    let at = MPdot (parent, l) in
    match se with
    | SEdecl decl -> [ Decl { in_module; decl } ]
    | SEmodtype mt ->
      (match Ts_sig.functor_signature sigs mt with
       | Some { parameters; result } ->
         List.map parameters ~f:(fun (id, mt) ->
           let at = MPbound id in
           Members (at, Ts_sig.resolve sigs ~at mt))
         @ [ Members (at, Ts_sig.resolve sigs ~at result) ]
       | None -> [ Members (at, Ts_sig.resolve sigs ~at mt) ])
    | SEmodule { ml_mod_expr = MEstruct (mp, sel'); _ } -> sources sigs ~parent:mp sel'
    | SEmodule { ml_mod_expr = MEfunctor _; ml_mod_type } ->
      (match Ts_sig.functor_ sigs at with
       | Some { params; body } ->
         List.map params ~f:(fun (id, mt) ->
           let at = MPbound id in
           Members (at, Ts_sig.resolve sigs ~at mt))
         @
           (match body, Ts_sig.functor_signature sigs ml_mod_type with
           | Ts_sig.Structure (mp, sel'), _ -> sources sigs ~parent:mp sel'
           | Ts_sig.Applied (MEident _), Some { result = MTsig (mp, members); _ } ->
             [ Members (mp, members) ]
           | Ts_sig.Applied _, _ -> [])
       | None ->
         CErrors.anomaly (Pp.str "Ts_env.sources: a functor the module types miss."))
    | SEmodule { ml_mod_expr = MEapply _; ml_mod_type } ->
      [ Members (at, Ts_sig.resolve sigs ~at ml_mod_type) ]
    | SEmodule { ml_mod_expr = MEident _; _ } -> [])
;;

let singleton_abbreviations ind =
  List.filter_map (Array.to_list ind.ind_packets) ~f:(fun (p : ml_ind_packet) ->
    match p.ip_types with
    | [| [ t ] |] when not (Table.is_custom p.ip_typename_ref) ->
      Some (p.ip_typename_ref, t)
    | _ -> None)
;;

let abbreviation ~kernel = function
  | Dtype (r, _, t)
    when (not (Table.is_custom r))
         && (not (phys_equal t Taxiom))
         && Option.is_none (Ts_kernel.alias kernel r) -> [ r, t ]
  | Dind ({ ind_kind = Singleton; _ } as ind) -> singleton_abbreviations ind
  | Dind _ | Dtype _ | Dterm _ | Dfix _ -> []
;;

let module_members sigs ~at mt =
  let mt =
    match Ts_sig.functor_signature sigs mt with
    | Some { result; _ } -> result
    | None -> mt
  in
  Ts_sig.resolve sigs ~at mt
;;

let rec sig_abbreviations sigs ~at members =
  List.concat_map members ~f:(fun (l, s) ->
    match s with
    | Spec (Stype (r, _, Some t)) when not (Table.is_custom r) -> [ r, t ]
    | Spec (Stype (r, _, None)) when not (Table.is_custom r) ->
      (match Ts_sig.sealed sigs r with
       | Some (_, t) -> [ r, t ]
       | None -> [])
    | Spec (Sind ({ ind_kind = Singleton; _ } as ind)) -> singleton_abbreviations ind
    | Smodule mt ->
      let at = MPdot (at, l) in
      sig_abbreviations sigs ~at (module_members sigs ~at mt)
    | Spec (Stype _ | Sval _ | Sind _) | Smodtype _ -> [])
;;

let rec atomic = function
  | MLrel _ | MLdummy _ | MLuint _ | MLfloat _ | MLstring _ -> true
  | MLglob r -> not (Table.is_inline_custom r)
  | MLcons (_, _, args) -> List.for_all args ~f:atomic
  | MLapp _
  | MLlam _
  | MLletin _
  | MLtuple _
  | MLcase _
  | MLfix _
  | MLexn _
  | MLaxiom _
  | MLmagic _
  | MLparray _ -> false
;;

let residual_arity terms body =
  let callee g =
    match Refmap.find_opt g terms with
    | Some { arity; _ } -> arity
    | None -> 0
  in
  match snd (Mlutil.collect_lams body) with
  | MLglob g -> callee g
  | MLapp (MLglob g, args) when List.for_all args ~f:atomic ->
    max 0 (callee g - List.length args)
  | _ -> 0
;;

let arrows t = List.length (fst (Mlutil.type_decomp t))

let term_arity terms ~in_module resolve abbrevs r body t =
  if in_module
  then arrows t
  else (
    let arrows = arrows (expand_ml resolve abbrevs t) in
    match body with
    | _ when Table.is_custom r -> arrows
    | MLaxiom _ | MLexn _ -> arrows
    | body -> min (Mlutil.nb_lams body + residual_arity terms body) arrows)
;;

let create state sigs struc =
  let kernel_types = Ts_kernel.create state struc in
  let resolve = Ts_alias.global struc in
  let signature r =
    Option.map
      (Ts_kernel.ctor kernel_types r)
      ~f:(map_ctor ~f:(expand_type resolve Refmap.empty))
  in
  let srcs = List.concat_map struc ~f:(fun (mp, sel) -> sources sigs ~parent:mp sel) in
  let abbrevs =
    List.fold
      (List.concat_map srcs ~f:(function
         | Decl { decl; _ } -> abbreviation ~kernel:kernel_types decl
         | Members (at, members) -> sig_abbreviations sigs ~at members))
      ~init:Refmap.empty
      ~f:(fun m (r, t) -> Refmap.add r t m)
  in
  let kernel = Ts_sig.canon sigs in
  let term terms ~in_module r body t =
    let schema =
      match Ts_kernel.term kernel_types r with
      | Some s -> map_schema s ~f:(expand_type resolve abbrevs)
      | None -> Ts_type.schema (Mlutil.type_maxvar t) (expand_with resolve abbrevs t)
    in
    { schema; arity = term_arity terms ~in_module resolve abbrevs r body t }
  in
  let refine refined r =
    if Option.is_some (Ts_kernel.term kernel_types r)
    then Refset.add r refined
    else refined
  in
  let add_packet ind i env (p : ml_ind_packet) =
    if p.ip_logical
    then env
    else (
      let ind_r = p.ip_typename_ref in
      let repr =
        Ts_repr.decide ~kernel ~signature ~scope:(Ts_kernel.scope kernel_types) ind i
      in
      let entry =
        { repr
        ; unary = Ts_repr.unary ~signature p repr
        ; optimise_unary = false
        ; nparams =
            List.length p.ip_vars
            + List.length (Ts_kernel.fields kernel_types p.ip_typename_ref)
        }
      in
      let add_ctor j ctors c =
        let args, lifted =
          match signature c with
          | Some k ->
            let k = map_ctor k ~f:(expand_type resolve abbrevs) in
            k.args, k.lifted
          | None -> List.map p.ip_types.(j) ~f:(expand_with resolve abbrevs), []
        in
        Refmap.add c { ind = ind_r; index = j; args; lifted } ctors
      in
      let ctors = Array.foldi p.ip_consnames_ref ~init:env.ctors ~f:add_ctor in
      { env with inds = Refmap.add ind_r entry env.inds; ctors })
  in
  let add_decl env ~in_module = function
    | Dterm (r, body, t) ->
      { env with
        terms = Refmap.add r (term env.terms ~in_module r body t) env.terms
      ; refined = refine env.refined r
      }
    | Dfix (rv, av, tv) ->
      let add_member i terms r =
        Refmap.add r (term env.terms ~in_module r av.(i) tv.(i)) terms
      in
      { env with
        terms = Array.foldi rv ~init:env.terms ~f:add_member
      ; refined = Array.fold rv ~init:env.refined ~f:refine
      }
    | Dind ind -> Array.foldi ind.ind_packets ~init:env ~f:(add_packet ind)
    | Dtype _ -> env
  in
  let rec add_members env ~at members =
    List.fold members ~init:env ~f:(fun env (l, s) ->
      match s with
      | Spec (Sval (r, t)) ->
        let arity =
          match Refmap.find_opt (kernel r) env.terms with
          | Some { arity; _ } -> arity
          | None -> arrows t
        in
        let schema, refined =
          match Ts_kernel.member kernel_types r t with
          | Some s ->
            map_schema s ~f:(expand_type resolve abbrevs), Refset.add r env.refined
          | None ->
            ( Ts_type.schema (Mlutil.type_maxvar t) (expand_with resolve abbrevs t)
            , env.refined )
        in
        { env with terms = Refmap.add r { schema; arity } env.terms; refined }
      | Spec (Sind ind) -> Array.foldi ind.ind_packets ~init:env ~f:(add_packet ind)
      | Smodule mt ->
        let at = MPdot (at, l) in
        add_members env ~at (module_members sigs ~at mt)
      | Spec (Stype _) | Smodtype _ -> env)
  in
  let add env = function
    | Decl { in_module; decl } -> add_decl env ~in_module decl
    | Members (at, members) -> add_members env ~at members
  in
  List.fold
    srcs
    ~init:
      { terms = Refmap.empty
      ; refined = Refset.empty
      ; inds = Refmap.empty
      ; ctors = Refmap.empty
      ; abbrevs
      ; kernel = kernel_types
      ; resolve
      }
    ~f:add
;;

let signature env c =
  Option.map
    (Ts_kernel.ctor env.kernel c)
    ~f:(map_ctor ~f:(expand_type env.resolve Refmap.empty))
;;

let fields env r = Ts_kernel.fields env.kernel r

let alias env r =
  Option.map
    (Ts_kernel.alias env.kernel (env.resolve r))
    ~f:(map_schema ~f:(expand_type env.resolve Refmap.empty))
;;

let missing_dependencies env sigs struc =
  let declared = ref Refset.empty in
  let needed = ref Refset.empty in
  let add set r = set := Refset.add (Ts_sig.canon sigs r) !set in
  let rec ty t =
    match Ts_type.resolve t with
    | Ts_type.Glob (r, args) ->
      add needed r;
      List.iter args ~f:ty
    | Ts_type.Arrow (a, b) ->
      ty a;
      ty b
    | Ts_type.Tuple ts | Ts_type.Union ts -> List.iter ts ~f:ty
    | Ts_type.Cond { on; arms } ->
      ty on;
      List.iter arms ~f:(fun (c, t) ->
        add needed c;
        ty t)
    | Ts_type.Forall (_, t) -> ty t
    | Ts_type.Var _ | Ts_type.Meta _ | Ts_type.Erased | Ts_type.Never -> ()
  in
  let params ps =
    List.iter ps ~f:(fun (p : Ts_type.tparam) -> Option.iter p.bound ~f:ty)
  in
  let schema (s : Ts_type.schema) =
    params s.tparams;
    ty s.ty
  in
  let ind ind =
    Array.iter ind.ind_packets ~f:(fun p ->
      add declared p.ip_typename_ref;
      Array.iter p.ip_consnames_ref ~f:(add declared))
  in
  let decl = function
    | Dtype (r, _, _) ->
      add declared r;
      Option.iter (alias env r) ~f:schema
    | Dterm (r, _, _) -> add declared r
    | Dfix (rs, _, _) -> Array.iter rs ~f:(add declared)
    | Dind i -> ind i
  in
  let rec members ~at specs =
    List.iter specs ~f:(fun (l, s) ->
      match s with
      | Spec (Stype (r, _, _) | Sval (r, _)) -> add declared r
      | Spec (Sind i) -> ind i
      | Smodule mt ->
        let at = ModPath.MPdot (at, l) in
        members ~at (module_members sigs ~at mt)
      | Smodtype _ -> ())
  in
  List.iter struc ~f:(fun (mp, sel) ->
    List.iter (sources sigs ~parent:mp sel) ~f:(function
      | Decl { decl = d; _ } -> decl d
      | Members (at, specs) -> members ~at specs));
  Refmap.iter (fun _ t -> schema t.schema) env.terms;
  Refmap.iter
    (fun _ c ->
       params c.lifted;
       List.iter c.args ~f:ty)
    env.ctors;
  Refset.elements (Refset.diff !needed !declared)
;;

let unfold env r args =
  Option.map (alias env r) ~f:(fun (s : Ts_type.schema) ->
    expand_type env.resolve env.abbrevs (Ts_type.subst args s.ty))
;;

let get what map r =
  match Refmap.find_opt r map with
  | Some x -> x
  | None ->
    CErrors.anomaly
      Pp.(
        str "Ts_env."
        ++ str what
        ++ str ": not in the structure: "
        ++ Printer.pr_global r.glob
        ++ str ".")
;;

let term env r = get "term" env.terms r

let refined env r =
  Refset.mem r env.refined && List.is_empty (Ts_type.metas [ (term env r).schema.ty ])
;;

let ind env r = get "ind" env.inds r
let ctor env r = get "ctor" env.ctors r

let optimise_unary env inputs =
  let inputs = List.fold inputs ~init:Refset.empty ~f:(fun set r -> Refset.add r set) in
  { env with
    inds =
      Refmap.mapi
        (fun r ind -> { ind with optimise_unary = Refset.mem r inputs })
        env.inds
  }
;;
