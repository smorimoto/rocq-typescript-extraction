open Import
open Names
open Extraction_plugin
open Miniml
module Refmap = Table.Refmap'
module Refset = Table.Refset'

type abstract =
  { global : global
  ; id : Id.t
  ; arity : int
  }

type body =
  | Structure of ModPath.t * ml_module_structure
  | Applied of ml_module_expr

type functor_ =
  { params : (MBId.t * ml_module_type) list
  ; body : body
  }

type signature_ =
  { parameters : (MBId.t * ml_module_type) list
  ; result : ml_module_type
  }

type t =
  { modtypes : ml_module_type ModPath.Map.t
  ; reached : (ModPath.t * ModPath.t) list
  ; implicit : global list Refmap.t
  ; fixed : (Id.t list * ml_type) Refmap.t
  ; sealed : (Id.t list * ml_type) Refmap.t
  ; functors : functor_ ModPath.Map.t
  ; bound : ml_module_type MBId.Map.t
  ; applications : ModPath.t list
  ; results : ModPath.Set.t
  ; used : Refset.t
  ; used_functors : ModPath.Set.t
  ; aliases : ModPath.t ModPath.Map.t
  ; arities : int Refmap.t
  ; homes : ModPath.t Refmap.t
  ; kinds : int ModPath.Map.t
  }

let rec rebase_path ~from ~to_ mp =
  if ModPath.equal mp from
  then to_
  else (
    match mp with
    | MPdot (parent, l) ->
      let parent' = rebase_path ~from ~to_ parent in
      if phys_equal parent' parent then mp else MPdot (parent', l)
    | MPfile _ | MPbound _ -> mp)
;;

let rebase ~from ~to_ r =
  let mp = Table.modpath_of_r r in
  let mp' = rebase_path ~from ~to_ mp in
  if phys_equal mp' mp then r else Ts_alias.rebase mp' r
;;

