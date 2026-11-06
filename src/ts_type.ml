open Import
open Names
open Extraction_plugin
open Miniml

type t =
  | Var of int
  | Meta of meta
  | Glob of global * t list
  | Arrow of t * t
  | Erased
  | Never
  | Tuple of t list
  | Union of t list
  | Cond of
      { on : t
      ; arms : (global * t) list
      }
  | Forall of int list * t

and meta =
  { id : int
  ; lost : bool
  ; mutable contents : t option
  }

exception Lost

type tparam =
  { hint : Id.t option
  ; bound : t option
  }

type schema =
  { tparams : tparam list
  ; ty : t
  }

let counter = ref 0

let fresh_meta lost =
  Int.incr counter;
  Meta { id = !counter; lost; contents = None }
;;

let meta () = fresh_meta false
let lost () = fresh_meta true

let rec of_ml = function
  | Tmeta { contents = Some t; _ } -> of_ml t
  | Tmeta { contents = None; _ } | Tunknown | Taxiom -> lost ()
  | Tarr (a, b) -> Arrow (of_ml a, of_ml b)
  | Tglob (r, args) -> Glob (r, List.map args ~f:of_ml)
  | Tvar i | Tvar' i -> Var i
  | Tdummy _ -> Erased
;;

let schema n ty =
  { tparams = List.init n ~f:(fun _ -> { hint = None; bound = None }); ty }
;;

let bound = ref 0

let fresh () =
  Int.decr bound;
  !bound
;;

let rec resolve = function
  | Meta { contents = Some t; _ } -> resolve t
  | t -> t
;;

let same m m' = m.id = m'.id

let bind m t =
  match m.contents with
  | None -> m.contents <- Some t
  | Some _ -> CErrors.anomaly (Pp.str "Ts_type.bind: a meta is bound once.")
;;

let rec occurs m = function
  | Meta { contents = Some t; _ } -> occurs m t
  | Meta m' -> same m m'
  | Arrow (a, b) -> occurs m a || occurs m b
  | Glob (_, ts) | Tuple ts | Union ts -> List.exists ts ~f:(occurs m)
  | Cond { on; arms } -> occurs m on || List.exists arms ~f:(fun (_, t) -> occurs m t)
  | Forall (_, t) -> occurs m t
  | Var _ | Erased | Never -> false
;;

let rec unbound acc = function
  | Meta { contents = Some t; _ } -> unbound acc t
  | Meta m -> m :: acc
  | Arrow (a, b) -> unbound (unbound acc a) b
  | Glob (_, ts) | Tuple ts | Union ts -> List.fold ts ~init:acc ~f:unbound
  | Cond { on; arms } ->
    List.fold arms ~init:(unbound acc on) ~f:(fun acc (_, t) -> unbound acc t)
  | Forall (_, t) -> unbound acc t
  | Var _ | Erased | Never -> acc
;;

let metas ts =
  List.stable_dedup
    (List.rev (List.fold ts ~init:[] ~f:unbound))
    ~compare:(fun m m' -> Int.compare m.id m'.id)
;;

let instantiate vars tys t =
  let rec go s = function
    | Meta { contents = Some t; _ } -> go s t
    | Var i as t -> Option.value (List.Assoc.find s ~equal:Int.equal i) ~default:t
    | Arrow (a, b) -> Arrow (go s a, go s b)
    | Glob (r, ts) -> Glob (r, List.map ts ~f:(go s))
    | Tuple ts -> Tuple (List.map ts ~f:(go s))
    | Union ts -> Union (List.map ts ~f:(go s))
    | Cond { on; arms } ->
      Cond { on = go s on; arms = List.map arms ~f:(fun (c, t) -> c, go s t) }
    | Forall (vs, t) ->
      Forall
        (vs, go (List.filter s ~f:(fun (i, _) -> not (List.mem vs i ~equal:Int.equal))) t)
    | (Meta { contents = None; _ } | Erased | Never) as t -> t
  in
  if List.is_empty vars then t else go (List.zip_exn vars tys) t
;;

let renamed vs t ws u =
  let common = List.map vs ~f:(fun _ -> Var (fresh ())) in
  instantiate vs common t, instantiate ws common u
;;

let same_global (r : global) (r' : global) = GlobRef.CanOrd.equal r.glob r'.glob

let rec mgu a b =
  match a, b with
  | Meta m, Meta m' when same m m' -> true
  | Meta m, t | t, Meta m ->
    (match m.contents with
     | Some u -> mgu u t
     | None when occurs m t -> false
     | None ->
       m.contents <- Some t;
       true)
  | Arrow (a, b), Arrow (a', b') -> mgu a a' && mgu b b'
  | Glob (r, ts), Glob (r', ts') when same_global r r' -> mgu_all ts ts'
  | Tuple ts, Tuple ts' | Union ts, Union ts' -> mgu_all ts ts'
  | Cond c, Cond c'
    when List.length c.arms = List.length c'.arms
         && List.for_all2_exn c.arms c'.arms ~f:(fun (r, _) (r', _) -> same_global r r')
    -> mgu c.on c'.on && mgu_all (List.map c.arms ~f:snd) (List.map c'.arms ~f:snd)
  | Forall (vs, t), Forall (ws, u) when List.length vs = List.length ws ->
    let t, u = renamed vs t ws u in
    mgu t u
  | Erased, Erased | Never, Never -> true
  | Var i, Var j when i = j -> true
  | (Var _ | Glob _ | Arrow _ | Erased | Never | Tuple _ | Union _ | Cond _ | Forall _), _
    -> false

