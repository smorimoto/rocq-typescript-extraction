open Import
open Extraction_plugin

type t =
  | Int63
  | Float64
  | Pstring
  | Parray
[@@deriving equal]

let registered () =
  let retro = Environ.retroknowledge (Global.env ()) in
  [ Int63, retro.retro_int63
  ; Float64, retro.retro_float64
  ; Pstring, retro.retro_string
  ; Parray, retro.retro_array
  ]
;;

let owned (r : Miniml.global) =
  match r.glob with
  | Names.GlobRef.ConstRef kn when not (Table.is_custom r) ->
    List.find_map (registered ()) ~f:(fun (p, registered) ->
      match registered with
      | Some kn' when Names.Constant.CanOrd.equal kn kn' -> Some p
      | Some _ | None -> None)
  | Names.GlobRef.(ConstRef _ | VarRef _ | IndRef _ | ConstructRef _) -> None
;;

let builtin r =
  match owned r with
  | Some Int63 -> Some "bigint"
  | Some Float64 -> Some "number"
  | Some Pstring -> Some "string"
  | Some Parray | None -> None
;;

let global p =
  Option.map
    (List.Assoc.find_exn (registered ()) ~equal p)
    ~f:(fun kn ->
      { Miniml.glob = Names.GlobRef.ConstRef kn; inst = Miniml.InfvInst.empty })
;;

let remove_owned_axioms table =
  List.iter (registered ()) ~f:(fun (p, _) ->
    match global p with
    | Some r when Option.is_some (owned r) -> Table.remove_info_axiom table r.glob
    | Some _ | None -> ())
;;

let parameter = Names.Id.of_string "a"