let rec rebase_type ~from ~to_ = function
  | Tglob (r, l) -> Tglob (rebase ~from ~to_ r, List.map l ~f:(rebase_type ~from ~to_))
  | Tarr (a, b) -> Tarr (rebase_type ~from ~to_ a, rebase_type ~from ~to_ b)
  | Tmeta { contents = Some t; _ } -> rebase_type ~from ~to_ t
  | (Tmeta { contents = None; _ } | Tvar _ | Tvar' _ | Tdummy _ | Tunknown | Taxiom) as t
    -> t
;;

let rebase_ind ~from ~to_ ind =
  let packet (p : ml_ind_packet) =
    { p with
      ip_typename_ref = rebase ~from ~to_ p.ip_typename_ref
    ; ip_consnames_ref = Array.map p.ip_consnames_ref ~f:(rebase ~from ~to_)
    ; ip_types = Array.map p.ip_types ~f:(List.map ~f:(rebase_type ~from ~to_))
    }
  in
  let kind =
    match ind.ind_kind with
    | Record projs -> Record (List.map projs ~f:(Option.map ~f:(rebase ~from ~to_)))
    | (Singleton | Coinductive | Standard) as kind -> kind
  in
  { ind with ind_kind = kind; ind_packets = Array.map ind.ind_packets ~f:packet }
;;

let rec rebase_sig ~from ~to_ members =
  List.map members ~f:(fun (l, s) ->
    ( l
    , match s with
      | Spec (Sval (r, t)) -> Spec (Sval (rebase ~from ~to_ r, rebase_type ~from ~to_ t))
      | Spec (Stype (r, vl, def)) ->
        Spec (Stype (rebase ~from ~to_ r, vl, Option.map def ~f:(rebase_type ~from ~to_)))
      | Spec (Sind ind) -> Spec (Sind (rebase_ind ~from ~to_ ind))
      | Smodule mt -> Smodule (rebase_modtype ~from ~to_ mt)
      | Smodtype mt -> Smodtype (rebase_modtype ~from ~to_ mt) ))

and rebase_modtype ~from ~to_ = function
  | MTident mp -> MTident (rebase_path ~from ~to_ mp)
  | MTsig (mp, members) -> MTsig (rebase_path ~from ~to_ mp, rebase_sig ~from ~to_ members)
  | MTfunsig (id, a, b) ->
    MTfunsig (id, rebase_modtype ~from ~to_ a, rebase_modtype ~from ~to_ b)
  | MTwith (mt, ML_With_type (inst, idl, vl, ty)) ->
    MTwith
      ( rebase_modtype ~from ~to_ mt
      , ML_With_type (inst, idl, vl, rebase_type ~from ~to_ ty) )
  | MTwith (mt, ML_With_module (idl, mp)) ->
    MTwith (rebase_modtype ~from ~to_ mt, ML_With_module (idl, rebase_path ~from ~to_ mp))
;;

let not_found mp =
  CErrors.user_err
    Pp.(
      str "TypeScript extraction cannot resolve the module type "
      ++ str (ModPath.to_string mp)
      ++ str ", which is not a module type of the structure.")
;;

let under at idl = List.fold idl ~init:at ~f:(fun mp l -> MPdot (mp, l))

let qualified r =
  let rec path mp =
    match Nametab.shortest_qualid_of_modtype mp with
    | q -> Libnames.string_of_qualid q
    | exception Stdlib.Not_found ->
      (match Nametab.shortest_qualid_of_module mp with
       | q -> Libnames.string_of_qualid q
       | exception Stdlib.Not_found ->
         (match mp with
          | MPdot (parent, l) -> path parent ^ "." ^ Id.to_string l
          | MPfile _ | MPbound _ -> ModPath.to_string mp))
  in
  path (Table.modpath_of_r r) ^ "." ^ Id.to_string (Table.label_of_r r)
;;

let rec define members idl vl ty =
  match idl with
  | [] -> CErrors.anomaly (Pp.str "Ts_sig.define: a constraint names a type.")
  | [ l ] ->
    List.map members ~f:(fun (l', s) ->
      match s with
      | Spec (Stype (r, _, _)) when Id.equal l l' -> l', Spec (Stype (r, vl, Some ty))
      | Spec _ | Smodule _ | Smodtype _ -> l', s)
  | l :: rest ->
    List.map members ~f:(fun (l', s) ->
      match s with
      | Smodule mt when Id.equal l l' ->
        l', Smodule (MTwith (mt, ML_With_type (InfvInst.empty, rest, vl, ty)))
      | Spec _ | Smodule _ | Smodtype _ -> l', s)
;;

let rec resolve_in modtypes ~at = function
  | MTsig (mp, members) ->
    if ModPath.equal mp at then members else rebase_sig ~from:mp ~to_:at members
  | MTident mp ->
    (match ModPath.Map.find_opt mp modtypes with
     | Some mt -> resolve_in modtypes ~at mt
     | None -> not_found mp)
  | MTwith (mt, ML_With_type (_, idl, vl, ty)) ->
    define (resolve_in modtypes ~at mt) idl vl ty
  | MTwith (mt, ML_With_module (idl, mp)) ->
    substitute modtypes ~at (resolve_in modtypes ~at mt) idl mp
  | MTfunsig _ -> []

and substitute modtypes ~at members idl mp =
  let at' = under at idl in
  let rec abstracts ~at ~labels members =
    List.concat_map members ~f:(fun (l, s) ->
      match s with
      | Spec (Stype (r, vl, None)) ->
        let args = List.mapi vl ~f:(fun i _ -> Tvar (i + 1)) in
        [ List.rev (l :: labels), vl, Tglob (rebase ~from:at' ~to_:mp r, args) ]
      | Smodule mt ->
        let at = MPdot (at, l) in
        abstracts ~at ~labels:(l :: labels) (resolve_in modtypes ~at mt)
      | Spec (Stype (_, _, Some _) | Sval _ | Sind _) | Smodtype _ -> [])
  in
  let rec find ~at members = function
    | [] -> None
    | l :: rest ->
      (match List.Assoc.find members ~equal:Id.equal l, rest with
       | Some (Smodule mt), [] -> Some mt
       | Some (Smodule mt), rest ->
         let at = MPdot (at, l) in
         find ~at (resolve_in modtypes ~at mt) rest
       | Some (Spec _ | Smodtype _), _ | None, _ -> None)
  in
  let fixes =
    match find ~at members idl with
    | Some mt -> abstracts ~at:at' ~labels:[] (resolve_in modtypes ~at:at' mt)
    | None -> []
  in
  List.fold fixes ~init:members ~f:(fun members (labels, vl, ty) ->
    define members (idl @ labels) vl ty)
;;

let rec origin_in modtypes = function
  | MTsig (mp, _) -> mp
  | MTident mp ->
    (match ModPath.Map.find_opt mp modtypes with
     | Some (MTfunsig _) -> mp
     | Some mt -> origin_in modtypes mt
     | None -> not_found mp)
  | MTwith (mt, _) -> origin_in modtypes mt
  | MTfunsig _ ->
    CErrors.anomaly (Pp.str "Ts_sig.origin: a functor signature is reached by its path.")
;;

let rec signature_of modtypes = function
  | MTfunsig (id, mt, result) ->
    let rec parts = function
      | MTfunsig (id, mt, result) ->
        let parameters, result = parts result in
        (id, mt) :: parameters, result
      | (MTsig _ | MTident _ | MTwith _) as result -> [], result
    in
    let parameters, result = parts result in
    Some { parameters = (id, mt) :: parameters; result }
  | MTident mp ->
    (match ModPath.Map.find_opt mp modtypes with
     | Some mt -> signature_of modtypes mt
     | None -> not_found mp)
  | MTsig _ | MTwith _ -> None
;;

let resolve t ~at mt = resolve_in t.modtypes ~at mt
let origin t mt = origin_in t.modtypes mt

let abstracts_in modtypes ~at members =
  let rec go ~at ~labels members =
    List.concat_map members ~f:(fun (l, s) ->
      match s with
      | Spec (Stype (r, vl, None)) ->
        let id =
          Id.of_string
            (String.concat ~sep:"_" (List.rev_map (l :: labels) ~f:Id.to_string))
        in
        [ { global = r; id; arity = List.length vl } ]
      | Smodule mt when Option.is_none (signature_of modtypes mt) ->
        let at = MPdot (at, l) in
        go ~at ~labels:(l :: labels) (resolve_in modtypes ~at mt)
      | Spec (Stype (_, _, Some _) | Sval _ | Sind _) | Smodule _ | Smodtype _ -> [])
  in
  go ~at ~labels:[] members
;;

let abstracts t ~at members = abstracts_in t.modtypes ~at members

let signature_abstracts modtypes ~at s =
  let parameters =
    List.concat_map s.parameters ~f:(fun (id, mt) ->
      let at = MPbound id in
      abstracts_in modtypes ~at (resolve_in modtypes ~at mt))
  in
  let results =
    match s.result with
    | MTident _ | MTwith _ | MTsig _ ->
      List.map
        (abstracts_in modtypes ~at (resolve_in modtypes ~at s.result))
        ~f:(fun a ->
          { a with id = Id.of_string "r"; arity = List.length parameters + a.arity })
    | MTfunsig _ -> []
  in
  parameters, results
;;

let parameter_abstracts_in modtypes ~at mt =
  match signature_of modtypes mt with
  | Some s -> snd (signature_abstracts modtypes ~at s)
  | None -> abstracts_in modtypes ~at (resolve_in modtypes ~at mt)
;;

let rec fixed_in modtypes ~at ~origin members =
  let declared =
    match ModPath.Map.find_opt origin modtypes with
    | Some mt -> resolve_in modtypes ~at:origin mt
    | None -> []
  in
  List.concat_map members ~f:(fun (l, s) ->
    match s with
    | Spec (Stype (r, vl, Some def)) ->
      (match List.Assoc.find declared ~equal:Id.equal l with
       | Some (Spec (Stype (_, _, None))) -> [ r, (vl, def) ]
       | Some (Spec (Stype (_, _, Some _) | Sval _ | Sind _) | Smodule _ | Smodtype _)
       | None -> [])
    | Smodule mt when Option.is_none (signature_of modtypes mt) ->
      let at = MPdot (at, l) in
      fixed_in modtypes ~at ~origin:(origin_in modtypes mt) (resolve_in modtypes ~at mt)
    | Spec (Stype (_, _, None) | Sval _ | Sind _) | Smodule _ | Smodtype _ -> [])
;;

let rec sig_types modtypes ~at members =
  List.concat_map members ~f:(fun (l, s) ->
    match s with
    | Spec (Stype (r, _, Some def)) -> [ r, [ def ] ]
    | Spec (Sind ind) -> ind_types ind
    | Smodule mt when Option.is_none (signature_of modtypes mt) ->
      let at = MPdot (at, l) in
      if ModPath.equal (origin_in modtypes mt) at
      then sig_types modtypes ~at (resolve_in modtypes ~at mt)
      else []
    | Spec (Stype (_, _, None) | Sval _) | Smodule _ | Smodtype _ -> [])

and ind_types ind =
  List.concat_map (Array.to_list ind.ind_packets) ~f:(fun (p : ml_ind_packet) ->
    if p.ip_logical
    then []
    else
      (p.ip_typename_ref, List.concat (Array.to_list p.ip_types))
      :: Array.to_list (Array.mapi p.ip_consnames_ref ~f:(fun j c -> c, p.ip_types.(j))))
;;

let rec body_types sel =
  List.concat_map sel ~f:(fun (_, se) ->
    match se with
    | SEdecl (Dtype (r, _, def)) -> [ r, [ def ] ]
    | SEdecl (Dind ind) -> ind_types ind
    | SEmodule { ml_mod_expr = MEstruct (_, sel); _ } -> body_types sel
    | SEdecl (Dterm _ | Dfix _)
    | SEmodule { ml_mod_expr = MEident _ | MEapply _ | MEfunctor _; _ }
    | SEmodtype _ -> [])
;;

let abstract_globals abstracts =
  List.fold abstracts ~init:Refset.empty ~f:(fun set a -> Refset.add a.global set)
;;

let implicit_of ~known abstracts types =
  let candidates = abstract_globals abstracts in
  let table = Hashtbl.Poly.create ~size:16 () in
  List.iter types ~f:(fun (g, _) -> Hashtbl.set table ~key:g ~data:Refset.empty);
  let rec mentions acc = function
    | Tglob (g, args) ->
      let acc = if Refset.mem g candidates then Refset.add g acc else acc in
      let acc =
        match Hashtbl.find table g with
        | Some set -> Refset.union set acc
        | None ->
          List.fold (known g) ~init:acc ~f:(fun acc a ->
            if Refset.mem a candidates then Refset.add a acc else acc)
      in
      List.fold args ~init:acc ~f:mentions
    | Tarr (a, b) -> mentions (mentions acc a) b
    | Tmeta { contents = Some t; _ } -> mentions acc t
    | Tmeta { contents = None; _ } | Tvar _ | Tvar' _ | Tdummy _ | Tunknown | Taxiom ->
      acc
  in
  let changed = ref true in
  while !changed do
    changed := false;
    List.iter types ~f:(fun (g, ts) ->
      let set = List.fold ts ~init:Refset.empty ~f:mentions in
      if not (Refset.equal set (Hashtbl.find_exn table g))
      then (
        Hashtbl.set table ~key:g ~data:set;
        changed := true))
  done;
  List.map types ~f:(fun (g, _) ->
    let set = Hashtbl.find_exn table g in
    ( g
    , List.filter_map abstracts ~f:(fun a ->
        if Refset.mem a.global set then Some a.global else None) ))
;;

let step_in reached mp =
  Option.map
    (List.find reached ~f:(fun (from, _) -> ModPath.subpath from mp))
    ~f:(fun (from, to_) -> rebase_path ~from ~to_ mp, (from, to_))
;;

let rec canonical_in reached mp =
  match step_in reached mp with
  | Some (mp', _) -> canonical_in reached mp'
  | None -> mp
;;

let reaches_in reached r =
  match step_in reached (Table.modpath_of_r r) with
  | Some (mp', _) -> Ts_alias.rebase mp' r
  | None -> r
;;

let rec implicit_in ~known ~reached ~applications r =
  match Refmap.find_opt r known with
  | Some mentioned -> mentioned
  | None ->
    let mp = Table.modpath_of_r r in
    if List.exists applications ~f:(fun a -> ModPath.subpath a mp)
    then []
    else (
      match step_in reached mp with
      | None -> []
      | Some (canonical, (from, to_)) ->
        List.map
          (implicit_in ~known ~reached ~applications (Ts_alias.rebase canonical r))
          ~f:(rebase ~from:to_ ~to_:from))
;;

let rebase_result ~at = function
  | MTsig (mp, members) as mt ->
    if ModPath.equal mp at then mt else MTsig (at, rebase_sig ~from:mp ~to_:at members)
  | (MTident _ | MTwith _ | MTfunsig _) as mt -> mt
;;

let rec functor_parts = function
  | MEfunctor (id, mt, me) ->
    let params, body = functor_parts me in
    (id, mt) :: params, body
  | MEstruct (mp, sel) -> [], Structure (mp, sel)
  | (MEident _ | MEapply _) as me -> [], Applied me
;;

let rec application_head = function
  | MEapply (f, _) -> application_head f
  | MEident mp -> Some mp
  | MEfunctor _ | MEstruct _ -> None
;;

let declarations struc =
  let modtypes = ref ModPath.Map.empty
  and functors = ref ModPath.Map.empty
  and bound = ref MBId.Map.empty
  and aliases = ref ModPath.Map.empty in
  let rec declare_modtype ~at mt =
    modtypes := ModPath.Map.add at mt !modtypes;
    nested ~at mt
  and nested ~at = function
    | MTsig (_, members) -> nested_modtypes ~at members
    | MTfunsig (id, param, result) ->
      bound := MBId.Map.add id param !bound;
      nested ~at result
    | MTident _ | MTwith _ -> ()
  and nested_modtypes ~at members =
    List.iter members ~f:(fun (l, s) ->
      match s with
      | Smodtype mt -> declare_modtype ~at:(MPdot (at, l)) mt
      | Smodule (MTsig (mp, _) as mt) -> declare_modtype ~at:mp mt
      | Smodule (MTfunsig _ as mt) -> nested ~at:(MPdot (at, l)) mt
      | Smodule (MTident _ | MTwith _) | Spec _ -> ())
  in
  let rec collect ~parent sel =
    List.iter sel ~f:(fun (l, se) ->
      let at = MPdot (parent, l) in
      match se with
      | SEmodtype mt -> declare_modtype ~at mt
      | SEmodule { ml_mod_expr = MEstruct (mp, sel); _ } -> collect ~parent:mp sel
      | SEmodule { ml_mod_expr = MEfunctor _ as me; _ } ->
        let params, body = functor_parts me in
        List.iter params ~f:(fun (id, mt) -> bound := MBId.Map.add id mt !bound);
        functors := ModPath.Map.add at { params; body } !functors;
        (match body with
         | Structure (mp, sel) -> collect ~parent:mp sel
         | Applied _ -> ())
      | SEmodule { ml_mod_expr = MEident target; _ } ->
        aliases := ModPath.Map.add at target !aliases
      | SEmodule { ml_mod_expr = MEapply _; _ } | SEdecl _ -> ())
  in
  List.iter struc ~f:(fun (mp, sel) -> collect ~parent:mp sel);
  !modtypes, !functors, !bound, !aliases
;;

type walk =
  { declared : ml_module_type ModPath.Map.t
  ; defined : functor_ ModPath.Map.t
  ; parameters : ml_module_type MBId.Map.t
  ; mutable reaching : (ModPath.t * ModPath.t) list
  ; mutable mentioned : global list Refmap.t
  ; mutable constrained : (Id.t list * ml_type) Refmap.t
  ; mutable sealing : (Id.t list * ml_type) Refmap.t
  ; mutable applied : ModPath.t list
  ; mutable returned : ModPath.Set.t
  ; mutable bound_at : (MBId.t * ModPath.t) list ModPath.Map.t
  ; mutable left : (global * global list) list
  ; mutable arities : int Refmap.t
  ; mutable homes : ModPath.t Refmap.t
  ; mutable kinds : int ModPath.Map.t
  }

let rec result_of w mt =
  match mt with
  | MTsig (mp, members) ->
    if not (ModPath.Set.mem mp w.returned)
    then (
      w.returned <- ModPath.Set.add mp w.returned;
      nested_results w members)
  | MTident _ | MTwith _ ->
    let o = origin_in w.declared mt in
    if not (ModPath.Set.mem o w.returned)
    then (
      w.returned <- ModPath.Set.add o w.returned;
      nested_results w (resolve_in w.declared ~at:o mt))
  | MTfunsig _ ->
    Option.iter (signature_of w.declared mt) ~f:(fun { result; _ } -> result_of w result)

and nested_results w members =
  List.iter members ~f:(fun (_, s) ->
    match s with
    | Smodule (MTsig (mp, members)) ->
      w.returned <- ModPath.Set.add mp w.returned;
      nested_results w members
    | Smodule ((MTident _ | MTwith _ | MTfunsig _) as mt) ->
      (match signature_of w.declared mt with
       | Some { result; _ } -> result_of w result
       | None -> result_of w mt)
    | Smodtype _ | Spec _ -> ())
;;

let kinded w ~origin abstracts =
  List.iter abstracts ~f:(fun a ->
    if a.arity > 0
    then (
      let file = Table.base_mp origin in
      w.arities <- Refmap.add a.global a.arity w.arities;
      w.homes <- Refmap.add a.global file w.homes;
      w.kinds
      <- ModPath.Map.update
           file
           (fun n -> Some (max a.arity (Option.value n ~default:0)))
           w.kinds))
;;

let record_implicit w abstracts types =
  let known =
    implicit_in ~known:w.mentioned ~reached:(List.rev w.reaching) ~applications:w.applied
  in
  List.iter (implicit_of ~known abstracts types) ~f:(fun (g, mentioned) ->
    w.mentioned <- Refmap.add g mentioned w.mentioned)
;;

let rec nested_reached w ~at members =
  List.iter members ~f:(fun (l, s) ->
    match s with
    | Smodule mt when Option.is_none (signature_of w.declared mt) ->
      let at = MPdot (at, l) in
      let o = origin_in w.declared mt in
      if not (ModPath.equal o at) then w.reaching <- (at, o) :: w.reaching;
      nested_reached w ~at (resolve_in w.declared ~at mt)
    | Smodule _ | Smodtype _ | Spec _ -> ())
;;

let rec use ?(outer = []) w ~at mt =
  match signature_of w.declared mt with
  | Some ({ parameters; result } as s) ->
    let abstracts =
      List.fold parameters ~init:[] ~f:(fun abstracts (id, mt) ->
        abstracts @ use ~outer:(outer @ abstracts) w ~at:(MPbound id) mt)
    in
    ignore (use ~outer:(outer @ abstracts) w ~at result : abstract list);
    let results = snd (signature_abstracts w.declared ~at s) in
    (match mt with
     | MTident _ | MTwith _ -> kinded w ~origin:(origin_in w.declared mt) results
     | MTfunsig _ -> kinded w ~origin:at results
     | MTsig _ -> ());
    results
  | None ->
    let members = resolve_in w.declared ~at mt in
    let o = origin_in w.declared mt in
    if not (ModPath.equal o at) then w.reaching <- (at, o) :: w.reaching;
    (match mt, at with
     | MTsig _, MPbound _ when ModPath.equal o at -> result_of w mt
     | (MTsig _ | MTident _ | MTwith _ | MTfunsig _), (MPbound _ | MPdot _ | MPfile _) ->
       ());
    nested_reached w ~at members;
    List.iter (fixed_in w.declared ~at ~origin:o members) ~f:(fun (g, def) ->
      w.constrained <- Refmap.add g def w.constrained);
    let abstracts = abstracts_in w.declared ~at members in
    kinded w ~origin:o abstracts;
    if ModPath.equal o at
    then (
      record_implicit w (outer @ abstracts) (sig_types w.declared ~at members);
      declared_functors w ~outer:(outer @ abstracts) ~at members);
    abstracts

and declared_functors w ~outer ~at members =
  List.iter members ~f:(fun (l, s) ->
    match s with
    | Smodule mt ->
      let at = MPdot (at, l) in
      (match signature_of w.declared mt with
       | Some { result; _ } ->
         result_of w result;
         ignore (use ~outer w ~at mt : abstract list)
       | None ->
         if ModPath.equal (origin_in w.declared mt) at
         then declared_functors w ~outer ~at (resolve_in w.declared ~at mt))
    | Smodtype _ | Spec _ -> ())
;;

let rec application_args = function
  | MEapply (f, MEident a) -> application_args f @ [ a ]
  | MEapply _ | MEident _ | MEfunctor _ | MEstruct _ -> []
;;

let rec pair params args =
  match params, args with
  | (id, _) :: params, a :: args -> (id, a) :: pair params args
  | [], _ | _, [] -> []
;;

let applied_result w ~outer ~at ~functor_ (s : signature_) args =
  let candidates = abstract_globals outer in
  let candidate g = Refset.mem g candidates in
  if List.length args = List.length s.parameters
  then (
    let arguments =
      List.concat
        (List.map2_exn s.parameters args ~f:(fun (id, mt) a ->
           List.map
             (abstracts_in
                w.declared
                ~at:(MPbound id)
                (resolve_in w.declared ~at:(MPbound id) mt))
             ~f:(fun p -> Tglob (rebase ~from:(MPbound id) ~to_:a p.global, []))))
    in
    List.iter2_exn
      (snd (signature_abstracts w.declared ~at:functor_ s))
      (abstracts_in w.declared ~at (resolve_in w.declared ~at s.result))
      ~f:(fun (r : abstract) (b : abstract) ->
        let own = List.init b.arity ~f:(fun i -> Tvar (i + 1)) in
        let def = Tglob (r.global, arguments @ own) in
        let mentioned =
          List.filter
            (r.global
             :: List.filter_map arguments ~f:(function
               | Tglob (g, []) -> Some g
               | _ -> None))
            ~f:candidate
        in
        w.constrained
        <- Refmap.add
             b.global
             (List.map own ~f:(fun _ -> Id.of_string "a"), def)
             w.constrained;
        w.mentioned <- Refmap.add b.global mentioned w.mentioned;
        w.left <- (b.global, mentioned) :: w.left))
;;

let left_through w ~outer ~at ~body params me =
  let bindings =
    List.map (pair params (application_args me)) ~f:(fun (id, a) -> MPbound id, a)
  in
  let candidates = abstract_globals outer in
  let instantiate g =
    let gp = Table.modpath_of_r g in
    match List.find bindings ~f:(fun (p, _) -> ModPath.subpath p gp) with
    | Some (from, to_) -> rebase ~from ~to_ g
    | None -> g
  in
  List.iter w.left ~f:(fun (b, mentioned) ->
    if ModPath.subpath body (Table.modpath_of_r b)
    then (
      let b = rebase ~from:body ~to_:at b in
      let mentioned =
        List.filter (List.map mentioned ~f:instantiate) ~f:(fun g ->
          Refset.mem g candidates)
      in
      w.mentioned <- Refmap.add b mentioned w.mentioned;
      w.left <- (b, mentioned) :: w.left))
;;

let fixed_through w ~outer ~at ~body bound =
  let bindings = (body, at) :: List.map bound ~f:(fun (id, a) -> MPbound id, a) in
  let instantiate t =
    List.fold bindings ~init:t ~f:(fun t (from, to_) -> rebase_type ~from ~to_ t)
  in
  Refmap.iter
    (fun g (vl, def) ->
       if ModPath.subpath body (Table.modpath_of_r g)
       then (
         let g = rebase ~from:body ~to_:at g
         and def = instantiate def in
         w.sealing <- Refmap.add g (vl, def) w.sealing;
         if not (List.is_empty outer) then record_implicit w outer [ g, [ def ] ]))
    w.sealing
;;

let application_reaches ?(outer = []) w ~at me mt =
  w.applied <- at :: w.applied;
  let argument id params args = List.Assoc.find (pair params args) ~equal:MBId.equal id in
  let rec instantiated mp id =
    let here =
      Option.bind (ModPath.Map.find_opt mp w.bound_at) ~f:(fun bs ->
        List.Assoc.find bs ~equal:MBId.equal id)
    in
    match here, mp with
    | Some _, _ -> here
    | None, MPdot (parent, _) -> instantiated parent id
    | None, (MPfile _ | MPbound _) -> None
  in
  let reach_parameter params args id ~from =
    Option.first_some (argument id params args) (instantiated from id)
  in
  let rec subst params args = function
    | MEident (MPbound id) as me ->
      (match argument id params args with
       | Some a -> MEident a
       | None -> me)
    | (MEident _ | MEfunctor _ | MEstruct _) as me -> me
    | MEapply (f, a) -> MEapply (subst params args f, subst params args a)
  in
  let seen = ref ModPath.Set.empty in
  let rec reach_defined me =
    match application_head me with
    | Some f when ModPath.Map.mem f w.defined && not (ModPath.Set.mem f !seen) ->
      seen := ModPath.Set.add f !seen;
      let { params; body } = ModPath.Map.find f w.defined in
      let args = application_args me in
      (match body with
       | Structure (mp, _) ->
         if not (List.is_empty outer) then left_through w ~outer ~at ~body:mp params me;
         fixed_through w ~outer ~at ~body:mp (pair params args);
         w.reaching <- (at, mp) :: w.reaching
       | Applied (MEident (MPbound id)) ->
         Option.iter (reach_parameter params args id ~from:f) ~f:(fun a ->
           w.reaching <- (at, a) :: w.reaching)
       | Applied (MEident target) -> w.reaching <- (at, target) :: w.reaching
       | Applied (MEapply _ as inner) -> reach_defined (subst params args inner)
       | Applied (MEfunctor _ | MEstruct _) -> ())
    | Some _ | None -> ()
  in
  (match application_head me with
   | Some f when ModPath.Map.mem f w.defined ->
     let { params; _ } = ModPath.Map.find f w.defined in
     w.bound_at <- ModPath.Map.add at (pair params (application_args me)) w.bound_at;
     reach_defined me
   | Some (MPbound id) ->
     (match
        Option.bind (MBId.Map.find_opt id w.parameters) ~f:(signature_of w.declared)
      with
      | Some ({ result; _ } as s) ->
        w.reaching <- (at, origin_in w.declared result) :: w.reaching;
        applied_result w ~outer ~at ~functor_:(MPbound id) s (application_args me)
      | None -> ())
   | Some ((MPfile _ | MPdot _) as f) ->
     let body = canonical_in w.reaching f in
     let moved = Option.some_if (not (ModPath.equal body f)) body in
     let target =
       match ModPath.Map.find_opt body w.defined with
       | Some { params; body = Applied (MEident (MPbound id)) } ->
         Option.first_some (reach_parameter params (application_args me) id ~from:f) moved
       | Some { body = Applied (MEident target); _ } -> Some target
       | _ -> moved
     in
     Option.iter target ~f:(fun to_ -> w.reaching <- (at, to_) :: w.reaching)
   | None -> ());
  List.iter
    (fixed_in
       w.declared
       ~at
       ~origin:(canonical_in w.reaching at)
       (resolve_in w.declared ~at mt))
    ~f:(fun (g, def) -> w.constrained <- Refmap.add g def w.constrained)
;;

let rec uses ?(outer = []) w ~parent sel =
  List.iter sel ~f:(fun (l, se) ->
    let at = MPdot (parent, l) in
    match se with
    | SEmodtype mt ->
      ignore (use ~outer w ~at mt : abstract list);
      Option.iter (signature_of w.declared mt) ~f:(fun { result; _ } ->
        result_of w (rebase_result ~at result))
    | SEmodule { ml_mod_expr = MEstruct (mp, sel); _ } -> uses ~outer w ~parent:mp sel
    | SEmodule { ml_mod_expr = MEfunctor _; ml_mod_type } ->
      functor_uses w ~outer ~at ml_mod_type
    | SEmodule { ml_mod_expr = MEapply _ as me; ml_mod_type } ->
      application_reaches ~outer w ~at me ml_mod_type
    | SEmodule { ml_mod_expr = MEident target; _ } ->
      let rec parameter = function
        | MPbound id -> MBId.Map.find_opt id w.parameters
        | MPdot (mp, _) -> parameter mp
        | MPfile _ -> None
      in
      Option.iter (parameter target) ~f:(result_of w)
    | SEdecl _ -> ())

and functor_uses w ~outer ~at mt =
  let { params; body } = ModPath.Map.find at w.defined in
  let rec sealed = function
    | MTfunsig (_, _, mt) -> sealed mt
    | (MTident _ | MTwith _) as mt ->
      result_of w mt;
      (match body with
       | Structure (mp, sel) ->
         let own =
           List.fold (body_types sel) ~init:Refset.empty ~f:(fun s (g, _) ->
             Refset.add g s)
         in
         List.iter
           (fixed_in
              w.declared
              ~at:mp
              ~origin:(origin_in w.declared mt)
              (resolve_in w.declared ~at:mp mt))
           ~f:(fun (g, def) ->
             if not (Refset.mem g own) then w.sealing <- Refmap.add g def w.sealing)
       | Applied _ -> ())
    | MTsig _ as mt ->
      (match body with
       | Applied (MEident (MPbound id)) ->
         Option.iter
           (Option.first_some
              (List.Assoc.find params ~equal:MBId.equal id)
              (MBId.Map.find_opt id w.parameters))
           ~f:(result_of w)
       | Applied (MEident _) -> result_of w mt
       | Structure _ | Applied (MEapply _ | MEfunctor _ | MEstruct _) -> ())
  in
  sealed mt;
  let abstracts =
    List.fold params ~init:outer ~f:(fun abstracts (id, mt) ->
      abstracts @ use ~outer:abstracts w ~at:(MPbound id) mt)
  in
  match body with
  | Structure (mp, sel) ->
    let applied =
      List.concat_map sel ~f:(fun (l, se) ->
        match se with
        | SEmodule { ml_mod_expr = MEapply _; ml_mod_type } ->
          let at = MPdot (mp, l) in
          sig_types w.declared ~at (resolve_in w.declared ~at ml_mod_type)
        | SEmodule { ml_mod_expr = MEstruct _ | MEident _ | MEfunctor _; _ }
        | SEdecl _ | SEmodtype _ -> [])
    in
    record_implicit w abstracts (body_types sel @ applied);
    uses ~outer:abstracts w ~parent:mp sel
  | Applied _ -> ()
;;

let used_members reached struc =
  let used = ref Refset.empty
  and functors = ref ModPath.Set.empty in
  let rec mark r =
    let r' = reaches_in reached r in
    if not (phys_equal r' r)
    then (
      used := Refset.add r' !used;
      mark r')
  in
  let rec mark_functor mp =
    match step_in reached mp with
    | Some (mp', _) ->
      functors := ModPath.Set.add mp' !functors;
      mark_functor mp'
    | None -> ()
  in
  let rec bound_in = function
    | MPbound _ -> true
    | MPdot (parent, _) -> bound_in parent
    | MPfile _ -> false
  in
  let rec ast a =
    (match a with
     | MLglob r | MLcons (_, r, _) -> if bound_in (Table.modpath_of_r r) then mark r
     | MLrel _
     | MLapp _
     | MLlam _
     | MLletin _
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
  let rec terms sel =
    List.iter sel ~f:(fun (_, se) ->
      match se with
      | SEdecl (Dterm (_, a, _)) -> ast a
      | SEdecl (Dfix (_, av, _)) -> Array.iter av ~f:ast
      | SEmodule { ml_mod_expr = MEstruct (_, sel); _ } -> terms sel
      | SEmodule { ml_mod_expr = MEfunctor _ as me; _ } ->
        (match functor_parts me with
         | _, Structure (_, sel) -> terms sel
         | _, Applied _ -> ())
      | SEmodule { ml_mod_expr = MEapply _ as me; _ } ->
        (match application_head me with
         | Some (MPdot _ as head) when bound_in head -> mark_functor head
         | Some (MPdot _ | MPbound _ | MPfile _) | None -> ())
      | SEdecl (Dind _ | Dtype _) | SEmodule { ml_mod_expr = MEident _; _ } | SEmodtype _
        -> ())
  in
  List.iter struc ~f:(fun (_, sel) -> terms sel);
  !used, !functors
;;

let create struc =
  let declared, defined, parameters, aliases = declarations struc in
  let w =
    { declared
    ; defined
    ; parameters
    ; reaching = []
    ; mentioned = Refmap.empty
    ; constrained = Refmap.empty
    ; sealing = Refmap.empty
    ; applied = []
    ; returned = ModPath.Set.empty
    ; bound_at = ModPath.Map.empty
    ; left = []
    ; arities = Refmap.empty
    ; homes = Refmap.empty
    ; kinds = ModPath.Map.empty
    }
  in
  List.iter struc ~f:(fun (mp, sel) -> uses w ~parent:mp sel);
  let reached = List.rev w.reaching in
  let used, used_functors = used_members reached struc in
  { modtypes = declared
  ; reached
  ; implicit = w.mentioned
  ; fixed = w.constrained
  ; sealed = w.sealing
  ; functors = defined
  ; bound = parameters
  ; applications = w.applied
  ; results = w.returned
  ; used
  ; used_functors
  ; aliases
  ; arities = w.arities
  ; homes = w.homes
  ; kinds = w.kinds
  }
;;

let alias t mp = ModPath.Map.find_opt mp t.aliases
let arity (t : t) r = Option.value (Refmap.find_opt r t.arities) ~default:0
let kinds (t : t) mp = Option.value (ModPath.Map.find_opt mp t.kinds) ~default:0
let home (t : t) r = Refmap.find_opt r t.homes
let parameter_abstracts t ~at mt = parameter_abstracts_in t.modtypes ~at mt
let signature_abstracts t ~at s = signature_abstracts t.modtypes ~at s
let canon_path t mp = canonical_in t.reached mp
let step t mp = step_in t.reached mp

let canon t r =
  let mp = Table.modpath_of_r r in
  let mp' = canon_path t mp in
  if ModPath.equal mp mp' then r else Ts_alias.rebase mp' r
;;

let reaches t r = reaches_in t.reached r
let pruned t mp = not (ModPath.Set.mem mp t.results)
let used t r = Refset.mem r t.used

let used_under t mp =
  Refset.exists (fun r -> ModPath.subpath mp (Table.modpath_of_r r)) t.used
  || ModPath.Set.exists (ModPath.subpath mp) t.used_functors
;;

let implicit t r =
  implicit_in ~known:t.implicit ~reached:t.reached ~applications:t.applications r
;;

let sealed t r = Refmap.find_opt r t.sealed
let fixed t r = Option.first_some (Refmap.find_opt r t.fixed) (sealed t r)
let functor_signature t mt = signature_of t.modtypes mt
let parameter t id = MBId.Map.find_opt id t.bound
let functor_ t mp = ModPath.Map.find_opt mp t.functors
