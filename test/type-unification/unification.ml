open Typescript_extraction_plugin.Import
module Type = Typescript_extraction_plugin.Ts_type

let report name result = print_endline [%string "%{name}: %{result#Bool}"]

let global name : Extraction_plugin.Miniml.global =
  { glob = Names.GlobRef.VarRef (Names.Id.of_string name)
  ; inst = Extraction_plugin.Miniml.InfvInst.empty
  }
;;

let%expect_test "structural unification binds metas" =
  let x = Type.meta () in
  let y = Type.meta () in
  let r = global "r" in
  let a =
    Type.(
      Tuple
        [ x
        ; Arrow (y, Erased)
        ; Glob (r, [ x ])
        ; Union [ x; Never ]
        ; Cond { on = x; arms = [ r, y ] }
        ; Forall ([ 1 ], Arrow (Var 1, x))
        ])
  in
  let b =
    Type.(
      Tuple
        [ Var 3
        ; Arrow (Var 4, Erased)
        ; Glob (r, [ Var 3 ])
        ; Union [ Var 3; Never ]
        ; Cond { on = Var 3; arms = [ r, Var 4 ] }
        ; Forall ([ 2 ], Arrow (Var 2, Var 3))
        ])
  in
  report "structural unification succeeds" (Type.unify a b);
  report "first meta is bound" (Type.equal x (Type.Var 3));
  report "second meta is bound" (Type.equal y (Type.Var 4));
  report "unified structures are equal" (Type.equal a b);
  [%expect
    {|
    structural unification succeeds: true
    first meta is bound: true
    second meta is bound: true
    unified structures are equal: true
    |}];
  let z = Type.meta () in
  report "a meta unifies with itself" (Type.unify z z);
  report "a meta binds on the right" (Type.unify Type.Erased z);
  report "right meta is bound" (Type.equal z Type.Erased);
  [%expect
    {|
    a meta unifies with itself: true
    a meta binds on the right: true
    right meta is bound: true
    |}]
;;

let%expect_test "occurs checks leave metas unbound" =
  let r = global "r" in
  List.iter
    [ ("arrow", fun x -> Type.Arrow (Type.Erased, x))
    ; ("global", fun x -> Type.Glob (r, [ x ]))
    ; ("tuple", fun x -> Type.Tuple [ x ])
    ; ("union", fun x -> Type.Union [ Type.Never; x ])
    ; ("conditional", fun x -> Type.Cond { on = Type.Erased; arms = [ r, x ] })
    ; ("forall", fun x -> Type.Forall ([ 1 ], x))
    ]
    ~f:(fun (name, wrap) ->
      let x = Type.meta () in
      report [%string "occurs check rejects %{name}"] (not (Type.unify x (wrap x)));
      report
        [%string "occurs failure leaves %{name} meta unbound"]
        (List.length (Type.metas [ x ]) = 1));
  [%expect
    {|
    occurs check rejects arrow: true
    occurs failure leaves arrow meta unbound: true
    occurs check rejects global: true
    occurs failure leaves global meta unbound: true
    occurs check rejects tuple: true
    occurs failure leaves tuple meta unbound: true
    occurs check rejects union: true
    occurs failure leaves union meta unbound: true
    occurs check rejects conditional: true
    occurs failure leaves conditional meta unbound: true
    occurs check rejects forall: true
    occurs failure leaves forall meta unbound: true
    |}]
;;

let%expect_test "failed unification rolls back partial bindings" =
  let r = global "r" in
  List.iter
    [ ("arrow", fun x -> Type.Arrow (x, Type.Erased), Type.Arrow (Type.Var 1, Type.Never))
    ; ( "tuple"
      , fun x -> Type.Tuple [ x; Type.Erased ], Type.Tuple [ Type.Var 1; Type.Never ] )
    ; ( "nested list"
      , fun x ->
          ( Type.Tuple [ x; Type.Union [ Type.Erased ] ]
          , Type.Tuple [ Type.Var 1; Type.Union [] ] ) )
    ; ( "conditional"
      , fun x ->
          ( Type.Cond { on = x; arms = [ r, Type.Erased ] }
          , Type.Cond { on = Type.Var 1; arms = [ r, Type.Never ] } ) )
    ; ( "forall"
      , fun x ->
          ( Type.Forall ([ 1 ], Type.Tuple [ x; Type.Var 1; Type.Erased ])
          , Type.Forall ([ 2 ], Type.Tuple [ Type.Var 3; Type.Var 2; Type.Never ]) ) )
    ]
    ~f:(fun (name, types) ->
      let x = Type.meta () in
      let a, b = types x in
      report [%string "%{name} mismatch fails"] (not (Type.unify a b));
      report
        [%string "%{name} failure rolls back partial binding"]
        (List.length (Type.metas [ x ]) = 1);
      report [%string "%{name} meta can be reused"] (Type.unify x (Type.Var 2)));
  [%expect
    {|
    arrow mismatch fails: true
    arrow failure rolls back partial binding: true
    arrow meta can be reused: true
    tuple mismatch fails: true
    tuple failure rolls back partial binding: true
    tuple meta can be reused: true
    nested list mismatch fails: true
    nested list failure rolls back partial binding: true
    nested list meta can be reused: true
    conditional mismatch fails: true
    conditional failure rolls back partial binding: true
    conditional meta can be reused: true
    forall mismatch fails: true
    forall failure rolls back partial binding: true
    forall meta can be reused: true
    |}]
;;

let%expect_test "failed unification preserves existing bindings" =
  let x = Type.meta () in
  let bound = Type.meta () in
  report "initial binding succeeds" (Type.unify bound Type.(Tuple [ Var 7; x ]));
  [%expect {| initial binding succeeds: true |}];
  let a = Type.(Tuple [ bound; Erased ]) in
  let b = Type.(Tuple [ Tuple [ Var 7; Var 8 ]; Never ]) in
  report "failure through a bound meta" (not (Type.unify a b));
  report "existing binding is preserved" (Type.equal bound Type.(Tuple [ Var 7; x ]));
  report "nested partial binding is rolled back" (List.length (Type.metas [ bound ]) = 1);
  [%expect
    {|
    failure through a bound meta: true
    existing binding is preserved: true
    nested partial binding is rolled back: true
    |}]
;;
