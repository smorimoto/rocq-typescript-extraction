open Import
open Ts_print

let pick l = List.nth_exn l (Random.int (List.length l))
let chance p = Float.O.(Random.float 1.0 < p)
let comparison a b = if Random.bool () then Equals (a, b) else Not_equals (a, b)
let letters = "abcdefghijklmnopqrstuvwxyz"

let reserved =
  [ "in"
  ; "do"
  ; "if"
  ; "of"
  ; "as"
  ; "for"
  ; "new"
  ; "var"
  ; "let"
  ; "try"
  ; "case"
  ; "else"
  ; "enum"
  ; "this"
  ; "void"
  ; "with"
  ; "null"
  ; "true"
  ; "false"
  ; "break"
  ; "catch"
  ; "class"
  ; "const"
  ; "super"
  ; "throw"
  ; "while"
  ; "yield"
  ; "delete"
  ; "export"
  ; "import"
  ; "return"
  ; "switch"
  ; "typeof"
  ; "default"
  ; "extends"
  ; "finally"
  ; "continue"
  ; "debugger"
  ; "function"
  ; "await"
  ; "is"
  ; "any"
  ; "set"
  ; "get"
  ; "out"
  ; "eval"
  ; "keyof"
  ; "never"
  ; "infer"
  ; "unique"
  ; "readonly"
  ]
;;

let word0 () =
  (* Identifier lengths vary so that lines land on both sides of the width
     limit. *)
  let n =
    match Random.int 10 with
    | 0 | 1 | 2 | 3 -> 1 + Random.int 3
    | 4 | 5 | 6 -> 3 + Random.int 6
    | 7 | 8 -> 8 + Random.int 12
    | _ -> 20 + Random.int 25
  in
  String.init n ~f:(fun _ -> letters.[Random.int 26])
;;

let rec word () =
  let w = word0 () in
  if List.mem reserved w ~equal:String.equal then word () else w
;;

let name () =
  let w = word () in
  match Random.int 40 with
  | 0 -> w ^ "ʹ"
  | 1 -> "M$" ^ w
  | 2 -> w ^ "0"
  | 3 -> "名前" ^ w
  | 4 -> "né" ^ w
  | _ -> w
;;

(* The realizers of ExtrTsBasic and ExtrTsNatBigInt, and two shaped like
   the make and set of ExtrTsPArray, which span lines: an object literal
   over several lines and a block body with a blank line. Their lines are
   short, since the printer reflows no user code, so that they fit at any
   depth the programs reach. *)
let realizers =
  [ "(<R>(t: () => R, f: () => R, b: boolean): R => (b ? t() : f()))"
  ; "(<R>(l: () => R, r: () => R, b: boolean): R => (b ? l() : r()))"
  ; "((a: boolean, b: boolean): boolean => a && b)"
  ; "((b: boolean): boolean => !b)"
  ; "((n: bigint): bigint => n + 1n)"
  ; "(<R>(fO: () => R, fS: (p: bigint) => R, n: bigint): R => (n === 0n ? fO() : fS(n - \
     1n)))"
  ; "((n: bigint, m: bigint): bigint => n + m)"
  ; "((n: bigint, m: bigint): bigint => (n > m ? n - m : 0n))"
  ; "((n: bigint): bigint => (n > 0n ? n - 1n : 0n))"
  ; "((n: bigint, m: bigint): boolean => n === m)"
  ; "((n: bigint, m: bigint): bigint => (m === 0n ? 0n : n / m))"
  ; "(<A>(d: A): PArray<A> => ({\n  default: d,\n  items: [d, d],\n}))"
  ; "(<A>(a: PArray<A>, v: A): PArray<A> => {\n\
    \  if (a.items.length > 0) {\n\
    \    return { default: v, items: [] };\n\
    \  }\n\n\
    \  return a;\n\
     })"
  ]
;;

(* An object literal over several lines, as the code of an Extract Constant
   is when its author broke it. *)
let multiline_object = "{\n  default: 0n,\n  items: [1n, 2n, 3n],\n}"
let tname () = String.capitalize (word ())

let rec ty d =
  if d <= 0
  then Name (pick [ tname (); "A"; "B"; "Nat"; "bigint"; "unknown" ], [])
  else (
    match Random.int 12 with
    | 0 | 1 | 2 | 3 | 4 -> Name (tname (), [])
    | 5 | 6 | 7 -> Name (tname (), List.init (1 + Random.int 3) ~f:(fun _ -> ty (d - 1)))
    | 8 | 9 -> Fn { tparams = []; params = [ "_", ty (d - 1) ]; result = ty (d - 1) }
    | 10 ->
      Name ("$Datatypes." ^ tname (), List.init (Random.int 3) ~f:(fun _ -> ty (d - 1)))
    | 11 when chance 0.5 -> Tuple (List.init (1 + Random.int 3) ~f:(fun _ -> ty (d - 1)))
    | _ ->
      Fn
        { tparams = unbounded (if chance 0.3 then [ "A" ] else [])
        ; params =
            List.init (Random.int 4) ~f:(fun i -> Printf.sprintf "_%d" i, ty (d - 1))
        ; result = ty (d - 1)
        })
