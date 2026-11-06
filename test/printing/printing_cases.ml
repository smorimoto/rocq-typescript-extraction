open Import
open Ts_print

let value exported name ty value = { exported; decl = Value { name; ty; value } }
let alias name def = { exported = true; decl = Type (Alias { name; tparams = []; def }) }
let render decls = program { header = None; imports = []; decls }

let function_types =
  [ alias
      "FunctionOrBoolean"
      (Union [ Name ("(_: number) => number", []); Name ("boolean", []) ])
  ; alias
      "RawFunctionOrBoolean"
      (Union
         [ Raw [ Verbatim "(_: "; Hole (Name ("number", [])); Verbatim ") => number" ]
         ; Name ("boolean", [])
         ])
  ; alias
      "FunctionArray"
      (Raw
         [ Verbatim "readonly "
         ; Hole (Name ("(_: number) => number", []))
         ; Verbatim "[]"
         ])
  ]
;;

let quoted_type_tokens =
  [ alias
      "QuotedBracketFunctionOrBoolean"
      (Union [ Name ("(_: \"(\") => number", []); Name ("boolean", []) ])
  ; alias
      "QuotedAngleFunctionOrBoolean"
      (Union [ Name ("(_: \">\") => number", []); Name ("boolean", []) ])
  ; alias "ArrowLiteralOrBoolean" (Union [ Name ("\"=>\"", []); Name ("boolean", []) ])
  ]
;;

let array_types =
  [ alias
      "ConditionalArray"
      (Raw
         [ Verbatim "readonly "; Hole (Name ("1 extends 2 ? 3 : 4", [])); Verbatim "[]" ])
  ; alias
      "TupleArray"
      (Raw
         [ Verbatim "readonly "
         ; Hole (Name ("readonly [number, number]", []))
         ; Verbatim "[]"
         ])
  ]
;;

let conditional_unions =
  [ alias
      "NestedConditionalOrNumber"
      (Union
         [ Name ("Promise<string extends number ? true : false>", [])
         ; Name ("number", [])
         ])
  ; alias
      "ConditionalOrNumber"
      (Union [ Name ("string extends number ? true : false", []); Name ("number", []) ])
  ; alias
      "RawConditionalOrNumber"
      (Union
         [ Raw [ Hole (Name ("string", [])); Verbatim " extends number ? true : false" ]
         ; Name ("number", [])
         ])
  ]
;;

let indexed_type =
  [ { exported = false
    ; decl =
        Type (Alias { name = "T"; tparams = []; def = Name ("readonly unknown[]", []) })
    }
  ]
;;

let element = String.make 60 'n'

let indexed_bindings =
  [ value
      false
      "a"
      (Some (Tuple [ Name ("(xs: readonly unknown[]) => T", []) ]))
      (Tuple [ Code "(xs) => xs" ])
  ; value false element None (Number "0")
  ]
;;

let discarded_objects =
  [ value
      true
      "discardRecord"
      None
      (Arrow
         ( []
         , [ "read", Fn { tparams = []; params = []; result = Name ("number", []) } ]
         , Some (Name ("number", []))
         , Block
             [ Eval (Record [ "value", Call (Var "read", [], []) ])
             ; Eval (Module_object [ "value", Call (Var "read", [], []) ])
             ; Return (Number "0")
             ] ))
  ]
;;

let quoted_regexp = [ value true "quotedRegexp" None (Code "[/\"/u, 1]") ]

let indexed_calls =
  [ value true "x" (Some (Name ("T", []))) (Call (Index (Var "a", 0), [], [ Tuple [] ]))
  ; value
      true
      "t"
      (Some (Name ("T", [])))
      (Call (Index (Var "a", 0), [], [ Code ("[" ^ element ^ "]") ]))
  ]
;;

let tuple_annotations =
  [ value
      true
      "pair"
      (Some (Tuple [ Name ("number", []); Name ("number", []) ]))
      (Tuple [ Number "0"; Number "0" ])
  ; value
      true
      "all"
      (Some
         (Tuple
            [ Tuple
                [ Tuple [ Name ("number", []); Name ("number", []) ]
                ; Name ("number", [])
                ]
            ; Name ("number", [])
            ]))
      (Tuple [ Tuple [ Tuple [ Number "0"; Number "0" ]; Number "0" ]; Number "0" ])
  ]
;;

let long_annotation =
  let number = Name ("number", []) in
  let ty, expr =
    List.fold (List.init 6 ~f:Fn.id) ~init:(number, Number "0") ~f:(fun (ty, expr) _ ->
      Tuple [ ty; number ], Call (Var "pair0", [], [ expr; Number "0" ]))
  in
  [ value
      false
      "pair0"
      None
      (Arrow
         ( unbounded [ "A"; "B" ]
         , [ "p", Name ("A", []); "q", Name ("B", []) ]
         , Some (Tuple [ Name ("A", []); Name ("B", []) ])
         , Expr (Tuple [ Var "p"; Var "q" ]) ))
  ; value true "nest" (Some ty) expr
  ]
;;

let all =
  List.concat
    [ indexed_type
    ; function_types
    ; quoted_type_tokens
    ; array_types
    ; conditional_unions
    ; indexed_bindings
    ; discarded_objects
    ; quoted_regexp
    ; indexed_calls
    ; tuple_annotations
    ; long_annotation
    ]
;;
