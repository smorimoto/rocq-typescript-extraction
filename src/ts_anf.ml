open Import
open Extraction_plugin
module I = Ts_infer
module T = Ts_type

type head =
  | Global of Miniml.global
  | Local of int

type member =
  { head : head
  ; arity : int
  ; result : I.ty
  ; accepts : I.ty list -> bool
  }

let rec shift_from c n e =
  let go = shift_from c n in
  match e with
  | I.Local (k, tys) -> if k > c then I.Local (k + n, tys) else e
  | I.Global _ | I.Fail _ | I.Dummy | I.Uint _ | I.Float _ | I.String _ -> e
  | I.Apply (f, args) ->
    I.Apply (go f, List.map args ~f:(fun (a : I.arg) -> { a with expr = go a.expr }))
  | I.Lambda (vs, bs, t, b) -> I.Lambda (vs, bs, t, shift_from (c + List.length bs) n b)
  | I.Let (b, tp, e1, e2, t) -> I.Let (b, tp, go e1, shift_from (c + 1) n e2, t)
  | I.Construct (r, tys, es) -> I.Construct (r, tys, List.map es ~f:go)
  | I.Match m ->
    I.Match
      { m with
        scrutinee = go m.scrutinee
      ; branches =
          List.map m.branches ~f:(fun (br : I.branch) ->
            { br with body = shift_from (c + List.length br.binders) n br.body })
      }
  | I.Unpack u ->
    I.Unpack
      { u with
        tuple = go u.tuple
      ; body = shift_from (c + List.length u.binders) n u.body
      }
  | I.Fix (i, defs) ->
    let k = Array.length defs in
    I.Fix
      ( i
      , Array.map defs ~f:(fun (d : I.fixdef) ->
          { d with body = shift_from (c + k) n d.body }) )
  | I.Cast (e, a, b, k) -> I.Cast (go e, a, b, k)
  | I.Parray (es, d) -> I.Parray (List.map es ~f:go, go d)
  | I.Tuple es -> I.Tuple (List.map es ~f:go)
;;

let shift n e = if n = 0 then e else shift_from 0 n e

let free e =
  let seen = ref [] in
  let rec go d = function
    | I.Local (k, _) ->
      if k > d && not (List.mem !seen (k - d) ~equal:Int.equal)
      then seen := (k - d) :: !seen
    | I.Global _ | I.Fail _ | I.Dummy | I.Uint _ | I.Float _ | I.String _ -> ()
    | I.Apply (f, args) ->
      go d f;
      List.iter args ~f:(fun (a : I.arg) -> go d a.expr)
    | I.Lambda (_, bs, _, b) -> go (d + List.length bs) b
    | I.Let (_, _, e1, e2, _) ->
      go d e1;
      go (d + 1) e2
    | I.Construct (_, _, es) | I.Tuple es -> List.iter es ~f:(go d)
    | I.Match m ->
      go d m.scrutinee;
      List.iter m.branches ~f:(fun (br : I.branch) ->
        go (d + List.length br.binders) br.body)
    | I.Unpack u ->
      go d u.tuple;
      go (d + List.length u.binders) u.body
    | I.Fix (_, defs) ->
      Array.iter defs ~f:(fun (f : I.fixdef) -> go (d + Array.length defs) f.body)
    | I.Cast (e, _, _, _) -> go d e
    | I.Parray (es, x) ->
      List.iter es ~f:(go d);
      go d x
  in
  go 0 e;
  List.rev !seen
;;

let member_at members d f =
  let matches m =
    match f, m.head with
    | I.Global (r, tys), Global r' ->
      Table.Refset'.mem r (Table.Refset'.singleton r') && m.accepts tys
    | I.Local (k, tys), Local i -> k > d && i = k - d && m.accepts tys
    | _ -> false
  in
  Option.map (List.findi members ~f:(fun _ m -> matches m)) ~f:fst
;;

