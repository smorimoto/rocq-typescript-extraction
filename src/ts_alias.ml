open Import
open Names
open Extraction_plugin
open Miniml
module Refmap = Table.Refmap'

let rec functor_body = function
  | MEfunctor (_, _, me) -> functor_body me
  | MEstruct (mp, sel) -> Some (mp, sel)
  | MEident _ | MEapply _ -> None
;;

let rec constrained ~at = function
  | MTwith (mt, ML_With_module (idl, target)) ->
    (List.fold idl ~init:at ~f:(fun mp l -> MPdot (mp, l)), target) :: constrained ~at mt
  | MTwith (mt, ML_With_type _) -> constrained ~at mt
  | MTfunsig (id, param, result) ->
    constrained ~at:(MPbound id) param @ constrained ~at result
  | MTsig (mp, members) ->
    List.concat_map members ~f:(fun (l, s) ->
      match s with
      | Smodule mt | Smodtype mt -> constrained ~at:(MPdot (mp, l)) mt
      | Spec _ -> [])
  | MTident _ -> []
;;

let rec functor_constraints = function
  | MEfunctor (id, mt, me) -> constrained ~at:(MPbound id) mt @ functor_constraints me
  | MEstruct _ | MEident _ | MEapply _ -> []
;;

let aliases struc =
  let rec elements mp acc sel =
    List.fold sel ~init:acc ~f:(fun acc (l, se) ->
      let at = MPdot (mp, l) in
      match se with
      | SEmodule { ml_mod_expr = MEident target; ml_mod_type } ->
        ((at, target) :: constrained ~at ml_mod_type) @ acc
      | SEmodule { ml_mod_expr = MEstruct (mp', sel'); ml_mod_type } ->
        elements mp' (constrained ~at ml_mod_type @ acc) sel'
      | SEmodule { ml_mod_expr = MEfunctor _ as me; ml_mod_type } ->
        let acc = functor_constraints me @ constrained ~at ml_mod_type @ acc in
        (match functor_body me with
         | Some (mp', sel') -> elements mp' acc sel'
         | None -> acc)
      | SEmodule { ml_mod_expr = MEapply _; ml_mod_type } ->
        constrained ~at ml_mod_type @ acc
      | SEmodtype mt -> constrained ~at mt @ acc
      | SEdecl _ -> acc)
  in
  List.fold struc ~init:[] ~f:(fun acc (mp, sel) -> elements mp acc sel)
;;

let rec target aliases mp =
  match List.find aliases ~f:(fun (alias, _) -> ModPath.equal alias mp) with
  | Some (_, t) -> target aliases t
  | None ->
    (match mp with
     | MPdot (parent, l) ->
       let parent' = target aliases parent in
       if phys_equal parent' parent then mp else target aliases (MPdot (parent', l))
     | MPfile _ | MPbound _ -> mp)
;;

let rebase mp r =
  let glob =
    GlobRef.(
      match r.glob with
      | ConstRef kn -> ConstRef (Constant.make2 mp (Constant.label kn))
      | IndRef (kn, i) -> IndRef (MutInd.make2 mp (MutInd.label kn), i)
      | ConstructRef ((kn, i), j) ->
        ConstructRef ((MutInd.make2 mp (MutInd.label kn), i), j)
      | VarRef _ as g -> g)
  in
  { r with glob }
;;

