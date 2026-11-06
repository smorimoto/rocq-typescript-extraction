open Import
open Extraction_plugin
open Miniml
module Refset = Table.Refset'
module Refmap = Table.Refmap'

type heads = Refset.t option

type var =
  { heads : heads
  ; field : bool
  }

type known =
  { siblings : Refset.t Refmap.t
  ; globals : heads Refmap.t
  }

type ctx =
  { vars : var list
  ; narrowed : heads Refmap.t
  }

let top = { vars = []; narrowed = Refmap.empty }
let unknown = { heads = None; field = false }
let push ctx v = { ctx with vars = v :: ctx.vars }

(* TypeScript keeps the narrowing of a parameter or a const inside a
   function, but not that of a property. *)
let enter ctx =
  { ctx with
    vars = List.map ctx.vars ~f:(fun v -> if v.field then { v with heads = None } else v)
  }
;;

let union a b =
  match a, b with
  | Some a, Some b -> Some (Refset.union a b)
  | None, _ | _, None -> None
;;

let constructor = function
  | Pusual c | Pcons (c, _) -> Some c
  | Pwild | Prel _ | Ptuple _ -> None
;;

let narrowings k h brs =
  let domain =
    match h with
    | Some _ -> h
    | None ->
      Array.find_map brs ~f:(fun (_, p, _) ->
        Option.bind (constructor p) ~f:(fun c -> Refmap.find_opt c k.siblings))
  in
  snd
    (Array.fold_map brs ~init:domain ~f:(fun rest (_, p, _) ->
       match constructor p with
       | Some c -> Option.map rest ~f:(Refset.remove c), Some (Refset.singleton c)
       | None -> Option.map rest ~f:(fun _ -> Refset.empty), rest))
;;

let narrow ctx s h =
  match s with
  | MLrel n ->
    { ctx with
      vars =
        List.mapi ctx.vars ~f:(fun i v -> if i = n - 1 then { v with heads = h } else v)
    }
  | MLglob r -> { ctx with narrowed = Refmap.add r h ctx.narrowed }
  | _ -> ctx
;;

let within ctx s h ids =
  List.fold ids ~init:(narrow ctx s h) ~f:(fun ctx _ ->
    push ctx { heads = None; field = true })
;;

let kept brs cs =
  let select (rest, kept) (i, (_, p, _)) =
    match constructor p with
    | Some c when Refset.mem c rest -> Refset.remove c rest, i :: kept
    | Some _ -> rest, kept
    | None when Refset.is_empty rest -> rest, kept
    | None -> Refset.empty, i :: kept
  in
  match Array.foldi brs ~init:(cs, []) ~f:(fun i acc br -> select acc (i, br)) with
  | rest, (_ :: _ as kept) when Refset.is_empty rest -> Some (List.rev kept)
  | _ -> None
;;

let defaulted brs =
  let wildcard (_, p, _) = Option.is_none (constructor p) in
  let constant (ids, _, _) = List.is_empty ids in
  if List.exists brs ~f:wildcard
  then brs
  else (
    match List.findi (List.rev brs) ~f:(fun _ br -> constant br) with
    | Some (k, (_, _, body)) ->
      let j = List.length brs - 1 - k in
      List.filteri brs ~f:(fun i _ -> i <> j) @ [ [], Pwild, body ]
    | None -> brs)
;;

let rec heads k ctx = function
  | MLcons (_, c, []) -> Some (Refset.singleton c)
  | MLrel n -> Option.bind (List.nth ctx.vars (n - 1)) ~f:(fun v -> v.heads)
  | MLglob r ->
    (match Refmap.find_opt r ctx.narrowed with
     | Some h -> h
     | None -> Option.join (Refmap.find_opt r k.globals))
  | MLletin (_, v, body) ->
    heads k (push ctx { heads = heads k ctx v; field = false }) body
  | MLcase (_, s, brs) ->
    let hs = narrowings k (heads k ctx s) brs in
    Array.fold
      (Array.mapi brs ~f:(fun i (ids, _, body) -> heads k (within ctx s hs.(i) ids) body))
      ~init:(Some Refset.empty)
      ~f:union
  | MLexn _ -> Some Refset.empty
  | MLcons _
  | MLapp _
  | MLlam _
  | MLtuple _
  | MLfix _
  | MLdummy _
  | MLaxiom _
  | MLmagic _
  | MLuint _
  | MLfloat _
  | MLstring _
  | MLparray _ -> None