;;

let text () =
  match Random.int 6 with
  | 0 -> "say \"hi\""
  | 1 -> "it's"
  | 2 -> "a\nb"
  | _ -> word ()
;;

let numbers () =
  List.init
    (1 + Random.int (pick [ 3; 12; 40 ]))
    ~f:(fun _ ->
      pick
        [ Number "0"; Number "1.5"; Number "-1"; Code "2"; Code "-3"; Number "123456789" ])
;;

let atom () =
  match Random.int 16 with
  | 0 | 1 | 2 | 3 | 4 -> Var (name ())
  | 13 -> Index (Var (name ()), Random.int 3)
  | 14 -> Tuple (if chance 0.3 then [] else numbers ())
  | 5 -> Text (text ())
  | 6 -> Bigint (Int.to_string (Random.int (pick [ 1000; 1_000_000_000 ])))
  | 7 ->
    Number
      (pick
         [ "0"
         ; "1.5"
         ; "-1"
         ; "NaN"
         ; "Infinity"
         ; "-Infinity"
         ; "-0"
         ; "1e+21"
         ; "1e-07"
         ; "123456789"
         ; "-12345.678901"
         ; "1.2345678901234567e+300"
         ])
  | 8 -> Code "undefined"
  | 9 ->
    Code (pick [ "[]"; "undefined"; "0n"; "true"; "Math.PI"; "-1"; multiline_object ])
  | 10 -> Field (Var (name ()), name ())
  | 11 -> Field (Field (Var (name ()), "arg0"), "arg1")
  | 12 -> Bytes (pick [ "abc"; "\x01\xff"; "q\"q" ])
  | _ -> Call (Var (name ()), [], [])
;;

let param () = name (), ty 1

let rec expr d =
  if d <= 0
  then atom ()
  else (
    match Random.int 32 with
    | 0 | 1 | 2 -> atom ()
    | 3 | 4 | 5 | 6 ->
      (* Lowering gives a callee in user code no type arguments. *)
      let f = callee (d - 1) in
      let tys =
        match f with
        | Code _ -> []
        | _ -> tyargs ()
      in
      Call (f, tys, List.init (Random.int 4) ~f:(fun _ -> expr (d - 1)))
    | 7 -> Call (Var (name ()), [], [ expr (d - 1) ])
    | 8 | 9 -> arrow (d - 1)
    | 10 | 11 -> cond (d - 1) (1 + Random.int 4)
    | 12 -> Record (fields (d - 1))
    | 13 -> Call (Helper Lazy, [], [ Arrow ([], [], Some (ty 1), Block (stmts (d - 1))) ])
    | 14 ->
      Call
        ( Arrow
            ( []
            , List.init (1 + Random.int 2) ~f:(fun _ -> param ())
            , Some (ty 1)
            , Expr (expr (d - 1)) )
        , []
        , List.init (1 + Random.int 2) ~f:(fun _ -> expr (d - 1)) )
    | 15 ->
      Call
        ( Code
            "(<R>(fO: () => R, fS: (p: bigint) => R, n: bigint): R => (n === 0n ? fO() : \
             fS(n - 1n)))"
        , []
        , [ Arrow ([], [], Some (ty 0), Expr (expr (d - 1)))
          ; Arrow ([], [ param () ], Some (ty 0), Expr (expr (d - 1)))
          ; expr (d - 1)
          ] )
    | 16 -> Call (Helper Lazy, [], [ Arrow ([], [], Some (ty 1), Expr (expr (d - 1))) ])
    | 17 -> Call (Helper Magic, [ ty 1; ty 1 ], [ expr (d - 1) ])
    | 18 -> Call (Call (Var (name ()), [], [ expr (d - 1) ]), [], [ expr (d - 1) ])
    | 19 ->
      Call
        (Field (Field (Var "$Datatypes", tname ()), name ()), tyargs (), [ expr (d - 1) ])
    | 20 -> Call (Field (Call (Var (name ()), [], []), name ()), [], [ expr (d - 1) ])
    | 21 -> Call (Helper Fail, [], [ Text (text ()) ])
    | 22 -> Field (Call (Var (name ()), [], []), name ())
    | 23 | 24 ->
      Call
        ( Code (pick realizers)
        , []
        , List.init (1 + Random.int 3) ~f:(fun _ -> expr (d - 1)) )
    | 25 -> Code (pick realizers)
    | 26 -> Call (arrow (d - 1), [], [ expr (d - 1) ])
    | 27 -> Field (cond (d - 1) (1 + Random.int 2), name ())
    | 28 -> Record [ name (), arrow (d - 1); name (), cond (d - 1) 2 ]
    | 29 ->
      Call
        ( Var (name ())
        , []
        , [ expr (d - 1); Arrow ([], [ param () ], Some (ty 1), Block (stmts (d - 1))) ]
        )
    | 30 when chance 0.4 ->
      Tuple
        (List.init
           (1 + Random.int 4)
           ~f:(fun _ -> if chance 0.3 then numbers_or_nested (d - 1) else expr (d - 1)))
    | 31 when chance 0.3 ->
      if chance 0.5
      then Call (Index (Var (name ()), Random.int 2), [], [ expr (d - 1) ])
      else Index (Call (Var (name ()), [], [ expr (d - 1) ]), Random.int 2)
    | 30 ->
      Call
        ( Call (Var (name ()), [], [ Text (word ()) ])
        , []
        , [ Arrow
              ( []
              , List.init (1 + Random.int 3) ~f:(fun _ -> param ())
              , Some (ty 1)
              , Block (stmts (d - 1)) )
          ] )
    | 31 when chance 0.5 ->
      let rec chain k e =
        if k = 0
        then e
        else
          chain
            (k - 1)
            (match Random.int 10 with
             | 0 | 1 | 2 | 3 | 4 | 5 ->
               Call
                 ( Field (e, name ())
                 , []
                 , List.init (Random.int 3) ~f:(fun _ -> expr (d - 1)) )
             | 6 -> Index (e, Random.int 3)
             | _ -> Field (e, name ()))
      in
      chain
        (2 + Random.int 4)
        (if chance 0.5 then Var (name ()) else Call (Var (name ()), [], []))
    | _ ->
      Call
        ( Field (Field (Var (name ()), name ()), name ())
        , []
        , List.init (Random.int 3) ~f:(fun _ -> expr (d - 1)) ))