let call members d = function
  | I.Apply (f, args) ->
    (match member_at members d f with
     | Some i when List.length args >= (List.nth_exn members i).arity -> Some (i, f, args)
     | Some _ | None -> None)
  | _ -> None
;;

let lazy_ctor env r =
  match (Ts_env.ind env (Ts_env.ctor env r).ind).repr with
  | Ts_repr.Lazy _ -> true
  | Ts_repr.Tagged _ | Ts_repr.Record _ | Ts_repr.Erased | Ts_repr.Custom _ -> false
;;

let delayed_branches env (m : I.match_) =
  match (Ts_env.ind env m.ind).repr with
  | Ts_repr.Custom { selectors = None; match_code = Some _; _ } -> true
  | Ts_repr.Custom _
  | Ts_repr.Tagged _
  | Ts_repr.Record _
  | Ts_repr.Lazy _
  | Ts_repr.Erased -> false
;;

let steps_at env members d e =
  let rec go d e =
    match call members d e with
    | Some _ -> true
    | None ->
      (match e with
       | I.Local _
       | I.Global _
       | I.Fail _
       | I.Dummy
       | I.Uint _
       | I.Float _
       | I.String _
       | I.Lambda _
       | I.Fix _ -> false
       | I.Apply (f, args) ->
         go d f || List.exists args ~f:(fun (a : I.arg) -> go d a.expr)
       | I.Let (_, _, e1, e2, _) -> go d e1 || go (d + 1) e2
       | I.Construct (r, _, es) -> (not (lazy_ctor env r)) && List.exists es ~f:(go d)
       | I.Tuple es -> List.exists es ~f:(go d)
       | I.Match m ->
         go d m.scrutinee
         || ((not (delayed_branches env m))
             && List.exists m.branches ~f:(fun (br : I.branch) ->
               go (d + List.length br.binders) br.body))
       | I.Unpack u -> go d u.tuple || go (d + List.length u.binders) u.body
       | I.Cast (e, _, _, _) -> go d e
       | I.Parray (es, x) -> List.exists es ~f:(go d) || go d x)
  in
  go d e
;;

let steps env members e = steps_at env members 0 e

let tails_only env members e =
  let has d e = steps_at env members d e in
  let rec tail d e =
    match call members d e with
    | Some (i, _, args) ->
      List.length args = (List.nth_exn members i).arity
      && not (List.exists args ~f:(fun (a : I.arg) -> has d a.expr))
    | None ->
      (match e with
       | I.Let (_, _, e1, e2, _) -> (not (has d e1)) && tail (d + 1) e2
       | I.Match m when not (delayed_branches env m) ->
         (not (has d m.scrutinee))
         && List.for_all m.branches ~f:(fun (br : I.branch) ->
           tail (d + List.length br.binders) br.body)
       | I.Unpack u -> (not (has d u.tuple)) && tail (d + List.length u.binders) u.body
       | e -> not (has d e))
  in
  tail 0 e
;;

let calls env members e =
  let found = ref [] in
  let rec go d e =
    match call members d e with
    | Some (i, _, args) ->
      found := (i, d, args) :: !found;
      List.iter args ~f:(fun (a : I.arg) -> go d a.expr)
    | None ->
      (match e with
       | I.Local _
       | I.Global _
       | I.Fail _
       | I.Dummy
       | I.Uint _
       | I.Float _
       | I.String _
       | I.Lambda _
       | I.Fix _ -> ()
       | I.Apply (f, args) ->
         go d f;
         List.iter args ~f:(fun (a : I.arg) -> go d a.expr)
       | I.Let (_, _, e1, e2, _) ->
         go d e1;
         go (d + 1) e2
       | I.Construct (r, _, es) -> if not (lazy_ctor env r) then List.iter es ~f:(go d)
       | I.Tuple es -> List.iter es ~f:(go d)
       | I.Match m ->
         go d m.scrutinee;
         if not (delayed_branches env m)
         then
           List.iter m.branches ~f:(fun (br : I.branch) ->
             go (d + List.length br.binders) br.body)
       | I.Unpack u ->
         go d u.tuple;
         go (d + List.length u.binders) u.body
       | I.Cast (e, _, _, _) -> go d e
       | I.Parray (es, x) ->
         List.iter es ~f:(go d);
         go d x)
  in
  go 0 e;
  List.rev !found