;;

let rec reduce k ctx = function
  | MLcase (ty, s, brs) -> case k ctx ty (reduce k ctx s) brs
  | MLletin (id, v, body) ->
    let v = reduce k ctx v in
    let body = reduce k (push ctx { heads = heads k ctx v; field = false }) body in
    if Mlutil.ast_occurs 1 body then MLletin (id, v, body) else Mlutil.ast_pop body
  | MLlam (id, body) -> MLlam (id, reduce k (push (enter ctx) unknown) body)
  | MLfix (i, ids, bodies) ->
    let ctx = Array.fold ids ~init:(enter ctx) ~f:(fun ctx _ -> push ctx unknown) in
    MLfix (i, ids, Array.map bodies ~f:(reduce k ctx))
  | a -> Mlutil.ast_map (reduce k ctx) a

and case k ctx ty s brs =
  let h = heads k ctx s in
  let hs = narrowings k h brs in
  let branch i (ids, p, body) = ids, p, reduce k (within ctx s hs.(i) ids) body in
  let custom = Table.is_custom_match brs in
  let whole () = MLcase (ty, s, Array.mapi brs ~f:branch) in
  match Option.bind h ~f:(kept brs) with
  | Some [ i ] ->
    (match brs.(i) with
     | [], _, body -> reduce k (narrow ctx s hs.(i)) body
     | br when not custom -> MLcase (ty, s, [| branch i br |])
     | _ -> whole ())
  | Some kept when List.length kept < Array.length brs && not custom ->
    MLcase
      (ty, s, Array.of_list (defaulted (List.map kept ~f:(fun i -> branch i brs.(i)))))
  | Some _ | None -> whole ()
;;

let body k a = Mlutil.dump_unused_vars (reduce k top a)

let decl k = function
  | Dterm (r, a, ty) ->
    let a = body k a in
    let k =
      if Table.is_custom r
      then k
      else { k with globals = Refmap.add r (heads k top a) k.globals }
    in
    k, Dterm (r, a, ty)
  | Dfix (rv, bodies, tys) -> k, Dfix (rv, Array.map bodies ~f:(body k), tys)
  | (Dind _ | Dtype _) as d -> k, d
;;

let rec elements k sel = List.fold_map sel ~init:k ~f:element

and element k (l, se) =
  match se with
  | SEdecl d ->
    let k, d = decl k d in
    k, (l, SEdecl d)
  | SEmodule m ->
    let k, me = expr k m.ml_mod_expr in
    k, (l, SEmodule { m with ml_mod_expr = me })
  | SEmodtype _ -> k, (l, se)

and expr k = function
  | MEstruct (mp, sel) ->
    let k, sel = elements k sel in
    k, MEstruct (mp, sel)
  | MEfunctor (id, mt, me) ->
    let k, me = expr k me in
    k, MEfunctor (id, mt, me)
  | (MEident _ | MEapply _) as me -> k, me
;;

let siblings struc =
  let packet acc (p : ml_ind_packet) =
    let all = Array.fold_right p.ip_consnames_ref ~f:Refset.add ~init:Refset.empty in
    Array.fold p.ip_consnames_ref ~init:acc ~f:(fun acc c -> Refmap.add c all acc)
  in
  let rec elements acc sel = List.fold sel ~init:acc ~f:element
  and element acc (_, se) =
    match se with
    | SEdecl (Dind ind) -> Array.fold ind.ind_packets ~init:acc ~f:packet
    | SEdecl (Dtype _ | Dterm _ | Dfix _) | SEmodtype _ -> acc
    | SEmodule m -> expr acc m.ml_mod_expr
  and expr acc = function
    | MEstruct (_, sel) -> elements acc sel
    | MEfunctor (_, _, me) -> expr acc me
    | MEident _ | MEapply _ -> acc
  in
  List.fold struc ~init:Refmap.empty ~f:(fun acc (_, sel) -> elements acc sel)
;;

let reduce struc ~separate =
  let start = { siblings = siblings struc; globals = Refmap.empty } in
  let file k (mp, sel) =
    let k', sel = elements k sel in
    (if separate then k else k'), (mp, sel)
  in
  List.folding_map struc ~init:start ~f:file
;;