and numbers_or_nested d =
  match Random.int 3 with
  | 0 -> Tuple (numbers ())
  | 1 -> Record (fields d)
  | _ -> Tuple (List.init (2 + Random.int 2) ~f:(fun _ -> expr d))

and callee d =
  match Random.int 7 with
  | 5 -> Code (pick realizers)
  | 0 -> Field (Var "$Datatypes", name ())
  | 1 -> Code "((n: bigint, m: bigint): bigint => n + m)"
  | 2 -> Helper Magic
  | 3 when d > 0 -> Call (Var (name ()), [], [ expr (d - 1) ])
  | _ -> Var (name ())

and tyargs () = if chance 0.6 then [] else List.init (1 + Random.int 2) ~f:(fun _ -> ty 1)

and arrow d =
  if chance 0.4
  then (
    let n = 2 + Random.int 3 in
    let rec chain k =
      if k = 1
      then Arrow ([], [ param () ], Some (ty 1), Expr (expr d))
      else Arrow ([], [ param () ], None, Expr (chain (k - 1)))
    in
    chain n)
  else (
    let body = if chance 0.25 then Block (stmts d) else Expr (expr d) in
    let tparams = unbounded (if chance 0.2 then [ tname () ] else []) in
    Arrow (tparams, List.init (Random.int 4) ~f:(fun _ -> param ()), Some (ty 1), body))

and cond d n =
  if n = 0
  then expr d
  else
    Cond
      ( (if chance 0.9
         then
           if chance 0.8
           then comparison (Field (Var (name ()), "tag")) (Text (tname ()))
           else comparison (Var (name ())) (Code (pick [ "-1"; "0n"; "true"; "\"x\"" ]))
         else Code "b")
      , expr d
      , cond d (n - 1) )

and fields d =
  List.init (Random.int 4) ~f:(fun _ ->
    let k = name () in
    k, if chance 0.3 then Var k else expr d)

(* Statements cover the blank lines of anti-slop's require-readable-spacing:
   one-line and broken consts, a switch in the middle of a list, and cases
   that end in a nested switch or in an arrow with a block body. *)
and stmts d =
  let const () =
    if chance 0.3
    then
      Const
        ( name ()
        , None
        , Arrow
            ( unbounded
                (List.init
                   (if chance 0.3 then 1 + Random.int 2 else 0)
                   ~f:(fun _ -> tname ()))
            , List.init (1 + Random.int 2) ~f:(fun _ -> param ())
            , Some (ty 1)
            , if d > 0 && chance 0.2 then Block (stmts (d - 1)) else Expr (expr d) ) )
    else Const (name (), Some (ty 1), expr d)
  in
  let switch () =
    Switch
      ( Field (Var (name ()), "tag")
      , List.init
          (1 + Random.int 3)
          ~f:(fun i ->
            let default = i = 2 in
            { label = (if default then None else Some (Text (tname ())))
            ; body =
                (match Random.int 6 with
                 | 0 when d > 0 -> stmts (d - 1)
                 | 1 when d > 0 ->
                   [ Return
                       (Cond
                          ( Code "b"
                          , expr (d - 1)
                          , Arrow ([], [ param () ], Some (ty 1), Block (stmts (d - 1)))
                          ))
                   ]
                 | 2 when default ->
                   [ Return (Satisfies (Var (name ()), Name ("never", []))) ]
                 | _ ->
                   (if chance 0.3 then [ Const (name (), Some (ty 1), expr d) ] else [])
                   @ [ Return (expr d) ])
            }) )
  in
  let middle =
    List.init (Random.int 4) ~f:(fun _ -> if chance 0.1 then switch () else const ())
  in
  middle @ [ (if chance 0.3 then switch () else Return (expr d)) ]