;;

let delays env e ~arities =
  let rec go arities = function
    | I.Lambda _ | I.Fix _ -> true
    | I.Local _ | I.Global _ | I.Fail _ | I.Dummy | I.Uint _ | I.Float _ | I.String _ ->
      false
    | I.Apply (f, args) ->
      let arity =
        match f with
        | I.Global (r, _) -> (Ts_env.term env r).arity
        | I.Local (k, _) -> List.nth_exn arities (k - 1)
        | _ -> 0
      in
      List.length args < arity
      || go arities f
      || List.exists args ~f:(fun (a : I.arg) -> go arities a.expr)
    | I.Let (_, _, e1, e2, _) -> go arities e1 || go (I.arity e1 :: arities) e2
    | I.Construct (r, _, es) -> lazy_ctor env r || List.exists es ~f:(go arities)
    | I.Tuple es -> List.exists es ~f:(go arities)
    | I.Match m ->
      delayed_branches env m
      || go arities m.scrutinee
      || List.exists m.branches ~f:(fun (br : I.branch) ->
        go (List.map br.binders ~f:(fun _ -> 0) @ arities) br.body)
    | I.Unpack u ->
      go arities u.tuple || go (List.map u.binders ~f:(fun _ -> 0) @ arities) u.body
    | I.Cast (e, _, _, _) -> go arities e
    | I.Parray (es, x) -> List.exists es ~f:(go arities) || go arities x
  in
  go arities e
;;

let rewrite e ~local ~app =
  let rec go d e =
    match e with
    | I.Apply (f, args) ->
      let args = List.map args ~f:(fun (a : I.arg) -> { a with expr = go d a.expr }) in
      (match app d f args with
       | Some e -> e
       | None -> I.Apply (go d f, args))
    | I.Local (k, tys) -> local d k tys
    | I.Global _ | I.Fail _ | I.Dummy | I.Uint _ | I.Float _ | I.String _ -> e
    | I.Lambda (vs, bs, t, b) -> I.Lambda (vs, bs, t, go (d + List.length bs) b)
    | I.Let (b, tp, e1, e2, t) -> I.Let (b, tp, go d e1, go (d + 1) e2, t)
    | I.Construct (r, tys, es) -> I.Construct (r, tys, List.map es ~f:(go d))
    | I.Match m ->
      I.Match
        { m with
          scrutinee = go d m.scrutinee
        ; branches =
            List.map m.branches ~f:(fun (br : I.branch) ->
              { br with body = go (d + List.length br.binders) br.body })
        }
    | I.Unpack u ->
      I.Unpack
        { u with tuple = go d u.tuple; body = go (d + List.length u.binders) u.body }
    | I.Fix (i, defs) ->
      let k = Array.length defs in
      I.Fix
        (i, Array.map defs ~f:(fun (f : I.fixdef) -> { f with body = go (d + k) f.body }))
    | I.Cast (e, a, b, c) -> I.Cast (go d e, a, b, c)
    | I.Parray (es, x) -> I.Parray (List.map es ~f:(go d), go d x)
    | I.Tuple es -> I.Tuple (List.map es ~f:(go d))
  in
  go 0 e
;;

let no_app _ _ _ = None

let occurrences r e =
  let n = ref 0 in
  ignore
    (rewrite
       e
       ~local:(fun d k tys ->
         if k - d = r then Int.incr n;
         I.Local (k, tys))
       ~app:no_app
     : I.expr);
  !n
;;

