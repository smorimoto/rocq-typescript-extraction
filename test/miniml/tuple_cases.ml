open Typescript_extraction_plugin.Import
(* The MiniML tuple forms, MLtuple and Ptuple, which the standard
   extraction never produces, built directly and extracted. *)

open Names
open Extraction_plugin
open Miniml
open Typescript_extraction_plugin

let file = ModPath.MPfile (DirPath.make [ Id.of_string "Tuples" ])
let id = Id.of_string

let const name =
  { glob = GlobRef.ConstRef (Constant.make2 file (id name)); inst = InfvInst.empty }
;;

let lam names body =
  List.fold_right names ~f:(fun x body -> MLlam (Id (id x), body)) ~init:body
;;

let unpack scrutinee names body =
  MLcase
    ( Tunknown
    , scrutinee
    , [| ( List.map names ~f:(fun x -> Id (id x))
         , Ptuple (List.mapi names ~f:(fun i _ -> Prel (List.length names - i)))
         , body )
      |] )
;;

let arrows args result = List.fold_right args ~f:(fun a t -> Tarr (a, t)) ~init:result

(* A tagged inductive, whose matches in expression position are
   conditionals on the tag. Its names are pushed to the name table, as a
   declaration pushes them, since the backend names a constructor after
   its entry there. *)
let sign_kn = MutInd.make2 file (id "sign")
let sign = { glob = GlobRef.IndRef (sign_kn, 0); inst = InfvInst.empty }
let ctor j = { glob = GlobRef.ConstructRef ((sign_kn, 0), j); inst = InfvInst.empty }
let constructors = [| "NegativeOrZero"; "Positive" |]

let () =
  let push name glob =
    Nametab.push
      (Nametab.Until 1)
      (Libnames.make_path (DirPath.make [ Id.of_string "Tuples" ]) (id name))
      glob
  in
  push "sign" sign.glob;
  Array.iteri constructors ~f:(fun j name -> push name (ctor (j + 1)).glob)
;;

let sign_decl =
  Dind
    { ind_kind = Standard
    ; ind_nparams = 0
    ; ind_packets =
        [| { ip_typename = id "sign"
           ; ip_typename_ref = sign
           ; ip_consnames = Array.map constructors ~f:id
           ; ip_consnames_ref = [| ctor 1; ctor 2 |]
           ; ip_logical = false
           ; ip_sign = []
           ; ip_vars = []
           ; ip_types = [| []; [] |]
           }
        |]
    ; ind_equiv = NoEquiv
    }
;;

(* The declarations, each with the type a plugin would give it: the type of
   a tuple is unknown to MiniML, so a tuple result is Tunknown and
   reconstruction types it from the body. *)
let decls =
  [ ( "pair"
    , lam [ "x"; "y" ] (MLtuple [ MLrel 2; MLrel 1 ])
    , arrows [ Tvar 1; Tvar 2 ] Tunknown )
  ; ( "swap"
    , lam
        [ "x"; "y" ]
        (unpack
           (MLtuple [ MLrel 2; MLrel 1 ])
           [ "a"; "b" ]
           (MLtuple [ MLrel 1; MLrel 2 ]))
    , arrows [ Tvar 1; Tvar 2 ] Tunknown )
  ; ( "second"
    , lam
        [ "x"; "y" ]
        (MLletin
           ( Id (id "p")
           , MLtuple [ MLrel 2; MLrel 1 ]
           , unpack (MLrel 1) [ "a"; "b" ] (MLrel 1) ))
    , arrows [ Tvar 1; Tvar 2 ] (Tvar 2) )
  ; ( "nested"
    , lam [ "x"; "y"; "z" ] (MLtuple [ MLrel 3; MLtuple [ MLrel 2; MLrel 1 ] ])
    , arrows [ Tvar 1; Tvar 2; Tvar 3 ] Tunknown )
  ; ( "wild"
    , lam
        [ "x"; "y" ]
        (MLcase
           ( Tunknown
           , MLtuple [ MLrel 2; MLrel 1 ]
           , [| [ Id (id "b") ], Ptuple [ Pwild; Prel 1 ], MLrel 1 |] ))
    , arrows [ Tvar 1; Tvar 2 ] (Tvar 2) )
  ; ( "inside"
    , lam
        [ "x"; "y" ]
        (MLtuple [ unpack (MLtuple [ MLrel 2; MLrel 1 ]) [ "a"; "b" ] (MLrel 1); MLrel 2 ])
    , arrows [ Tvar 1; Tvar 2 ] Tunknown )
    (* A conditional on a tag inside a tuple, whose test fills its line. *)
  ; ( "flipped"
    , lam
        [ "signOfTheFirstArgumentWhoseTagTheConditionalTestOfTheTupleReads"; "x" ]
        (MLtuple
           [ MLcase
               ( Tglob (sign, [])
               , MLrel 2
               , [| [], Pusual (ctor 1), MLcons (Tglob (sign, []), ctor 2, [])
                  ; [], Pusual (ctor 2), MLcons (Tglob (sign, []), ctor 1, [])
                 |] )
           ; MLrel 1
           ])
    , arrows [ Tglob (sign, []); Tvar 1 ] Tunknown )
  ]
;;

let state () =
  Common.State.make ~modular:false ~library:false ~keywords:Typescript.keywords ()
;;

let structure =
  let elements =
    (id "sign", SEdecl sign_decl)
    :: List.map decls ~f:(fun (name, body, ty) ->
      id name, SEdecl (Dterm (const name, body, ty)))
  in
  [ file, elements ]
;;

let source () =
  let requested = List.map decls ~f:(fun (name, _, _) -> const name), [] in
  let text, (_ : Typescript.stats) =
    Typescript.structure (state ()) ~requested structure
  in
  text
;;

let render_declaration global =
  let text, (_ : Typescript.stats) = Typescript.declaration (state ()) structure global in
  text
;;

let declaration name = render_declaration (const name)
let sign_declaration () = render_declaration sign