;;

let type_decl () =
  let tparams =
    unbounded
      (if chance 0.3 then List.init (1 + Random.int 3) ~f:(fun _ -> tname ()) else [])
  in
  if chance 0.5
  then
    Alias
      { name = tname ()
      ; tparams
      ; def =
          (match Random.int 4 with
           | 0 ->
             Union
               (List.init
                  (2 + Random.int 6)
                  ~f:(fun _ -> Name (tname (), if chance 0.3 then [ ty 0 ] else [])))
           | 1 ->
             Fn
               { tparams = []
               ; params = []
               ; result =
                   Union (List.init (2 + Random.int 4) ~f:(fun _ -> Name (tname (), [])))
               }
           | 2 -> ty 2
           | _ -> Name (tname (), []))
      }
  else
    Interface
      { name = tname ()
      ; tparams
      ; fields =
          ("tag", Literal (tname ()))
          :: List.init (Random.int 3) ~f:(fun _ -> name (), ty 2)
      }
;;

let decl () =
  let d = 1 + Random.int 4 in
  match Random.int 8 with
  | 1 | 2 | 3 ->
    let tparams =
      unbounded
        (if chance 0.3 then List.init (1 + Random.int 2) ~f:(fun _ -> tname ()) else [])
    in
    let params = List.init (Random.int 4) ~f:(fun _ -> param ()) in
    let result = ty 2 in
    let body =
      match stmts d with
      | [ Return e ] -> Expr e
      | ss -> Block ss
    in
    { exported = chance 0.8
    ; decl =
        Value
          { name = name ()
          ; ty = None
          ; value = Arrow (tparams, params, Some result, body)
          }
    }
  | 4 | 5 ->
    { exported = chance 0.8
    ; decl = Value { name = name (); ty = Some (ty 2); value = expr d }
    }
  | 6 ->
    { exported = true
    ; decl =
        Value
          { name = tname ()
          ; ty = None
          ; value =
              Module_object
                (List.init (Random.int 4) ~f:(fun _ ->
                   let k = name () in
                   ( k
                   , if chance 0.2
                     then Module_object [ name (), Var (name ()) ]
                     else Var (name ()) )))
          }
    }
  | _ -> { exported = chance 0.8; decl = Type (type_decl ()) }
;;

(* A realiser of Extract Inductive, declared once. Drawing these after the
   other declarations keeps the draws of those, and so the declarations
   themselves, unchanged. *)
let realiser () =
  { exported = true
  ; decl = Value { name = name (); ty = None; value = Code (pick realizers) }
  }
;;

(* A const that reads properties off a chain of calls, drawn last for the
   same reason. *)
let chain_read () =
  let rec calls k e =
    if k = 0
    then e
    else
      calls
        (k - 1)
        (Call (Field (e, name ()), [], List.init (Random.int 3) ~f:(fun _ -> atom ())))
  in
  let rec reads k e =
    if k = 0
    then e
    else
      reads (k - 1) (if chance 0.3 then Index (e, Random.int 3) else Field (e, name ()))
  in
  let head =
    if chance 0.5 then Var (name ()) else Call (Var (name ()), [], [ atom () ])
  in
  { exported = chance 0.8
  ; decl =
      Value
        { name = name ()
        ; ty = Some (ty 0)
        ; value = reads (1 + Random.int 3) (calls (2 + Random.int 3) head)
        }
  }
;;

(* A const of a curried function whose name and type may leave no room on
   their line, so both the line after its [=] and the arrows break, drawn
   last for the same reason. *)
let long_chain () =
  let long lo hi =
    String.init (lo + Random.int (hi - lo)) ~f:(fun _ -> letters.[Random.int 26])
  in
  let rec chain k =
    if k = 1
    then Arrow ([], [ param () ], Some (ty 1), Expr (expr 1))
    else Arrow ([], [ param () ], None, Expr (chain (k - 1)))
  in
  { exported = true
  ; decl =
      Value
        { name = long 20 50
        ; ty = Some (Name (String.capitalize (long 30 60), []))
        ; value = chain (2 + Random.int 3)
        }
  }
;;

(* A destructuring of the members of a group, some renamed, drawn last for
   the same reason. *)
let members () =
  { exported = chance 0.8
  ; decl =
      Members
        { fields =
            List.init
              (1 + Random.int 6)
              ~f:(fun _ ->
                let k = name () in
                k, if chance 0.3 then "M$" ^ k else k)
        ; source = name (), List.init (Random.int 3) ~f:(fun _ -> name ())
        }
  }
;;

(* The call of a functor with explicit type arguments, applied again to
   each further argument, of a functor and to modules of this file or of
   an imported one. *)
let applied () =
  let module_ () =
    if chance 0.3 then Field (Var "$Datatypes", tname ()) else Var (tname ())
  in
  List.fold
    (List.init (Random.int 2) ~f:(fun _ -> module_ ()))
    ~init:(Call (module_ (), List.init (Random.int 3) ~f:(fun _ -> ty 1), [ module_ () ]))
    ~f:(fun f a -> Call (f, [], [ a ]))