let shifted k members =
  List.map members ~f:(fun m ->
    match m.head with
    | Local i -> { m with head = Local (i + k) }
    | Global _ -> m)
;;

let lift env members bs body =
  let nb = List.length bs in
  let fix =
    match body with
    | I.Let (_, [], I.Fix (0, [| d |]), e2, _) -> Some (d, `Let e2)
    | I.Apply (I.Fix (0, [| d |]), args) -> Some (d, `Apply args)
    | _ -> None
  in
  match fix with
  | Some ({ I.body = I.Lambda (_, abs, ares, abody); tparams = []; _ }, use)
    when steps_at env (shifted (List.length abs + 1 + nb) members) 0 abody ->
    let na = List.length abs in
    let reads = free abody in
    let captured =
      List.filter (List.init nb ~f:Fn.id) ~f:(fun p ->
        List.mem reads (na + 1 + nb - p) ~equal:Int.equal)
    in
    let nc = List.length captured in
    let position p = fst (List.findi_exn captured ~f:(fun _ -> Int.equal p)) in
    let reads_captured d index =
      List.map captured ~f:(fun p ->
        { I.expr = I.Local (index p + d, []); atomic = true })
    in
    let lifted_body =
      rewrite
        abody
        ~local:(fun d k tys ->
          let r = k - d in
          if r <= na
          then I.Local (k, tys)
          else if r = na + 1
          then I.Local (nc + na + 1 + d, tys)
          else if r <= na + 1 + nb
          then I.Local (na + nc - position (na + 1 + nb - r) + d, tys)
          else I.Local (r - nb + nc + d, tys))
        ~app:(fun d f args ->
          match f with
          | I.Local (k, _) when k - d = na + 1 ->
            Some
              (I.Apply
                 ( I.Local (nc + na + 1 + d, [])
                 , reads_captured d (fun p -> na + nc - position p) @ args ))
          | _ -> None)
    in
    let call d args =
      I.Apply (I.Local (nb + 1 + d, []), reads_captured d (fun p -> nb - p) @ args)
    in
    let member_body =
      match use with
      | `Apply args ->
        let outer e =
          rewrite
            e
            ~local:(fun d k tys -> I.Local ((if k - d > nb then k + 1 else k), tys))
            ~app:no_app
        in
        call 0 (List.map args ~f:(fun (a : I.arg) -> { a with expr = outer a.expr }))
      | `Let e2 ->
        rewrite
          e2
          ~local:(fun d k tys ->
            let r = k - d in
            if r = 1
            then I.Local (nb + 1 + d, tys)
            else if r <= nb + 1
            then I.Local (k - 1, tys)
            else I.Local (k, tys))
          ~app:(fun d f args ->
            match f with
            | I.Local (k, _) when k - d = 1 -> Some (call d args)
            | _ -> None)
    in
    let self =
      { head = Local 1
      ; arity = nc + na
      ; result = ares
      ; accepts = (fun tys -> List.is_empty tys)
      }
    in
    let heads = shifted 1 members @ [ self ] in
    let last = List.length heads - 1 in
    let steps_of depth e =
      List.count (calls env (shifted depth heads) e) ~f:(fun (i, _, _) -> i = last)
    in
    if
      occurrences (nb + 1) member_body = steps_of nb member_body
      && occurrences (nc + na + 1) lifted_body = steps_of (nc + na) lifted_body
    then
      Some
        ( heads
        , member_body
        , (List.map captured ~f:(List.nth_exn bs) @ abs, ares, lifted_body) )
    else None
  | Some _ | None -> None
;;

let lift_fixes env heads lambdas =
  List.find_mapi lambdas ~f:(fun j (bs, _, body) ->
    let open Option.Let_syntax in
    let%map heads, member_body, lifted = lift env heads bs body in
    let lambdas =
      List.mapi lambdas ~f:(fun i (bs, res, b) ->
        if i = j then bs, res, member_body else bs, res, shift_from (List.length bs) 1 b)
    in
    heads, lambdas @ [ lifted ])