and mgu_all ts ts' = List.length ts = List.length ts' && List.for_all2_exn ts ts' ~f:mgu

let unify a b =
  let bound = unbound (unbound [] a) b in
  match mgu a b with
  | true -> true
  | false ->
    List.iter bound ~f:(fun m -> m.contents <- None);
    false
;;

let rec equal a b =
  match resolve a, resolve b with
  | Meta m, Meta m' -> same m m'
  | Arrow (a, b), Arrow (a', b') -> equal a a' && equal b b'
  | Glob (r, ts), Glob (r', ts') -> same_global r r' && List.equal equal ts ts'
  | Tuple ts, Tuple ts' | Union ts, Union ts' -> List.equal equal ts ts'
  | Cond c, Cond c' ->
    equal c.on c'.on
    && List.equal (fun (r, t) (r', t') -> same_global r r' && equal t t') c.arms c'.arms
  | Forall (vs, t), Forall (ws, u) when List.length vs = List.length ws ->
    let t, u = renamed vs t ws u in
    equal t u
  | Var i, Var j -> i = j
  | Erased, Erased | Never, Never -> true
  | ( ( Meta _
      | Arrow _
      | Glob _
      | Tuple _
      | Union _
      | Cond _
      | Forall _
      | Var _
      | Erased
      | Never )
    , _ ) -> false
;;

let subst tys t = instantiate (List.mapi tys ~f:(fun i _ -> i + 1)) tys t

let rec split k t =
  match resolve t with
  | Arrow (a, b) when k > 0 ->
    let params, result = split (k - 1) b in
    a :: params, result
  | t -> [], t
;;

let curried params result =
  List.fold_right params ~f:(fun a b -> Arrow (a, b)) ~init:result
;;

let is_erased t =
  match resolve t with
  | Erased -> true
  | Var _ | Meta _ | Glob _ | Arrow _ | Never | Tuple _ | Union _ | Cond _ | Forall _ ->
    false
;;

let vars ts =
  let rec collect acc = function
    | Var i -> i :: acc
    | Meta { contents = Some t; _ } -> collect acc t
    | Arrow (a, b) -> collect (collect acc a) b
    | Glob (_, ts) | Tuple ts | Union ts -> List.fold ts ~init:acc ~f:collect
    | Cond { on; arms } ->
      List.fold arms ~init:(collect acc on) ~f:(fun acc (_, t) -> collect acc t)
    | Forall (vs, t) ->
      List.filter (collect [] t) ~f:(fun i -> not (List.mem vs i ~equal:Int.equal)) @ acc
    | Meta { contents = None; _ } | Erased | Never -> acc
  in
  List.dedup_and_sort (List.fold ts ~init:[] ~f:collect) ~compare:Int.compare
;;

let rec zonk = function
  | Meta { contents = Some t; _ } -> zonk t
  | Meta { contents = None; lost = true; _ } -> raise Lost
  | Meta { contents = None; lost = false; _ } -> Never
  | Arrow (a, b) -> Arrow (zonk a, zonk b)
  | Glob (r, ts) -> Glob (r, List.map ts ~f:zonk)
  | Tuple ts -> Tuple (List.map ts ~f:zonk)
  | Union ts ->
    (match
       List.filter (List.map ts ~f:zonk) ~f:(function
         | Never -> false
         | Var _
         | Meta _
         | Glob _
         | Arrow _
         | Erased
         | Tuple _
         | Union _
         | Cond _
         | Forall _ -> true)
     with
     | [] -> Never
     | [ t ] -> t
     | ts -> Union ts)
  | Cond { on; arms } ->
    Cond { on = zonk on; arms = List.map arms ~f:(fun (c, t) -> c, zonk t) }
  | Forall (vs, t) -> Forall (vs, zonk t)
  | (Var _ | Erased | Never) as t -> t
;;

let union ts =
  let members =
    List.concat_map ts ~f:(fun t ->
      match resolve t with
      | Union ts -> ts
      | t -> [ t ])
  in
  match
    List.fold members ~init:[] ~f:(fun acc t ->
      if List.exists acc ~f:(equal t) then acc else acc @ [ t ])
  with
  | [ t ] -> t
  | ts -> Union ts
;;

let is_ctor (r : global) =
  match r.glob with
  | GlobRef.ConstructRef _ -> true
  | GlobRef.VarRef _ | GlobRef.ConstRef _ | GlobRef.IndRef _ -> false
;;

let rec reduce t ~unfold =
  match resolve t with
  | Glob (r, args) as t ->
    (match unfold r args with
     | Some d -> reduce d ~unfold
     | None -> t)
  | Tuple ts -> Tuple (List.map ts ~f:(reduce ~unfold))
  | Cond { on; arms } as t ->
    (match resolve on with
     | Glob (c, _) when is_ctor c ->
       (match List.find arms ~f:(fun (c', _) -> same_global c c') with
        | Some (_, arm) -> reduce arm ~unfold
        | None -> t)
     | Var _ | Meta _ -> t
     | Glob _ | Arrow _ | Erased | Never | Tuple _ | Union _ | Cond _ | Forall _ ->
       union (List.map arms ~f:(fun (_, arm) -> reduce arm ~unfold)))
  | (Var _ | Meta _ | Arrow _ | Erased | Never | Union _ | Forall _) as t -> t
;;