;;

(* The members of an object bound by a destructuring, as a functor body
   binds those of a parameter at its top, and those of an application
   after the application. *)
let bind source =
  Bind
    ( List.init
        (1 + Random.int 2)
        ~f:(fun _ ->
          let k = name () in
          k, if chance 0.3 then k ^ "0" else k)
    , Var source )
;;

(* A functor: a generic arrow, curried per parameter, whose block body
   binds members of a parameter, declares the members, among them an
   application of a functor-typed parameter, the object of a module
   nested in the body, and a functor nested in the body, and returns their
   object, or, when every member is hoisted, whose body is the object of
   the hoisted members, drawn last for the same reason. *)
let functor_ () =
  let tparams = List.init (1 + Random.int 3) ~f:(fun _ -> tname ()) in
  let args = List.map tparams ~f:(fun t -> Name (t, [])) in
  let parameter () = tname (), Name (tname (), if chance 0.3 then [] else args) in
  let result = Name (tname (), if chance 0.2 then [] else args) in
  let locals = List.init (1 + Random.int 4) ~f:(fun _ -> name ()) in
  let binds = if chance 0.4 then [ bind (tname ()) ] else [] in
  let const x =
    match Random.int 5 with
    | 0 | 1 ->
      Const
        ( x
        , None
        , Arrow
            ( []
            , List.init (Random.int 3) ~f:(fun _ -> param ())
            , Some (ty 1)
            , if chance 0.2 then Block (stmts 1) else Expr (expr 1) ) )
    | 2 ->
      Const
        ( x
        , None
        , Module_object
            (List.init
               (1 + Random.int 4)
               ~f:(fun _ ->
                 let k = name () in
                 k, Var (if chance 0.5 then x ^ "$" ^ k else k))) )
    | 3 ->
      Const
        ( x
        , None
        , Arrow
            ( unbounded [ tname () ]
            , [ param () ]
            , Some (ty 1)
            , if chance 0.5 then Block (stmts 1) else Expr (applied ()) ) )
    | _ -> Const (x, Some (ty 1), expr 1)
  in
  let applied =
    if chance 0.3
    then (
      let x = tname () in
      ( [ x ]
      , Const
          ( x
          , None
          , Call
              ( Var (tname ())
              , List.init (Random.int 3) ~f:(fun _ -> ty 1)
              , [ Var (tname ()) ] ) )
        :: (if chance 0.5 then [ bind x ] else []) ))
    else [], []
  in
  let body =
    if chance 0.2
    then Expr (Record (List.map locals ~f:(fun x -> x, Var (tname () ^ "$" ^ x))))
    else
      Block
        (binds
         @ snd applied
         @ List.map locals ~f:const
         @ [ Return (Record (List.map (fst applied @ locals) ~f:(fun x -> x, Var x))) ])
  in
  let rec chain = function
    | [] -> Arrow (unbounded tparams, [ parameter () ], Some result, body)
    | [ p ] -> Arrow ([], [ p ], Some result, body)
    | p :: rest -> Arrow ([], [ p ], None, Expr (chain rest))
  in
  let value =
    match List.init (Random.int 3) ~f:(fun _ -> parameter ()) with
    | [] -> chain []
    | p :: rest -> Arrow (unbounded tparams, [ p ], None, Expr (chain rest))
  in
  { exported = chance 0.8; decl = Value { name = tname (); ty = None; value } }
;;

(* The interface of a module type, with function-typed members, the
   empty record of a memberless one, or the generic arrow type of a
   functor signature, curried per parameter, drawn last for the same
   reason. *)
let signature () =
  if chance 0.15
  then
    { exported = true
    ; decl =
        Type
          (Alias
             { name = tname ()
             ; tparams = []
             ; def = Name ("Record", [ Name ("never", []); Name ("never", []) ])
             })
    }
  else if chance 0.2
  then (
    let tparams = List.init (Random.int 3) ~f:(fun _ -> tname ()) in
    let args = List.map tparams ~f:(fun t -> Name (t, [])) in
    let parameter () = tname (), Name (tname (), if chance 0.3 then [] else args) in
    let rec arrow tparams = function
      | [] -> Name (tname (), args)
      | p :: rest ->
        Fn { tparams = unbounded tparams; params = [ p ]; result = arrow [] rest }
    in
    { exported = chance 0.8
    ; decl =
        Type
          (Alias
             { name = tname ()
             ; tparams = []
             ; def =
                 arrow tparams (List.init (1 + Random.int 3) ~f:(fun _ -> parameter ()))
             })
    })
  else (
    let field () =
      ( name ()
      , match Random.int 3 with
        | 0 -> ty 1
        | 1 ->
          Fn
            { tparams = unbounded (if chance 0.3 then [ "A" ] else [])
            ; params = List.init (Random.int 4) ~f:(fun i -> Printf.sprintf "_%d" i, ty 1)
            ; result = ty 1
            }
        | _ ->
          Fn
            { tparams = []
            ; params = List.init (1 + Random.int 3) ~f:(fun _ -> param ())
            ; result = ty 1
            } )
    in
    { exported = chance 0.8
    ; decl =
        Type
          (Interface
             { name = tname ()
             ; tparams = unbounded (List.init (Random.int 3) ~f:(fun _ -> tname ()))
             ; fields = List.init (1 + Random.int 5) ~f:(fun _ -> field ())
             })
    })