;;

let binder name ty = { I.id = Miniml.Id (Names.Id.of_string name); ty }

let rec atomic = function
  | I.Local _ | I.Global _ | I.Dummy | I.Uint _ | I.Float _ | I.String _ -> true
  | I.Construct (_, _, es) | I.Tuple es -> List.for_all es ~f:atomic
  | I.Cast (e, _, _, _) -> atomic e
  | I.Apply _
  | I.Lambda _
  | I.Let _
  | I.Match _
  | I.Unpack _
  | I.Fix _
  | I.Fail _
  | I.Parray _ -> false
;;

let type_of env e =
  let rec go = function
    | I.Apply (I.Global (r, tys), args) ->
      let t = T.subst tys (Ts_env.term env r).schema.ty in
      let arity = List.length args in
      let params, result = T.split arity t in
      if List.length params = arity then Some result else None
    | I.Construct (r, tys, _) -> Some (T.Glob ((Ts_env.ctor env r).ind, tys))
    | I.Match m -> Some m.result
    | I.Unpack u -> Some u.result
    | I.Let (_, _, _, _, t) | I.Cast (_, _, t, _) -> Some t
    | I.Tuple es -> Option.map (Option.all (List.map es ~f:go)) ~f:(fun ts -> T.Tuple ts)
    | I.Apply _
    | I.Local _
    | I.Global _
    | I.Lambda _
    | I.Fix _
    | I.Fail _
    | I.Dummy
    | I.Uint _
    | I.Float _
    | I.String _
    | I.Parray _ -> None
  in
  let open Option.Let_syntax in
  let%bind t = go e in
  match T.zonk t with
  | _ -> Some t
  | exception T.Lost -> None
;;

let shift_branches (m : I.match_) s n =
  { m with
    scrutinee = s
  ; branches =
      List.map m.branches ~f:(fun (br : I.branch) ->
        { br with body = shift_from (List.length br.binders) n br.body })
  }
;;

let with_expr (a : I.arg) e =
  { I.expr = e
  ; atomic =
      (a.atomic
       ||
       match e with
       | I.Local _ -> true
       | _ -> false)
  }
;;