let declared struc =
  let add acc r = Refmap.add r r acc in
  let decl acc = function
    | Dterm (r, _, _) | Dtype (r, _, _) -> add acc r
    | Dfix (rv, _, _) -> Array.fold rv ~init:acc ~f:add
    | Dind ind ->
      Array.fold ind.ind_packets ~init:acc ~f:(fun acc (p : ml_ind_packet) ->
        Array.fold p.ip_consnames_ref ~init:(add acc p.ip_typename_ref) ~f:add)
  in
  let rec elements acc sel =
    List.fold sel ~init:acc ~f:(fun acc (_, se) ->
      match se with
      | SEdecl d -> decl acc d
      | SEmodule { ml_mod_expr = MEstruct (_, sel'); _ } -> elements acc sel'
      | SEmodule { ml_mod_expr = MEfunctor _ as me; _ } ->
        (match functor_body me with
         | Some (_, sel') -> elements acc sel'
         | None -> acc)
      | SEmodule _ | SEmodtype _ -> acc)
  in
  List.fold struc ~init:Refmap.empty ~f:(fun acc (_, sel) -> elements acc sel)
;;

let global struc =
  match aliases struc with
  | [] -> Fn.id
  | aliases ->
    let declared = declared struc in
    fun r ->
      let mp = Table.modpath_of_r r in
      let mp' = target aliases mp in
      if phys_equal mp' mp
      then r
      else (
        let r' = rebase mp' r in
        Option.value (Refmap.find_opt r' declared) ~default:r')
;;

let resolve struc =
  match aliases struc with
  | [] -> struc
  | aliases ->
    let g = global struc in
    let rec ty = function
      | Tglob (r, l) -> Tglob (g r, List.map l ~f:ty)
      | Tarr (a, b) -> Tarr (ty a, ty b)
      | Tmeta ({ contents = Some t; _ } as m) -> Tmeta { m with contents = Some (ty t) }
      | (Tmeta { contents = None; _ } | Tvar _ | Tvar' _ | Tdummy _ | Tunknown | Taxiom)
        as t -> t
    in
    let rec pat = function
      | Pcons (r, ps) -> Pcons (g r, List.map ps ~f:pat)
      | Ptuple ps -> Ptuple (List.map ps ~f:pat)
      | Pusual r -> Pusual (g r)
      | (Prel _ | Pwild) as p -> p
    in
    let rec ast = function
      | MLglob r -> MLglob (g r)
      | MLcons (t, r, args) -> MLcons (ty t, g r, List.map args ~f:ast)
      | MLcase (t, s, branches) ->
        MLcase (ty t, ast s, Array.map branches ~f:(fun (ids, p, b) -> ids, pat p, ast b))
      | a -> Mlutil.ast_map ast a
    in
    let packet (p : ml_ind_packet) =
      { p with ip_types = Array.map p.ip_types ~f:(List.map ~f:ty) }
    in
    let decl = function
      | Dind ind -> Dind { ind with ind_packets = Array.map ind.ind_packets ~f:packet }
      | Dtype (r, vl, t) -> Dtype (r, vl, ty t)
      | Dterm (r, a, t) -> Dterm (r, ast a, ty t)
      | Dfix (rv, av, tv) -> Dfix (rv, Array.map av ~f:ast, Array.map tv ~f:ty)
    in
    let rec modtype = function
      | MTident mp -> MTident mp
      | MTfunsig (id, a, b) -> MTfunsig (id, modtype a, modtype b)
      | MTsig (mp, members) ->
        MTsig
          ( mp
          , List.map members ~f:(fun (l, s) ->
              ( l
              , match s with
                | Spec (Sval (r, t)) -> Spec (Sval (r, ty t))
                | Spec (Stype (r, vl, def)) -> Spec (Stype (r, vl, Option.map def ~f:ty))
                | Spec (Sind ind) ->
                  Spec
                    (Sind { ind with ind_packets = Array.map ind.ind_packets ~f:packet })
                | Smodule mt -> Smodule (modtype mt)
                | Smodtype mt -> Smodtype (modtype mt) )) )
      | MTwith (mt, ML_With_module (idl, t)) ->
        MTwith (modtype mt, ML_With_module (idl, target aliases t))
      | MTwith (mt, ML_With_type (inst, idl, vl, t)) ->
        MTwith (modtype mt, ML_With_type (inst, idl, vl, ty t))
    in
    let rec expr = function
      | MEstruct (mp, sel) -> MEstruct (mp, List.map sel ~f:element)
      | MEident t -> MEident (target aliases t)
      | MEfunctor (id, mt, me) -> MEfunctor (id, modtype mt, expr me)
      | MEapply (f, a) -> MEapply (expr f, expr a)
    and element (l, se) =
      ( l
      , match se with
        | SEdecl d -> SEdecl (decl d)
        | SEmodule m ->
          SEmodule
            { ml_mod_expr = expr m.ml_mod_expr; ml_mod_type = modtype m.ml_mod_type }
        | SEmodtype mt -> SEmodtype (modtype mt) )
    in
    List.map struc ~f:(fun (mp, sel) -> mp, List.map sel ~f:element)
;;

let find struc mp =
  let rec elements sel =
    List.find_map sel ~f:(fun (_, se) ->
      match se with
      | SEmodule { ml_mod_expr = MEstruct (mp', sel'); _ } ->
        if ModPath.equal mp mp' then Some sel' else elements sel'
      | SEmodule { ml_mod_expr = MEfunctor _ as me; _ } ->
        Option.bind (functor_body me) ~f:(fun (_, sel') -> elements sel')
      | SEdecl _ | SEmodule _ | SEmodtype _ -> None)
  in
  List.find_map struc ~f:(fun (mp', sel) ->
    if ModPath.equal mp mp' then Some sel else elements sel)
;;