;;

(* An application: a call with explicit type arguments, applied again to
   each further argument, of a functor and to modules of this file or of
   an imported one, or, when partial, a generic arrow over the parameters
   left whose body is that call, drawn last for the same reason. *)
let application () =
  let value =
    if chance 0.3
    then
      Arrow
        ( unbounded (List.init (Random.int 3) ~f:(fun _ -> tname ()))
        , [ tname (), ty 1 ]
        , Some (ty 1)
        , Expr (applied ()) )
    else applied ()
  in
  { exported = chance 0.8; decl = Value { name = tname (); ty = None; value } }
;;

(* An over-applied call whose callee is a call, f<T>(a, b)(c)(d), whose
   head is a name or a member and whose first call may have more arguments
   than those after it, as an initialiser, a returned value, or an
   argument, drawn last for the same reason. *)
let curried_call () =
  let d = 1 + Random.int 3 in
  let head =
    match Random.int 3 with
    | 0 -> Field (Var (name ()), name ())
    | 1 -> Field (Field (Var "$Datatypes", tname ()), name ())
    | _ -> Var (name ())
  in
  let call =
    List.fold
      (List.init (1 + Random.int 2) ~f:(fun _ -> expr (d - 1)))
      ~init:
        (Call (head, tyargs (), List.init (1 + Random.int 3) ~f:(fun _ -> expr (d - 1))))
      ~f:(fun f a -> Call (f, [], [ a ]))
  in
  let params () = List.init (Random.int 3) ~f:(fun _ -> param ()) in
  let annotation, value =
    match Random.int 4 with
    | 0 -> Some (ty 1), call
    | 1 -> None, Arrow ([], params (), Some (ty 1), Expr call)
    | 2 ->
      ( None
      , Arrow
          ( []
          , params ()
          , Some (ty 1)
          , Block [ Const (name (), Some (ty 1), expr d); Return call ] ) )
    | _ ->
      ( Some (ty 1)
      , Call
          (Var (name ()), [], call :: List.init (Random.int 2) ~f:(fun _ -> expr (d - 1)))
      )
  in
  { exported = chance 0.8; decl = Value { name = name (); ty = annotation; value } }
;;

(* A function whose body declares a variable that a switch, whose cases
   end in [break], or a chain of tests with [else] assigns, drawn last for
   the same reason. *)
let assigning () =
  let d = 1 + Random.int 3 in
  let test () =
    if chance 0.7
    then comparison (Field (Var (name ()), "tag")) (Text (tname ()))
    else Code (pick [ "b"; "n === 0"; "p > 1 && p % 2 === 1" ])
  in
  let x = name () in
  let rec assigned k =
    (if chance 0.3 then [ Const (name (), Some (ty 1), expr d) ] else [])
    @ if k > 0 && chance 0.2 then branches (k - 1) else [ Assign (x, expr d) ]
  and branches k =
    if chance 0.5
    then (
      let n = 1 + Random.int 3 in
      [ Switch
          ( Field (Var (name ()), "tag")
          , List.init n ~f:(fun i ->
              { label = (if i = 2 then None else Some (Text (tname ())))
              ; body = (assigned k @ if i < n - 1 then [ Break ] else [])
              }) )
      ])
    else (
      let rec chain j =
        if j = 0 then assigned k else [ If (test (), assigned k, chain (j - 1)) ]
      in
      chain (1 + Random.int 3))
  in
  let returning =
    if chance 0.3 then [ If (test (), stmts (d - 1) @ [ Return (expr d) ], []) ] else []
  in
  let body = returning @ (Let (x, ty 1) :: branches 2) @ stmts d in
  { exported = chance 0.8
  ; decl =
      Value
        { name = name ()
        ; ty = None
        ; value =
            Arrow
              ( []
              , List.init (Random.int 3) ~f:(fun _ -> param ())
              , Some (ty 2)
              , Block body )
        }
  }
;;

(* A chain of conditional types with [arms] tests, the last of which may
   hold another chain in its first arm, as the type of a declaration whose
   type depends on a term is. *)
let rec conditional d arms =
  let yes = if arms = 1 && chance 0.2 then conditional (d - 1) 1 else ty (d - 1) in
  Conditional
    { check = Name (pick [ "B"; "C" ], [])
    ; extends = Name (pick [ "true"; "false"; tname (); "$Datatypes." ^ tname () ], [])
    ; yes
    ; no = (if arms > 1 then conditional d (arms - 1) else ty (d - 1))
    }
;;

(* Type parameters of the names [names], some bounded, as a lifted binder
   of an enumeration is. *)