let normalise env members e =
  let has d e = steps_at env members d e in
  let rec bind d e k =
    if not (has d e)
    then k d e
    else (
      match call members d e with
      | Some (i, f, args) ->
        let m = List.nth_exn members i in
        bind_list
          d
          (List.map args ~f:(fun (a : I.arg) -> a.expr))
          (fun d' es ->
             let args' = List.map2_exn args es ~f:with_expr in
             let now, extra = List.split_n args' m.arity in
             let site = I.Apply (shift (d' - d) f, now) in
             let value =
               match extra with
               | [] -> I.Local (1, [])
               | _ ->
                 I.Apply
                   ( I.Local (1, [])
                   , List.map extra ~f:(fun (a : I.arg) ->
                       { a with I.expr = shift 1 a.expr }) )
             in
             I.Let (binder "v" m.result, [], site, k (d' + 1) value, m.result))
      | None ->
        (match e with
         | I.Apply (f, args) ->
           bind_list
             d
             (f :: List.map args ~f:(fun (a : I.arg) -> a.expr))
             (fun d' -> function
               | f' :: es -> k d' (I.Apply (f', List.map2_exn args es ~f:with_expr))
               | [] -> CErrors.anomaly (Pp.str "Ts_anf.bind: an application has a head."))
         | I.Construct (r, tys, es) ->
           bind_list d es (fun d' es' -> k d' (I.Construct (r, tys, es')))
         | I.Tuple es -> bind_list d es (fun d' es' -> k d' (I.Tuple es'))
         | I.Parray (es, x) ->
           bind_list d (x :: es) (fun d' -> function
             | x' :: es' -> k d' (I.Parray (es', x'))
             | [] -> CErrors.anomaly (Pp.str "Ts_anf.bind: an array has a default."))
         | I.Cast (e1, a, b, c) -> bind d e1 (fun d' e1' -> k d' (I.Cast (e1', a, b, c)))
         | I.Let (b, tp, e1, e2, t) ->
           I.Let (b, tp, stmt ~tail:false d e1, bind (d + 1) e2 k, t)
         | I.Match m when delayed_branches env m ->
           bind d m.scrutinee (fun d' s -> k d' (I.Match (shift_branches m s (d' - d))))
         | I.Match m ->
           let t = m.result in
           I.Let
             (binder "result" t, [], stmt ~tail:false d e, k (d + 1) (I.Local (1, [])), t)
         | I.Unpack u ->
           let t = u.result in
           I.Let
             (binder "result" t, [], stmt ~tail:false d e, k (d + 1) (I.Local (1, [])), t)
         | I.Local _
         | I.Global _
         | I.Fail _
         | I.Dummy
         | I.Uint _
         | I.Float _
         | I.String _
         | I.Lambda _
         | I.Fix _ -> k d e))
  and bind_list d es k =
    match es with
    | [] -> k d []
    | e :: rest when (not (atomic e)) && (not (has d e)) && List.exists rest ~f:(has d) ->
      (match type_of env e with
       | Some t ->
         I.Let
           ( binder "x" t
           , []
           , e
           , bind_list
               (d + 1)
               (List.map rest ~f:(shift 1))
               (fun d2 rest' -> k d2 (I.Local (d2 - d, []) :: rest'))
           , t )
       | None -> bind_rest d e rest k)
    | e :: rest -> bind_rest d e rest k
  and bind_rest d e rest k =
    bind d e (fun d1 e' ->
      bind_list
        d1
        (List.map rest ~f:(shift (d1 - d)))
        (fun d2 rest' -> k d2 (shift (d2 - d1) e' :: rest')))
  and stmt ~tail d e =
    match call members d e with
    | Some (i, _, args) when tail && List.length args = (List.nth_exn members i).arity ->
      untangle (bind d e (fun _ e' -> e'))
    | Some _ -> bind d e (fun _ e' -> e')
    | None ->
      (match e with
       | I.Let (b, tp, e1, e2, t) ->
         (match call members d e1 with
          | Some (i, f, args) when List.length args = (List.nth_exn members i).arity ->
            bind_list
              d
              (List.map args ~f:(fun (a : I.arg) -> a.expr))
              (fun d' es ->
                 I.Let
                   ( b
                   , tp
                   , I.Apply (shift (d' - d) f, List.map2_exn args es ~f:with_expr)
                   , stmt ~tail (d' + 1) (shift_from 1 (d' - d) e2)
                   , t ))
          | Some _ | None -> I.Let (b, tp, stmt ~tail:false d e1, stmt ~tail (d + 1) e2, t))
       | I.Match m when not (delayed_branches env m) ->
         bind d m.scrutinee (fun d' s ->
           I.Match
             { m with
               scrutinee = s
             ; branches =
                 List.map m.branches ~f:(fun (br : I.branch) ->
                   let n = List.length br.binders in
                   { br with body = stmt ~tail (d' + n) (shift_from n (d' - d) br.body) })
             })
       | I.Match m ->
         bind d m.scrutinee (fun d' s -> I.Match (shift_branches m s (d' - d)))
       | I.Unpack u ->
         bind d u.tuple (fun d' t ->
           let n = List.length u.binders in
           I.Unpack
             { u with
               tuple = t
             ; body = stmt ~tail (d' + n) (shift_from n (d' - d) u.body)
             })
       | _ -> bind d e (fun _ e' -> e'))
  and untangle = function
    | I.Let (_, [], site, I.Local (1, []), _) -> site
    | I.Let (b, tp, e1, e2, t) -> I.Let (b, tp, e1, untangle e2, t)
    | e -> e
  in
  stmt ~tail:true 0 e
;;