let bounded names =
  List.map names ~f:(fun name ->
    { name
    ; bound =
        (if chance 0.4
         then Some (Name (pick [ "boolean"; tname (); "$Datatypes." ^ tname () ], []))
         else None)
    })
;;

(* A declaration over bounded type parameters whose types are chains of
   conditional types: an alias, an interface, a function, or a constant
   whose annotation and cast name one, drawn last for the same reason. *)
let dependent () =
  let tparams = bounded (List.init (1 + Random.int 3) ~f:(fun _ -> tname ())) in
  let dty () =
    match Random.int 4 with
    | 0 | 1 -> conditional 2 (1 + Random.int 3)
    | 2 -> Union [ conditional 1 1; Name (tname (), []) ]
    | _ -> ty 2
  in
  let decl =
    match Random.int 4 with
    | 0 -> Type (Alias { name = tname (); tparams; def = dty () })
    | 1 ->
      Type
        (Interface
           { name = tname ()
           ; tparams
           ; fields =
               ("tag", Literal (tname ()))
               :: List.init (1 + Random.int 3) ~f:(fun _ -> name (), dty ())
           })
    | 2 ->
      Value
        { name = name ()
        ; ty = None
        ; value =
            Arrow
              ( tparams
              , List.init (Random.int 3) ~f:(fun _ -> name (), dty ())
              , Some (dty ())
              , Expr (Call (Helper Magic, [ dty (); dty () ], [ Var (name ()) ])) )
        }
    | _ ->
      Value
        { name = name ()
        ; ty = Some (Name (tname (), [ dty (); ty 0 ]))
        ; value = Call (Var (name ()), [ dty () ], [])
        }
  in
  { exported = chance 0.8; decl }
;;

(* A function whose body copies its parameters to variables and loops, as
   a self tail call does, with tests and cases that return, or assign the
   variables and continue, and assignments that end the loop's body,
   drawn last for the same reason. *)
let looping () =
  let d = 1 + Random.int 3 in
  let params = List.init (1 + Random.int 3) ~f:(fun _ -> param ()) in
  let copies = List.map params ~f:(fun _ -> name ()) in
  let test () =
    if chance 0.7
    then comparison (Field (Var (pick copies), "tag")) (Text (tname ()))
    else Code (pick [ "b"; "n0 === 0"; "p0 > 1 && p0 % 2 === 1" ])
  in
  let assigned () =
    List.filter_map copies ~f:(fun x ->
      if chance 0.7 then Some (Assign (x, expr d)) else None)
  in
  let jumping () =
    (if chance 0.3 then [ Const (name (), Some (ty 1), expr d) ] else [])
    @ assigned ()
    @ [ Continue ]
  in
  let leaving () = stmts (d - 1) @ [ Return (expr d) ] in
  let branch () =
    if chance 0.5
    then (
      let n = 1 + Random.int 3 in
      Switch
        ( Field (Var (pick copies), "tag")
        , List.init n ~f:(fun i ->
            { label = (if i = 2 then None else Some (Text (tname ())))
            ; body = (if chance 0.5 then jumping () else leaving ())
            }) ))
    else If (test (), (if chance 0.5 then jumping () else leaving ()), [])
  in
  let body =
    (If (test (), leaving (), []) :: List.init (Random.int 2) ~f:(fun _ -> branch ()))
    @ stmts (d - 1)
    @ assigned ()
  in
  { exported = chance 0.8
  ; decl =
      Value
        { name = name ()
        ; ty = None
        ; value =
            Arrow
              ( []
              , params
              , Some (ty 2)
              , Block
                  (List.map2_exn copies params ~f:(fun x (p, _) ->
                     Variable (x, if chance 0.7 then Var p else expr d))
                   @ [ Loop body ]) )
        }
  }
;;

let generate count =
  Random.init 20261101;
  let decls = List.init count ~f:(fun _ -> decl ()) in
  let realisers = List.init (count / 20) ~f:(fun _ -> realiser ()) in
  let chain_reads = List.init (count / 10) ~f:(fun _ -> chain_read ()) in
  let long_chains = List.init (count / 20) ~f:(fun _ -> long_chain ()) in
  let members = List.init (count / 10) ~f:(fun _ -> members ()) in
  let functors = List.init (count / 20) ~f:(fun _ -> functor_ ()) in
  let signatures = List.init (count / 20) ~f:(fun _ -> signature ()) in
  let applications = List.init (count / 20) ~f:(fun _ -> application ()) in
  let curried_calls = List.init (count / 10) ~f:(fun _ -> curried_call ()) in
  let assignings = List.init (count / 10) ~f:(fun _ -> assigning ()) in
  (* Lengths on both sides of the print width. No [Random] use, so the
     programs above keep the draws they had. *)
  let literal_bodies =
    List.init 12 ~f:(fun i ->
      let n = 4 + (i * 6) in
      let tname = String.make n 'p' in
      let elem = String.make (4 + (i * 5)) 'e' in
      let body =
        if Int.rem i 2 = 0
        then Printf.sprintf "[%s]" elem
        else Printf.sprintf "({ left: %s, right: %s })" elem elem
      in
      { exported = true
      ; decl =
          Value
            { name = "literalBody" ^ Int.to_string i
            ; ty =
                Some
                  (Fn
                     { tparams = []
                     ; params = [ "_0", Name (tname, []) ]
                     ; result = Name ("T", [])
                     })
            ; value =
                Code
                  (Printf.sprintf "<A>(line: readonly [A, A]): readonly A[] => %s" body)
            }
      })
  in
  let index_calls =
    List.init 8 ~f:(fun i ->
      let arg =
        if i = 0 then Tuple [] else Code ("[" ^ String.make (8 + (i * 8)) 'n' ^ "]")
      in
      { exported = false
      ; decl =
          Value
            { name = "indexedCall" ^ Int.to_string i
            ; ty = Some (Name ("T", []))
            ; value = Call (Index (Var "a", 0), [], [ arg ])
            }
      })
  in
  (* No [Random] use. A tuple annotation that alone passes the print width
     breaks inside the tuple, and the initialiser stays after it. *)
  let long_annotations =
    List.init 6 ~f:(fun i ->
      let rec nest k =
        if k = 0 then Name ("number", []) else Tuple [ nest (k - 1); Name ("number", []) ]
      in
      { exported = true
      ; decl =
          Value
            { name = "longAnnotation" ^ Int.to_string i
            ; ty = Some (nest (i + 1))
            ; value = Code "0"
            }
      })
  in
  let dependents = List.init (count / 10) ~f:(fun _ -> dependent ()) in
  let loopings = List.init (count / 10) ~f:(fun _ -> looping ()) in
  decls
  @ realisers
  @ chain_reads
  @ long_chains
  @ members
  @ functors
  @ signatures
  @ applications
  @ curried_calls
  @ assignings
  @ literal_bodies
  @ index_calls
  @ long_annotations
  @ dependents
  @ loopings
;;

let render decls = program { header = None; imports = []; decls }

let with_formatter config f =
  let with_file suffix f =
    let path = Stdlib.Filename.temp_file "random-programs-" suffix in
    Exn.protect ~f:(fun () -> f path) ~finally:(fun () -> Stdlib.Sys.remove path)
  in
  with_file ".ts" (fun input ->
    with_file ".formatted.ts" (fun output ->
      let format source =
        Out_channel.write_all input ~data:source;
        let pid =
          In_channel.with_file input ~f:(fun input ->
            Out_channel.with_file output ~f:(fun output ->
              Unix.create_process
                "bunx"
                [| "bunx"
                 ; "--no-install"
                 ; "oxfmt"
                 ; "--config"
                 ; config
                 ; "--stdin-filepath=program.ts"
                |]
                (Unix.descr_of_in_channel input)
                (Unix.descr_of_out_channel output)
                Unix.stderr))
        in
        match snd (Unix.waitpid [] pid) with
        | Unix.WEXITED 0 -> In_channel.read_all output
        | Unix.WEXITED code ->
          failwith (Printf.sprintf "Oxfmt exited with status %d" code)
        | Unix.WSIGNALED signal | Unix.WSTOPPED signal ->
          failwith (Printf.sprintf "Oxfmt stopped with signal %d" signal)
      in
      f format))
;;

let smaller decls =
  let open Base_quickcheck in
  let singles =
    Shrinker.shrink [%quickcheck.shrinker: [%custom Shrinker.atomic] list] decls
  in
  let half = List.length decls / 2 in
  if half = 0
  then singles
  else
    Sequence.append
      (Sequence.of_list [ List.take decls half; List.drop decls half ])
      singles
;;

let check config decls =
  with_formatter config (fun format ->
    let source = render decls in
    let formatted = format source in
    if String.equal source formatted
    then true
    else (
      let remaining = ref 256 in
      let rec reduce decls source formatted =
        let rec search candidates =
          if !remaining = 0
          then decls, source, formatted
          else (
            match Sequence.next candidates with
            | None -> decls, source, formatted
            | Some (candidate, rest) ->
              Int.decr remaining;
              let source' = render candidate in
              let formatted' = format source' in
              if String.equal source' formatted'
              then search rest
              else reduce candidate source' formatted')
        in
        search (smaller decls)
      in
      let reduced, source, formatted = reduce decls source formatted in
      eprintf
        "Oxfmt changed a generated program. Reduced from %d to %d declarations in %d \
         attempts.\n\n\
         Input:\n\
         %s\n\
         Oxfmt output:\n\
         %s"
        (List.length decls)
        (List.length reduced)
        (256 - !remaining)
        source
        formatted;
      false))
;;

let () =
  match Array.to_list (Sys.get_argv ()) with
  | [ _; count ] -> print_string (render (generate (Int.of_string count)))
  | [ _; count; "--check"; config ] ->
    if not (check config (generate (Int.of_string count))) then Stdlib.exit 1
  | _ -> failwith "Usage: random_programs COUNT [--check OXFMT_CONFIG]"
;;
