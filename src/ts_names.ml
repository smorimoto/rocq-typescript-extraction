open Import
open Names
open Extraction_plugin
open Miniml
module Refmap = Table.Refmap'
module Refset = Table.Refset'

let ecmascript_reserved_words =
  [ "break"
  ; "case"
  ; "catch"
  ; "class"
  ; "const"
  ; "continue"
  ; "debugger"
  ; "default"
  ; "delete"
  ; "do"
  ; "else"
  ; "export"
  ; "extends"
  ; "false"
  ; "finally"
  ; "for"
  ; "function"
  ; "if"
  ; "import"
  ; "in"
  ; "instanceof"
  ; "new"
  ; "null"
  ; "return"
  ; "super"
  ; "switch"
  ; "this"
  ; "throw"
  ; "true"
  ; "try"
  ; "typeof"
  ; "var"
  ; "void"
  ; "while"
  ; "with"
  ]
;;

let strict_reserved_words = [ "let"; "static"; "yield"; "await" ]

let future_reserved_words =
  [ "enum"
  ; "implements"
  ; "interface"
  ; "package"
  ; "private"
  ; "protected"
  ; "public"
  ; "abstract"
  ; "boolean"
  ; "byte"
  ; "char"
  ; "double"
  ; "final"
  ; "float"
  ; "goto"
  ; "int"
  ; "long"
  ; "native"
  ; "short"
  ; "synchronized"
  ; "throws"
  ; "transient"
  ; "volatile"
  ]
;;

let special_identifiers =
  [ "arguments"; "as"; "async"; "eval"; "from"; "get"; "of"; "set"; "accessor" ]
;;

let global_objects =
  [ "globalThis"
  ; "Infinity"
  ; "NaN"
  ; "undefined"
  ; "eval"
  ; "isFinite"
  ; "isNaN"
  ; "parseFloat"
  ; "parseInt"
  ; "decodeURI"
  ; "decodeURIComponent"
  ; "encodeURI"
  ; "encodeURIComponent"
  ; "escape"
  ; "unescape"
  ; "Object"
  ; "Function"
  ; "Boolean"
  ; "Symbol"
  ; "Error"
  ; "AggregateError"
  ; "EvalError"
  ; "RangeError"
  ; "ReferenceError"
  ; "SuppressedError"
  ; "SyntaxError"
  ; "TypeError"
  ; "URIError"
  ; "InternalError"
  ; "Number"
  ; "BigInt"
  ; "Math"
  ; "Date"
  ; "Temporal"
  ; "String"
  ; "RegExp"
  ; "Array"
  ; "TypedArray"
  ; "Int8Array"
  ; "Uint8Array"
  ; "Uint8ClampedArray"
  ; "Int16Array"
  ; "Uint16Array"
  ; "Int32Array"
  ; "Uint32Array"
  ; "BigInt64Array"
  ; "BigUint64Array"
  ; "Float16Array"
  ; "Float32Array"
  ; "Float64Array"
  ; "Map"
  ; "Set"
  ; "WeakMap"
  ; "WeakSet"
  ; "ArrayBuffer"
  ; "SharedArrayBuffer"
  ; "DataView"
  ; "Atomics"
  ; "JSON"
  ; "WeakRef"
  ; "FinalizationRegistry"
  ; "Iterator"
  ; "AsyncIterator"
  ; "Promise"
  ; "GeneratorFunction"
  ; "Generator"
  ; "AsyncGeneratorFunction"
  ; "AsyncGenerator"
  ; "AsyncFunction"
  ; "DisposableStack"
  ; "AsyncDisposableStack"
  ; "AbstractModuleSource"
  ; "Reflect"
  ; "Proxy"
  ; "Intl"
  ]
;;

let typescript_keywords =
  [ "any"
  ; "unknown"
  ; "never"
  ; "number"
  ; "string"
  ; "symbol"
  ; "object"
  ; "bigint"
  ; "type"
  ; "namespace"
  ; "module"
  ; "declare"
  ; "readonly"
  ; "keyof"
  ; "infer"
  ; "is"
  ; "asserts"
  ; "satisfies"
  ; "override"
  ; "require"
  ; "global"
  ; "constructor"
  ; "unique"
  ]
;;

let typescript_types =
  [ "Awaited"
  ; "Partial"
  ; "Required"
  ; "Readonly"
  ; "Record"
  ; "Pick"
  ; "Omit"
  ; "Exclude"
  ; "Extract"
  ; "NonNullable"
  ; "Parameters"
  ; "ConstructorParameters"
  ; "ReturnType"
  ; "InstanceType"
  ; "NoInfer"
  ; "ThisParameterType"
  ; "OmitThisParameter"
  ; "ThisType"
  ; "Uppercase"
  ; "Lowercase"
  ; "Capitalize"
  ; "Uncapitalize"
  ; "ReadonlyArray"
  ; "ArrayLike"
  ; "Iterable"
  ; "IterableIterator"
  ; "PromiseLike"
  ; "ReadonlyMap"
  ; "ReadonlySet"
  ]
;;

let helper_names =
  [ "__coerces"
  ; "__fail"
  ; "__lazy"
  ; "__magic"
  ; "__readCell"
  ; "__unaryOrder"
  ; "__unaryConstructor"
  ; "__unreachable"
  ; "__writeCell"
  ]
;;

(* Oxlint's node/callback-return reads a call to one of these names as a
   callback that must be returned, wherever the call is. *)
let callback_names = [ "callback"; "cb"; "next" ]

(* unicorn's no-thenable forbids then as the key of an object and as an
   exported name, so no value is named then. *)
let thenable_names = [ "then" ]

let helper_locals =
  Set.of_list
    (module String)
    [ "cell"
    ; "cells"
    ; "force"
    ; "index"
    ; "message"
    ; "value"
    ; "__UnaryPrefix"
    ; "__unaryAdvanceLeft"
    ; "__unaryAnswer"
    ; "__unaryBuild"
    ; "__unaryChild"
    ; "__unaryCurrent"
    ; "__unaryDecide"
    ; "__unaryDepth"
    ; "__unaryExisting"
    ; "__unaryFallback"
    ; "__unaryField"
    ; "__unaryFirst"
    ; "__unaryKind"
    ; "__unaryKnown"
    ; "__unaryLeft"
    ; "__unaryLeftDepth"
    ; "__unaryLeftPrefix"
    ; "__unaryLeftRest"
    ; "__unaryNext"
    ; "__unaryNextDepth"
    ; "__unaryNextRest"
    ; "__unaryNo"
    ; "__unaryPrefixes"
    ; "__unaryPrevious"
    ; "__unaryPreviousFirst"
    ; "__unaryRest"
    ; "__unaryRight"
    ; "__unaryRightDepth"
    ; "__unaryRightPrefix"
    ; "__unaryRightRest"
    ; "__unaryRoot"
    ; "__unarySave"
    ; "__unarySlow"
    ; "__unaryStep"
    ; "__unarySuccessor"
    ; "__unarySuccessors"
    ; "__unarySuffix"
    ; "__unaryTag"
    ; "__unaryValue"
    ; "__unaryYes"
    ; "__unaryZero"
    ]
;;

(* The member names whose call through an object a rule of the presets
   reads as a call of a method of a built-in, by rule, as oxlint reports
   them under the presets. no-array-method-this-argument reads a call with
   two arguments, no-array-reduce one with one or two,
   require-number-to-fixed-digits-argument one with
   none, and the others any call. *)
let methods_by_rule =
  [ ( "unicorn/no-array-method-this-argument"
    , [ "every"
      ; "filter"
      ; "find"
      ; "findIndex"
      ; "findLast"
      ; "findLastIndex"
      ; "flatMap"
      ; "forEach"
      ; "map"
      ; "some"
      ] )
  ; "unicorn/no-array-for-each", [ "forEach" ]
  ; "unicorn/no-array-reduce", [ "reduce"; "reduceRight" ]
  ; "unicorn/prefer-spread", [ "concat" ]
  ; "unicorn/prefer-string-slice", [ "substr"; "substring" ]
  ; "unicorn/require-number-to-fixed-digits-argument", [ "toFixed" ]
  ; ( "eslint/no-prototype-builtins"
    , [ "hasOwnProperty"; "isPrototypeOf"; "propertyIsEnumerable" ] )
  ]
;;

let builtin_methods = Set.of_list (module String) (List.concat_map methods_by_rule ~f:snd)
let is_method s = Set.mem builtin_methods s

let reserved_words =
  List.concat
    [ ecmascript_reserved_words
    ; strict_reserved_words
    ; future_reserved_words
    ; special_identifiers
    ; global_objects
    ; typescript_keywords
    ; typescript_types
    ; helper_names
    ; callback_names
    ; thenable_names
    ]
;;

let keywords = Id.Set.of_list (List.map reserved_words ~f:Id.of_string)
let reserved = Set.of_list (module String) reserved_words
let is_reserved s = Set.mem reserved s
let in_table table c = List.exists table ~f:(fun (lo, hi) -> lo <= c && c <= hi)

(* An ECMAScript identifier starts with [_] or an ID_Start character, a
   letter or Nl, and continues with ID_Continue, which adds Mn, Mc, Nd, and
   Pc. No Rocq identifier has Mc or Pc other than [_]. U+2E2F VERTICAL TILDE
   is a letter that ECMAScript excludes as pattern syntax. *)
let id_start c =
  let letter = Unicode.is_letter (Unicode.classify c) || in_table Unicodetable.nl c in
  c = Char.to_int '_' || (letter && c <> 0x2E2F)
;;

let id_continue c = id_start c || in_table Unicodetable.nd c || in_table Unicodetable.mn c

let ident s =
  let utf8 = String.Utf8.of_string s in
  let b = Buffer.create (String.length s) in
  ignore
    (String.Utf8.fold utf8 ~init:0 ~f:(fun pos u ->
       let len = Uchar.Utf8.byte_length u in
       (match Uchar.to_scalar u with
        | 0x27 -> Buffer.add_string b "ʹ"
        | c when 0x2080 <= c && c <= 0x2089 ->
          Buffer.add_char b (Char.of_int_exn (Char.to_int '0' + c - 0x2080))
        | c when id_continue c -> Buffer.add_substring b s ~pos ~len
        | c -> Printf.bprintf b "_%04x" c);
       pos + len)
     : int);
  match Buffer.contents b with
  | "" -> ""
  | s ->
    let first =
      Uchar.to_scalar (String.Utf8.get (String.Utf8.of_string_unchecked s) ~byte_pos:0)
    in
    if id_start first then s else "_" ^ s
;;

(* Anti-slop's no-shape-in-symbol-names rejects an identifier that
   contains "shape" in any case, which a suffix keeps, so each occurrence
   becomes "form", with the case of its first letter. *)
let permitted s =
  let lowered = String.lowercase s in
  let b = Buffer.create (String.length s) in
  let rec go i =
    if i + 5 <= String.length s && String.equal (String.sub lowered ~pos:i ~len:5) "shape"
    then (
      Buffer.add_string b (if Char.equal s.[i] 'S' then "Form" else "form");
      go (i + 5))
    else if i < String.length s
    then (
      Buffer.add_char b s.[i];
      go (i + 1))
  in
  go 0;
  Buffer.contents b
;;

let words s = List.filter (String.split s ~on:'_') ~f:(fun w -> not (String.is_empty w))

let lower s =
  match words s with
  | [] -> ""
  | w :: ws ->
    ident (String.concat (String.uncapitalize w :: List.map ws ~f:String.capitalize))
;;

let upper s = ident (String.concat (List.map (words s) ~f:String.capitalize))
let camel id = permitted (lower (Id.to_string id))
let pascal id = permitted (upper (Id.to_string id))

let checked what code =
  if Ts_print.balanced code
  then code
  else
    CErrors.user_err
      Pp.(
        str "The TypeScript code "
        ++ qstring code
        ++ str " of "
        ++ what ()
        ++ str " does not balance its brackets and quotes.")
;;

let custom r = checked (fun () -> Printer.pr_global r.glob) (Table.find_custom r)

(* Table keys custom match strings by the inductive of the first branch's
   constructor, so a one-branch probe built from the first constructor finds
   the string without a real match. *)
let custom_match (p : ml_ind_packet) =
  if Array.length p.ip_consnames_ref = 0
  then None
  else (
    let probe = [| [], Pusual p.ip_consnames_ref.(0), MLdummy Kprop |] in
    if Table.is_custom_match probe
    then
      Some
        (checked
           (fun () ->
              Pp.(
                str "the match function of " ++ Printer.pr_global p.ip_typename_ref.glob))
           (Table.find_custom_match probe))
    else None)
;;

let realisers (p : ml_ind_packet) =
  let declared code = not (Ts_print.is_atom code) in
  let ctors =
    List.filteri
      (Array.to_list (Array.map p.ip_consnames_ref ~f:(fun c -> c, custom c)))
      ~f:(fun j (_, code) -> (not (List.is_empty p.ip_types.(j))) && declared code)
  in
  match custom_match p with
  | Some code when declared code -> ctors @ [ p.ip_typename_ref, code ]
  | Some _ | None -> ctors
;;

let group_members rv av =
  List.filter_map
    (Array.to_list (Array.zip_exn rv av))
    ~f:(fun (r, body) ->
      match body with
      | MLexn "UNUSED" -> None
      | _ when Table.is_custom r -> None
      | _ -> Some r)
;;

let numbered used base =
  let base = if String.is_empty base then "x" else base in
  if not (Set.mem used base)
  then base
  else (
    let rec go i =
      let n = base ^ Int.to_string i in
      if Set.mem used n then go (i + 1) else n
    in
    go 0)
;;

let next used base = numbered used (permitted base)
let type_lambda = "TypeLambda"
let kind_name n = if n = 1 then "Kind" else "Kind" ^ Int.to_string n
let kind_slot i = if i = 0 then "Target" else "Target" ^ Int.to_string i
let method_key used s = next (Set.add used s) s

type binding =
  { source : DirPath.t * string list
  ; member : string
  ; local : string
  }

type aliased =
  { declared : global
  ; under : global
  ; name : string
  ; params : Id.t list
  }

type file =
  | Whole
  | File of
      { dp : DirPath.t
      ; referenced : DirPath.t list ref
      ; bound : binding list
      }

type scope =
  | Top
  | Body of
      { paths : ModPath.t list
      ; params : string ModPath.Map.t
      ; locals : string Refmap.t
      ; holders : string Refmap.t
      ; taken : Set.M(String).t
      }

type t =
  { table : Table.t
  ; modular : bool
  ; sigs : Ts_sig.t
  ; roots : ModPath.Set.t
  ; values : string Refmap.t
  ; types : string Refmap.t
  ; interfaces : string Refmap.t
  ; tags : string Refmap.t
  ; modules : string ModPath.Map.t
  ; signatures : string ModPath.Map.t
  ; results : string ModPath.Map.t
  ; flat : ModPath.Set.t
  ; file_values : Set.M(String).t ModPath.Map.t
  ; groups : string Refmap.t
  ; keys : string Refmap.t
  ; hoisted : Refset.t
  ; type_names : Set.M(String).t
  ; root_values : Set.M(String).t
  ; aliased : aliased list ModPath.Map.t
  ; file : file
  ; scope : scope
  ; lifts : Set.M(String).t ref
  ; abstracts : Refset.t
  ; lambdas : Set.M(String).t ref
  ; methods : string Refmap.t
  ; own_bound : (Ts_print.path * (string * string) list) list
  }

type entry =
  | Elements of ModPath.t * ml_module_structure
  | Members of ModPath.t * ml_module_sig
  | Instance of ModPath.t * ml_module_sig

let rec functor_body = function
  | MEfunctor (_, _, me) -> functor_body me
  | MEstruct (mp, sel) -> Some (mp, sel)
  | MEident _ | MEapply _ -> None
;;

let rec functor_parameters = function
  | MEfunctor (id, mt, me) -> (id, mt) :: functor_parameters me
  | MEstruct _ | MEident _ | MEapply _ -> []
;;

let rec fold_decls sel ~init ~f =
  List.fold sel ~init ~f:(fun acc (_, se) ->
    match se with
    | SEdecl d -> f acc d
    | SEmodule { ml_mod_expr = MEstruct (_, sel); _ } -> fold_decls sel ~init:acc ~f
    | SEmodule { ml_mod_expr = MEfunctor _ as me; _ } ->
      (match functor_body me with
       | Some (_, sel) -> fold_decls sel ~init:acc ~f
       | None -> acc)
    | SEmodule { ml_mod_expr = MEident _ | MEapply _; _ } | SEmodtype _ -> acc)
;;

let inlined_parameters struc =
  let term acc r =
    if Table.is_inline_custom r
    then List.fold (Ts_print.code_parameters (Table.find_custom r)) ~init:acc ~f:Set.add
    else acc
  in
  List.fold
    struc
    ~init:(Set.empty (module String))
    ~f:(fun acc (_, sel) ->
      fold_decls sel ~init:acc ~f:(fun acc d ->
        match d with
        | Dterm (r, _, _) -> term acc r
        | Dfix (rv, _, _) -> Array.fold rv ~init:acc ~f:term
        | Dind _ | Dtype _ -> acc))
;;

type member =
  | Value_member
  | Module_member
[@@deriving compare, hash, sexp_of]

module Member_key = struct
  type t = member * string [@@deriving compare, hash, sexp_of]
end

type chosen =
  { base : global -> string
  ; module_types : Ts_sig.t
  ; struc : ml_structure
  ; top_level : Set.M(String).t
  ; keys : (Member_key.t, string) Hashtbl.t
  ; mutable keys_taken : Set.M(String).t
  ; mutable value_of : string Refmap.t
  ; mutable type_of : string Refmap.t
  ; mutable interface_of : string Refmap.t
  ; mutable tag_of : string Refmap.t
  ; mutable module_of : string ModPath.Map.t
  ; mutable signature_of : string ModPath.Map.t
  ; mutable result_of : string ModPath.Map.t
  ; mutable flattened : ModPath.Set.t
  ; mutable group_of : string Refmap.t
  ; mutable key_of : string Refmap.t
  ; mutable lifted : Refset.t
  ; mutable taken_types : Set.M(String).t
  ; mutable alias_of : aliased list ModPath.Map.t
  ; helper_types : Set.M(String).t
  }

type level =
  { prefix : string
  ; members : bool
  ; body : bool
  ; file_types : Set.M(String).t ref
  ; mutable taken_values : Set.M(String).t
  ; mutable taken_shorts : Set.M(String).t
  ; mutable taken_tags : Set.M(String).t
  }

let file_level c =
  { prefix = ""
  ; members = false
  ; body = false
  ; file_types = ref (Set.union reserved c.helper_types)
  ; taken_values = c.top_level
  ; taken_shorts = reserved
  ; taken_tags = Set.empty (module String)
  }
;;

let sublevel ?(body = false) lv n =
  { prefix = lv.prefix ^ n
  ; members = true
  ; body
  ; file_types = lv.file_types
  ; taken_values = reserved
  ; taken_shorts = reserved
  ; taken_tags = Set.empty (module String)
  }
;;

let key c kind label spelt =
  match Hashtbl.find c.keys (kind, label) with
  | Some k -> k
  | None ->
    let k = next c.keys_taken (spelt label) in
    Hashtbl.add_exn c.keys ~key:(kind, label) ~data:k;
    c.keys_taken <- Set.add c.keys_taken k;
    k
;;

let value c lv r label =
  let n =
    if lv.members
    then key c Value_member label lower
    else next lv.taken_values (lower label)
  in
  lv.taken_values <- Set.add lv.taken_values n;
  c.value_of <- Refmap.add r n c.value_of
;;

let short lv s =
  let n = next lv.taken_shorts s in
  lv.taken_shorts <- Set.add lv.taken_shorts n;
  n
;;

let tag lv s =
  let n = numbered lv.taken_tags s in
  lv.taken_tags <- Set.add lv.taken_tags n;
  n
;;

let type_name c lv s =
  let n = next !(lv.file_types) (lv.prefix ^ s) in
  lv.file_types := Set.add !(lv.file_types) n;
  c.taken_types <- Set.add c.taken_types n;
  n
;;

let term c lv r =
  if (not (Table.is_inline_custom r)) && not (Refmap.mem r c.value_of)
  then value c lv r (c.base r)
;;

let realiser c lv (r, _) =
  if lv.body then c.lifted <- Refset.add r c.lifted;
  match r.glob with
  | GlobRef.IndRef _ -> value c lv r ("match_" ^ c.base r)
  | GlobRef.ConstructRef _ | GlobRef.ConstRef _ | GlobRef.VarRef _ ->
    value c lv r (c.base r)
;;

let is_declared r =
  not (Table.is_inline_custom r || Option.is_some (Ts_primitives.builtin r))
;;

let declare_type c lv r s =
  c.type_of <- Refmap.add r (type_name c lv (short lv s)) c.type_of
;;

let name_inductive c lv ind =
  Array.iter ind.ind_packets ~f:(fun (p : ml_ind_packet) ->
    if p.ip_logical
    then ()
    else if Table.is_custom p.ip_typename_ref
    then List.iter (realisers p) ~f:(realiser c lv)
    else (
      declare_type c lv p.ip_typename_ref (upper (c.base p.ip_typename_ref));
      match ind.ind_kind with
      | Standard | Coinductive ->
        Array.iter p.ip_consnames_ref ~f:(fun r ->
          let tag = tag lv (upper (c.base r)) in
          c.tag_of <- Refmap.add r tag c.tag_of;
          c.interface_of <- Refmap.add r (type_name c lv tag) c.interface_of;
          value c lv r (c.base r))
      | Record _ | Singleton -> ()))
;;

let name_group c lv rv av =
  match group_members rv av with
  | first :: _ :: _ as members ->
    let n =
      next lv.taken_values (lower (String.concat ~sep:"_" (List.map members ~f:c.base)))
    in
    lv.taken_values <- Set.add lv.taken_values n;
    c.group_of <- Refmap.add first n c.group_of;
    List.iter members ~f:(fun r ->
      let m = Refmap.find r c.value_of in
      if Set.mem builtin_methods m
      then (
        let k = method_key lv.taken_values m in
        lv.taken_values <- Set.add lv.taken_values k;
        c.key_of <- Refmap.add r k c.key_of))
  | [] | [ _ ] -> ()
;;

let name_decl c lv = function
  | Dind ind -> name_inductive c lv ind
  | Dtype (r, _, _) ->
    (match Ts_primitives.owned r with
     | Some Ts_primitives.Parray -> declare_type c lv r "PArray"
     | Some Ts_primitives.(Int63 | Float64 | Pstring) | None ->
       if is_declared r then declare_type c lv r (upper (c.base r)))
  | Dterm (r, _, _) -> term c lv r
  | Dfix (rv, _, _) -> Array.iter rv ~f:(term c lv)
;;

(* A module is a member of the object of the module around it, so it is
   named by its key, but a top-level module object and a type of the
   same name would redeclare the name for a linter that does not know
   TypeScript. *)
let module_ c lv l p =
  let n =
    if lv.members
    then key c Module_member (Id.to_string l) upper
    else next (Set.union lv.taken_values !(lv.file_types)) (upper (Id.to_string l))
  in
  lv.taken_values <- Set.add lv.taken_values n;
  if not lv.members then lv.file_types := Set.add !(lv.file_types) n;
  c.module_of <- ModPath.Map.add p n c.module_of;
  n
;;

let rec alias_types c lv alias ~prefix ~target mt =
  let aliased ~declared ~under params =
    [ { declared
      ; under
      ; name = type_name c lv (prefix ^ upper (c.base declared))
      ; params
      }
    ]
  in
  let nested l ~target =
    alias_types c lv (MPdot (alias, l)) ~prefix:(prefix ^ upper (Id.to_string l)) ~target
  in
  let packets ind one =
    List.concat_map (Array.to_list ind.ind_packets) ~f:(fun (p : ml_ind_packet) ->
      if p.ip_logical then [] else one p.ip_typename_ref p.ip_vars)
  in
  match Ts_alias.find c.struc target with
  | Some sel ->
    let one r params = aliased ~declared:r ~under:(Ts_alias.rebase alias r) params in
    List.concat_map sel ~f:(fun (l, se) ->
      match se with
      | SEdecl (Dind ind) ->
        packets ind (fun r vl -> if Table.is_custom r then [] else one r vl)
      | SEdecl (Dtype (r, vl, _)) -> if is_declared r then one r vl else []
      | SEmodule { ml_mod_expr = MEstruct (mp, _); ml_mod_type } ->
        nested l ~target:mp ml_mod_type
      | SEmodule { ml_mod_expr = MEident target; ml_mod_type } ->
        nested l ~target ml_mod_type
      | SEdecl (Dterm _ | Dfix _) | SEmodule _ | SEmodtype _ -> [])
  | None ->
    let one r params =
      aliased ~declared:(Ts_sig.rebase ~from:alias ~to_:target r) ~under:r params
    in
    List.concat_map (Ts_sig.resolve c.module_types ~at:alias mt) ~f:(fun (l, s) ->
      match s with
      | Spec (Sind ind) ->
        packets ind (fun r vl ->
          if Table.is_custom (Ts_sig.rebase ~from:alias ~to_:target r)
          then []
          else one r vl)
      | Spec (Stype (r, vl, _)) ->
        if is_declared (Ts_sig.rebase ~from:alias ~to_:target r) then one r vl else []
      | Smodule mt -> nested l ~target:(MPdot (target, l)) mt
      | Spec (Sval _) | Smodtype _ -> [])
;;

let rec level c lv entries =
  List.iter entries ~f:(function
    | Elements (parent, sel) ->
      List.iter sel ~f:(fun (_, se) ->
        match se with
        | SEdecl (Dterm (r, _, _)) -> term c lv r
        | SEdecl (Dfix (rv, _, _)) -> Array.iter rv ~f:(term c lv)
        | SEdecl (Dind _ | Dtype _) | SEmodule _ | SEmodtype _ -> ());
      List.iter sel ~f:(name_element c lv parent)
    | Members (at, members) -> List.iter members ~f:(name_member c lv at)
    | Instance (at, members) -> List.iter members ~f:(name_instance c lv at));
  List.iter entries ~f:(function
    | Elements (_, sel) ->
      List.iter sel ~f:(function
        | _, SEdecl (Dfix (rv, av, _)) -> name_group c lv rv av
        | _, (SEdecl (Dind _ | Dtype _ | Dterm _) | SEmodule _ | SEmodtype _) -> ())
    | Members _ | Instance _ -> ())

and name_modtype c lv l p mt =
  let n = type_name c lv (upper (Id.to_string l)) in
  c.signature_of <- ModPath.Map.add p n c.signature_of;
  c.module_of <- ModPath.Map.add p n c.module_of;
  match mt with
  | MTsig (mp, members) -> level c (sublevel lv n) [ Members (mp, members) ]
  | MTfunsig _ -> signature_result c lv n p mt
  | MTident _ | MTwith _ -> ()

and signature_result c lv n p = function
  | MTfunsig (id, param, result) ->
    inline_parameter c lv n (id, param);
    signature_result c lv n p result
  | MTsig (mp, members) ->
    c.result_of <- ModPath.Map.add p (type_name c lv (n ^ "Result")) c.result_of;
    level c (sublevel lv n) [ Members (mp, members) ]
  | MTident _ | MTwith _ -> ()

and name_member c lv at (l, s) =
  match s with
  | Spec (Sval (r, _)) -> term c lv r
  | Spec (Stype (r, vl, Some t)) -> name_decl c lv (Dtype (r, vl, t))
  | Spec (Stype (_, _, None)) -> ()
  | Spec (Sind ind) -> name_decl c lv (Dind ind)
  | Smodule mt ->
    let p = MPdot (at, l) in
    let n = module_ c lv l p in
    (match mt with
     | MTsig (mp, members) ->
       c.signature_of <- ModPath.Map.add mp (type_name c lv n) c.signature_of;
       level c (sublevel lv n) [ Members (mp, members) ]
     | MTfunsig _ ->
       c.signature_of <- ModPath.Map.add p (type_name c lv n) c.signature_of;
       signature_result c lv n p mt
     | MTident _ | MTwith _ -> ())
  | Smodtype mt -> name_modtype c lv l (MPdot (at, l)) mt

and name_instance c lv at (l, s) =
  match s with
  | Spec (Stype (r, _, None)) -> declare_type c lv r (upper (c.base r))
  | Spec (Sind ind)
    when Array.exists ind.ind_packets ~f:(fun (p : ml_ind_packet) ->
           Table.is_custom p.ip_typename_ref) -> ()
  | Spec (Sval _ | Stype (_, _, Some _) | Sind _) | Smodtype _ ->
    name_member c lv at (l, s)
  | Smodule mt ->
    let p = MPdot (at, l) in
    let n = module_ c lv l p in
    level c (sublevel lv n) [ Instance (p, Ts_sig.resolve c.module_types ~at:p mt) ]

and name_element c lv parent (l, se) =
  match se with
  | SEdecl d -> name_decl c lv d
  | SEmodule { ml_mod_expr = MEstruct (mp, sel); _ } ->
    let n = module_ c lv l mp in
    if lv.body then c.signature_of <- ModPath.Map.add mp (type_name c lv n) c.signature_of;
    level c (sublevel ~body:lv.body lv n) [ Elements (mp, sel) ]
  | SEmodule { ml_mod_expr = MEident target; ml_mod_type } ->
    let alias = MPdot (parent, l) in
    let n = module_ c lv l alias in
    if not lv.body
    then
      c.alias_of
      <- ModPath.Map.add
           alias
           (alias_types c lv alias ~prefix:n ~target ml_mod_type)
           c.alias_of
  | SEmodule { ml_mod_expr = MEfunctor _ as me; ml_mod_type } ->
    let p = MPdot (parent, l) in
    let n = module_ c lv l p in
    c.flattened <- ModPath.Set.add p c.flattened;
    c.signature_of <- ModPath.Map.add p (type_name c lv (n ^ "Result")) c.signature_of;
    List.iter (functor_parameters me) ~f:(inline_parameter c lv n);
    (match
       ( functor_body me
       , Ts_sig.functor_ c.module_types p
       , Ts_sig.functor_signature c.module_types ml_mod_type )
     with
     | Some (mp, sel), _, _ -> level c (sublevel ~body:true lv n) [ Elements (mp, sel) ]
     | ( None
       , Some { body = Applied (MEident _); _ }
       , Some { result = MTsig (mp, members); _ } ) ->
       level c (sublevel lv n) [ Members (mp, members) ]
     | None, _, _ -> ())
  | SEmodule { ml_mod_expr = MEapply _; ml_mod_type } ->
    let p = MPdot (parent, l) in
    let n = module_ c lv l p in
    c.flattened <- ModPath.Set.add p c.flattened;
    level
      c
      (sublevel lv n)
      [ Instance (p, Ts_sig.resolve c.module_types ~at:p ml_mod_type) ]
  | SEmodtype mt -> name_modtype c lv l (MPdot (parent, l)) mt

and inline_parameter c lv n (id, mt) =
  match mt with
  | MTsig (mp, members) when ModPath.equal mp (MPbound id) ->
    let short = n ^ upper (Id.to_string (MBId.to_id id)) in
    c.signature_of <- ModPath.Map.add mp (type_name c lv short) c.signature_of;
    level c (sublevel lv short) [ Members (mp, members) ]
  | MTsig _ | MTident _ | MTwith _ | MTfunsig _ -> ()
;;

let member_labels base struc =
  let labels = ref [] in
  let add kind label = labels := (kind, label) :: !labels in
  let value r = add Value_member (base r) in
  let inductive ind =
    Array.iter ind.ind_packets ~f:(fun (p : ml_ind_packet) ->
      if not p.ip_logical then Array.iter p.ip_consnames_ref ~f:value)
  in
  let rec signature = function
    | MTsig (_, specs) -> List.iter specs ~f:spec
    | MTfunsig (_, param, result) ->
      signature param;
      signature result
    | MTwith (mt, _) -> signature mt
    | MTident _ -> ()
  and spec (l, s) =
    match s with
    | Spec (Sval (r, _)) -> value r
    | Spec (Sind ind) -> inductive ind
    | Spec (Stype _) -> ()
    | Smodule mt ->
      add Module_member (Id.to_string l);
      signature mt
    | Smodtype mt -> signature mt
  and expr = function
    | MEstruct (_, sel) -> List.iter sel ~f:element
    | MEfunctor (_, param, body) ->
      signature param;
      expr body
    | MEident _ | MEapply _ -> ()
  and element (l, se) =
    match se with
    | SEdecl (Dterm (r, _, _)) -> value r
    | SEdecl (Dfix (rv, _, _)) -> Array.iter rv ~f:value
    | SEdecl (Dind ind) -> inductive ind
    | SEdecl (Dtype _) -> ()
    | SEmodule m ->
      add Module_member (Id.to_string l);
      module_ m
    | SEmodtype mt -> signature mt
  and module_ { ml_mod_expr; ml_mod_type } =
    signature ml_mod_type;
    expr ml_mod_expr
  in
  List.iter struc ~f:(fun (_, sel) ->
    List.iter sel ~f:(function
      | _, SEdecl _ -> ()
      | _, SEmodule m -> module_ m
      | _, SEmodtype mt -> signature mt));
  List.rev !labels
;;

let create state sigs struc =
  let table = Common.State.get_table state in
  let helper_types =
    match List.fold struc ~init:0 ~f:(fun n (mp, _) -> max n (Ts_sig.kinds sigs mp)) with
    | 0 -> Set.empty (module String)
    | n ->
      Set.of_list
        (module String)
        (type_lambda :: List.init n ~f:(fun i -> kind_name (i + 1)))
  in
  let base r =
    let s = Id.to_string (Table.safe_basename_of_global table r) in
    match InfvInst.encode r.inst with
    | None -> s
    | Some suffix -> s ^ "__" ^ suffix
  in
  let c =
    { base
    ; module_types = sigs
    ; struc
    ; top_level = Set.union reserved (Set.union helper_locals (inlined_parameters struc))
    ; keys = Hashtbl.create (module Member_key) ~size:256
    ; keys_taken = reserved
    ; value_of = Refmap.empty
    ; type_of = Refmap.empty
    ; interface_of = Refmap.empty
    ; tag_of = Refmap.empty
    ; module_of = ModPath.Map.empty
    ; signature_of = ModPath.Map.empty
    ; result_of = ModPath.Map.empty
    ; flattened = ModPath.Set.empty
    ; group_of = Refmap.empty
    ; key_of = Refmap.empty
    ; lifted = Refset.empty
    ; taken_types = Set.union reserved helper_types
    ; alias_of = ModPath.Map.empty
    ; helper_types
    }
  in
  List.iter (member_labels base struc) ~f:(fun (kind, label) ->
    let spelt =
      match kind with
      | Value_member -> lower
      | Module_member -> upper
    in
    if String.equal (permitted (spelt label)) label && not (is_reserved label)
    then ignore (key c kind label spelt : string));
  let file sels =
    let lv = file_level c in
    level c lv sels;
    lv.taken_values
  in
  let modular = Common.State.get_modular state in
  let file_values, root_values =
    if modular
    then (
      let per_file =
        List.map struc ~f:(fun (mp, sel) -> mp, file [ Elements (mp, sel) ])
      in
      ( List.fold per_file ~init:ModPath.Map.empty ~f:(fun m (mp, vs) ->
          ModPath.Map.add mp vs m)
      , List.fold
          per_file
          ~init:(Set.empty (module String))
          ~f:(fun acc (_, vs) -> Set.union acc vs) ))
    else ModPath.Map.empty, file (List.map struc ~f:(fun (mp, sel) -> Elements (mp, sel)))
  in
  { table
  ; modular
  ; sigs
  ; roots = ModPath.Set.of_list (List.map struc ~f:fst)
  ; values = c.value_of
  ; types = c.type_of
  ; interfaces = c.interface_of
  ; tags = c.tag_of
  ; modules = c.module_of
  ; signatures = c.signature_of
  ; results = c.result_of
  ; flat = c.flattened
  ; file_values
  ; groups = c.group_of
  ; keys = c.key_of
  ; hoisted = c.lifted
  ; type_names = c.taken_types
  ; root_values = Set.diff root_values helper_locals
  ; aliased = c.alias_of
  ; file = Whole
  ; scope = Top
  ; lifts = ref (Set.empty (module String))
  ; abstracts = Refset.empty
  ; lambdas = ref (Set.empty (module String))
  ; methods = Refmap.empty
  ; own_bound = []
  }
;;

let find names map r =
  match Refmap.find_opt r map with
  | Some _ as found -> found
  | None -> Refmap.find_opt (Ts_sig.canon names.sigs r) map
;;

let get names what map r =
  match find names map r with
  | Some n -> n
  | None ->
    CErrors.anomaly
      Pp.(
        str "Ts_names." ++ str what ++ str ": unnamed " ++ GlobRef.print r.glob ++ str ".")
;;

let member_name names r = get names "member_name" names.values r

let group_key names r =
  match find names names.keys r with
  | Some k -> k
  | None -> member_name names r
;;

let type_name names r = get names "type_name" names.types r
let type_name_opt names r = find names names.types r
let interface_name names c = get names "interface_name" names.interfaces c
let tag names c = get names "tag" names.tags c

let parameter names mp =
  match names.scope with
  | Body { params; _ } -> ModPath.Map.find_opt mp params
  | Top -> None
;;

let module_name names mp =
  let own =
    Option.first_some (ModPath.Map.find_opt mp names.modules) (parameter names mp)
  in
  let through_parent =
    match own, mp with
    | Some _, _ -> own
    | None, ModPath.MPdot (parent, l) ->
      ModPath.Map.find_opt
        (ModPath.MPdot (Ts_sig.canon_path names.sigs parent, l))
        names.modules
    | None, ModPath.(MPfile _ | MPbound _) -> None
  in
  match through_parent with
  | Some s -> s
  | None -> CErrors.anomaly (Pp.str "Ts_names.module_name: unnamed module.")
;;

let signature_name names mp =
  match ModPath.Map.find_opt mp names.signatures with
  | Some s -> s
  | None -> CErrors.anomaly (Pp.str "Ts_names.signature_name: unnamed module type.")
;;

let result_name names mp =
  match ModPath.Map.find_opt mp names.results with
  | Some s -> s
  | None -> CErrors.anomaly (Pp.str "Ts_names.result_name: not a functor signature.")
;;

let is_root names mp =
  ModPath.Set.mem mp names.roots
  ||
  match names.scope with
  | Body { paths; _ } -> List.exists paths ~f:(ModPath.equal mp)
  | Top -> false
;;

let rec module_path names mp =
  if is_root names mp
  then []
  else (
    match mp with
    | ModPath.MPdot (parent, _) -> module_path names parent @ [ module_name names mp ]
    | ModPath.MPfile _ | ModPath.MPbound _ -> [])
;;

let path names r =
  let names = if Refset.mem r names.hoisted then { names with scope = Top } else names in
  module_path names (Table.modpath_of_r r)
;;

let flat_name names mp =
  match parameter names mp with
  | Some n -> n
  | None -> String.concat ~sep:"$" (module_path names mp)
;;

let top_name names mp =
  match module_path names mp with
  | top :: _ -> top
  | [] -> CErrors.anomaly (Pp.str "Ts_names.top_name: a file has no value.")
;;

let kebab s =
  let n = String.length s in
  let b = Buffer.create (n + 4) in
  String.iteri s ~f:(fun i c ->
    if Char.equal c '_'
    then Buffer.add_char b '-'
    else (
      if i > 0 && Char.is_uppercase c
      then (
        let p = s.[i - 1] in
        if
          Char.is_lowercase p
          || Char.is_digit p
          || (Char.is_uppercase p && i + 1 < n && Char.is_lowercase s.[i + 1])
        then Buffer.add_char b '-');
      Buffer.add_char b (Char.lowercase c)));
  Buffer.contents b
;;

let library names dp = Table.file_of_modfile names.table dp
let file_name names dp = kebab (library names dp)
let alias names dp = "$" ^ permitted (ident (library names dp))

let foreign dp mp =
  match Table.base_mp mp with
  | ModPath.MPfile dp' when not (DirPath.equal dp dp') -> Some dp'
  | ModPath.MPfile _ | ModPath.MPdot _ | ModPath.MPbound _ -> None
;;

let record_import names mp =
  match names.file with
  | Whole -> None
  | File { dp; referenced; _ } ->
    Option.map (foreign dp mp) ~f:(fun dp' ->
      if not (List.exists !referenced ~f:(DirPath.equal dp'))
      then referenced := dp' :: !referenced;
      dp', alias names dp')
;;

let local names r =
  match names.scope with
  | Body { locals; _ } -> Refmap.find_opt r locals
  | Top -> None
;;

let value_name names r =
  match local names r with
  | Some l -> l
  | None -> String.concat ~sep:"$" (path names r @ [ member_name names r ])
;;

let group_name names r =
  let holder =
    match names.scope with
    | Body { holders; _ } -> Refmap.find_opt r holders
    | Top -> None
  in
  match holder with
  | Some l -> Some l
  | None ->
    Option.map (Refmap.find_opt r names.groups) ~f:(fun n ->
      String.concat ~sep:"$" (path names r @ [ n ]))
;;

let same_source (dp, mods) (dp', mods') =
  DirPath.equal dp dp' && List.equal String.equal mods mods'
;;

let binds mods member = List.is_empty mods || Set.mem builtin_methods member
let fields root mods = List.fold mods ~init:root ~f:(fun e n -> Ts_print.Field (e, n))

let reference names r =
  match names.file, record_import names (Table.modpath_of_r r) with
  | Whole, _ | File _, None -> Ts_print.Var (value_name names r)
  | File { bound; _ }, Some (dp, alias) ->
    let mods = path names r
    and member = member_name names r in
    if binds mods member
    then (
      match
        List.find bound ~f:(fun b ->
          same_source b.source (dp, mods) && String.equal b.member member)
      with
      | Some b -> Ts_print.Var b.local
      | None ->
        CErrors.anomaly
          Pp.(
            str "Ts_names.reference: "
            ++ Printer.pr_global r.glob
            ++ str " was not bound when its file was entered."))
    else fields (Ts_print.Var alias) (mods @ [ member ])
;;

let rec object_of names mp =
  match parameter names mp with
  | Some x -> Some (Ts_print.Var x)
  | None -> object_path names mp

and object_path names mp =
  if ModPath.Set.mem mp names.flat && Option.is_none (record_import names mp)
  then Some (Ts_print.Var (flat_name names mp))
  else (
    match mp with
    | ModPath.MPdot (parent, _) ->
      Option.map (object_of names parent) ~f:(fun o ->
        Ts_print.Field (o, module_name names mp))
    | ModPath.MPbound _ | ModPath.MPfile _ -> None)
;;

let realised names r =
  if Refmap.mem r names.values
  then Some r
  else (
    let c = Ts_sig.canon names.sigs r in
    Option.some_if (Refmap.mem c names.values) c)
;;

let value names r =
  match local names r, Refmap.find_opt r names.methods with
  | Some l, _ | None, Some l -> Ts_print.Var l
  | None, None ->
    (match Table.is_inline_custom r, realised names r with
     | true, None -> Ts_print.Code (custom r)
     | true, Some r -> reference names r
     | false, _ when Refset.mem r names.hoisted -> reference names r
     | false, _ ->
       (match object_of names (Table.modpath_of_r r) with
        | Some o -> Ts_print.Field (o, member_name names r)
        | None -> reference names r))
;;

let match_function names r code =
  match realised names r with
  | Some r -> reference names r
  | None -> Ts_print.Code code
;;

let qualified names mp name =
  String.concat
    ~sep:"."
    (Option.to_list (Option.map (record_import names mp) ~f:snd) @ [ name ])
;;

let kind_ref names r name =
  match Ts_sig.home names.sigs r with
  | Some file -> qualified names file name
  | None -> qualified names (Table.modpath_of_r (Ts_sig.canon names.sigs r)) name
;;

let module_ref names mp =
  match object_of names mp with
  | Some o -> o
  | None ->
    (match record_import names mp, module_path names mp with
     | Some (_, alias), mods -> fields (Ts_print.Var alias) mods
     | None, top :: mods -> fields (Ts_print.Var top) mods
     | None, [] -> CErrors.anomaly (Pp.str "Ts_names.module_ref: a file has no object."))
;;

let alias_types names mp =
  match ModPath.Map.find_opt mp names.aliased with
  | Some types -> types
  | None -> CErrors.anomaly (Pp.str "Ts_names.alias_types: not an alias.")
;;

let interface_ref names c =
  qualified names (Table.modpath_of_r c) (interface_name names c)
;;

let type_ref names r = qualified names (Table.modpath_of_r r) (type_name names r)
let signature_ref names mp = qualified names mp (signature_name names mp)
let same_file names mp = Option.is_none (record_import names mp)
let result_ref names mp = qualified names mp (result_name names mp)

type tvars =
  | Params of (int * string) list
  | Erased

let tvar_names names ~taken n =
  let candidate k =
    if k < 26
    then String.make 1 (Char.of_int_exn (65 + k))
    else "T" ^ Int.to_string (k + 1)
  in
  let rec go k acc =
    if List.length acc = n
    then List.rev acc
    else (
      let c = candidate k in
      go
        (k + 1)
        (if Set.mem names.type_names c || List.mem taken c ~equal:String.equal
         then acc
         else c :: acc))
  in
  go 0 []
;;

let numbered names = Params (List.mapi names ~f:(fun i name -> i + 1, name))
let slots n = numbered (List.init n ~f:(fun i -> Printf.sprintf "this[%S]" (kind_slot i)))
let params names n = numbered (tvar_names names ~taken:[] n)

let named names ids =
  let params =
    List.folding_map ids ~init:names.type_names ~f:(fun used id ->
      let n = next used (upper (Id.to_string id)) in
      Set.add used n, n)
  in
  numbered params
;;

let erased = Erased

let tparams = function
  | Params l -> List.map l ~f:snd
  | Erased -> []
;;

let in_scope = function
  | Params l -> l
  | Erased -> []
;;

let extend tvars named =
  if List.is_empty named then tvars else Params (List.rev_append named (in_scope tvars))
;;

let generic names tvars ids =
  let fresh =
    tvar_names names ~taken:(List.map (in_scope tvars) ~f:snd) (List.length ids)
  in
  extend tvars (List.zip_exn ids fresh), fresh
;;

let hide tvars ids = extend tvars (List.map ids ~f:(fun i -> i, "never"))

let tvar tvars i =
  match tvars with
  | Erased -> "any"
  | Params l ->
    (match List.Assoc.find l ~equal:Int.equal i with
     | Some name -> name
     | None -> CErrors.anomaly (Pp.str "Ts_names.ty: type variable out of scope."))
;;

let segments r code args =
  let n = String.length code in
  let digit i = i < n && Char.is_digit code.[i] in
  let rec digits j = if digit j then digits (j + 1) else j in
  let verbatim from upto acc =
    if from < upto
    then Ts_print.Verbatim (String.sub code ~pos:from ~len:(upto - from)) :: acc
    else acc
  in
  let hole i j =
    match Int.of_string_opt (String.sub code ~pos:(i + 1) ~len:(j - i - 1)) with
    | Some k when k >= 1 && k <= List.length args ->
      Ts_print.Hole (List.nth_exn args (k - 1))
    | Some _ | None ->
      CErrors.user_err
        Pp.(
          str "The TypeScript type of "
          ++ Printer.pr_global r.glob
          ++ str " uses "
          ++ str (String.sub code ~pos:i ~len:(j - i))
          ++ str ", but the type has "
          ++ int (List.length args)
          ++ str " type arguments.")
  in
  let rec go from i acc =
    if i >= n
    then List.rev (verbatim from n acc)
    else if Char.equal code.[i] '$' && digit (i + 1)
    then (
      let j = digits (i + 1) in
      go j j (hole i j :: verbatim from i acc))
    else go from (i + 1) acc
  in
  go 0 0 []
;;

let applied segments args =
  let rec holes = function
    | [ Ts_print.Hole t; Ts_print.Verbatim close ]
      when String.equal (String.strip close) ">" -> Some [ t ]
    | Ts_print.Hole t :: Ts_print.Verbatim comma :: rest
      when String.equal (String.strip comma) "," ->
      Option.map (holes rest) ~f:(List.cons t)
    | [] | [ Ts_print.Hole _ ] | Ts_print.Verbatim _ :: _ | Ts_print.Hole _ :: _ -> None
  in
  match segments with
  | [ Ts_print.Verbatim name ] -> Some (String.strip name, args)
  | Ts_print.Verbatim head :: rest ->
    let head = String.strip head in
    if String.is_suffix head ~suffix:"<"
    then
      Option.map (holes rest) ~f:(fun holes ->
        String.strip (String.sub head ~pos:0 ~len:(String.length head - 1)), holes)
    else None
  | [] | Ts_print.Hole _ :: _ -> None
;;

let generated_in r ~what ~name candidates =
  let file r' = Table.base_mp (Table.modpath_of_r r') in
  let home, others =
    List.partition_tf candidates ~f:(fun r' -> ModPath.equal (file r') (file r))
  in
  match home, others with
  | r' :: _, _ -> Some r'
  | [], [] -> None
  | [], r' :: rest ->
    (match List.find rest ~f:(fun r'' -> not (ModPath.equal (file r'') (file r'))) with
     | None -> Some r'
     | Some r'' ->
       CErrors.user_err
         Pp.(
           str "The TypeScript "
           ++ str what
           ++ str " of "
           ++ Printer.pr_global r.glob
           ++ str " mentions "
           ++ str name
           ++ str ", which names both "
           ++ Printer.pr_global r'.glob
           ++ str " and "
           ++ Printer.pr_global r''.glob
           ++ str
                ", generated in different files. Rename one of them, or extract to a \
                 single file."))
;;

let generated_type names r name =
  if is_reserved name || not (Set.mem names.type_names name)
  then None
  else
    generated_in
      r
      ~what:"type"
      ~name
      (List.filter_map
         (Refmap.bindings names.types @ Refmap.bindings names.interfaces)
         ~f:(fun (r', n) -> Option.some_if (String.equal n name) r'))
;;

let generated_value names r name =
  if is_reserved name
  then None
  else
    generated_in
      r
      ~what:"code"
      ~name
      (List.filter_map (Refmap.bindings names.values) ~f:(fun (r', n) ->
         Option.some_if (String.equal n name && List.is_empty (path names r')) r'))
;;

let qualify_code names r ~params code =
  let b = Buffer.create (String.length code) in
  let from =
    List.fold (Ts_print.code_identifier_spans code) ~init:0 ~f:(fun from (i, j) ->
      let id = String.sub code ~pos:i ~len:(j - i) in
      let found =
        if List.mem params id ~equal:String.equal
        then None
        else if Ts_print.typeof_operand code i
        then generated_value names r id
        else generated_type names r id
      in
      match found with
      | Some r' ->
        Buffer.add_substring b code ~pos:from ~len:(i - from);
        Buffer.add_string b (qualified names (Table.modpath_of_r r') id);
        j
      | None -> from)
  in
  Buffer.add_substring b code ~pos:from ~len:(String.length code - from);
  Buffer.contents b
;;

let tuple_of segments =
  let rec holes = function
    | [ Ts_print.Hole t; Ts_print.Verbatim "]" ] -> Some [ t ]
    | Ts_print.Hole t :: Ts_print.Verbatim ", " :: rest ->
      Option.map (holes rest) ~f:(List.cons t)
    | [] | Ts_print.Hole _ :: _ | Ts_print.Verbatim _ :: _ -> None
  in
  match segments with
  | Ts_print.Verbatim "readonly [" :: rest -> holes rest
  | [] | Ts_print.Verbatim _ :: _ | Ts_print.Hole _ :: _ -> None
;;

let custom_type names r args =
  let code = Table.find_custom r in
  let placeholders = segments r code args in
  let generated =
    let open Option.Let_syntax in
    let%bind name, args = applied placeholders args in
    let%map r' = generated_type names r name in
    Ts_print.Name (qualified names (Table.modpath_of_r r') name, args)
  in
  match generated, tuple_of placeholders with
  | Some t, _ -> t
  | None, Some ts -> Ts_print.Tuple ts
  | None, None ->
    let code = qualify_code names r ~params:[] code in
    (match segments r code args with
     | [ Ts_print.Hole t ] -> t
     | [] | [ Ts_print.Verbatim _ ] ->
       (match args, Ts_print.union_members code with
        | [], (_ :: _ :: _ as members) ->
          Ts_print.Union (List.map members ~f:(fun m -> Ts_print.Name (m, [])))
        | _ -> Ts_print.Name (code, args))
     | segments -> Ts_print.Raw segments)
;;

let implicit_params names r = List.map (Ts_sig.implicit names.sigs r) ~f:(type_name names)

let rec ty names tvars = function
  | Ts_type.Arrow (a, b) ->
    let params = if Ts_type.is_erased a then [] else [ "_", ty names tvars a ] in
    Ts_print.Fn { tparams = []; params; result = ty names tvars b }
  | Ts_type.Glob (c, []) when Ts_type.is_ctor c ->
    if Table.is_custom c
    then Ts_print.Name (custom c, [])
    else Ts_print.Name (interface_ref names c, [])
  | Ts_type.Glob (r, args) ->
    let printed () = List.map args ~f:(ty names tvars) in
    if Table.is_inline_custom r
    then custom_type names r (printed ())
    else (
      match
        Ts_primitives.builtin r, find names names.types r, Ts_sig.fixed names.sigs r
      with
      | Some keyword, _, _ -> Ts_print.Name (keyword, [])
      | None, Some name, _ when (not (List.is_empty args)) && Refset.mem r names.abstracts
        ->
        Ts_print.Name
          ( kind_ref names r (kind_name (List.length args))
          , Ts_print.Name (name, []) :: printed () )
      | None, Some name, _ ->
        Ts_print.Name
          (qualified names (Table.modpath_of_r r) name, printed () @ implicit_args names r)
      | None, None, Some (_, def) ->
        ty names tvars (Ts_type.subst args (Ts_type.of_ml def))
      | None, None, None ->
        Ts_print.Name (type_ref names r, printed () @ implicit_args names r))
  | Ts_type.Var i -> Ts_print.Name (tvar tvars i, [])
  | Ts_type.Forall (vs, t) ->
    let inner, fresh = generic names tvars vs in
    (match ty names inner t with
     | Ts_print.Fn f -> Ts_print.Fn { f with tparams = Ts_print.unbounded fresh }
     | _ -> CErrors.anomaly (Pp.str "Ts_names.ty: a generic type is a function."))
  | Ts_type.Meta _ as t -> ty names tvars (Ts_type.zonk t)
  | Ts_type.Erased -> Ts_print.Name ("undefined", [])
  | Ts_type.Never -> Ts_print.Name ("never", [])
  | Ts_type.Tuple ts -> Ts_print.Tuple (List.map ts ~f:(ty names tvars))
  | Ts_type.Union ts ->
    let by_text a b = String.compare (Ts_print.type_text a) (Ts_print.type_text b) in
    (match List.dedup_and_sort (List.map ts ~f:(ty names tvars)) ~compare:by_text with
     | [ t ] -> t
     | ts -> Ts_print.Union ts)
  | Ts_type.Cond { on; arms } ->
    let rec chain = function
      | [] -> CErrors.anomaly (Pp.str "Ts_names.ty: a conditional has arms.")
      | [ (_, t) ] -> ty names tvars t
      | (c, t) :: rest ->
        Ts_print.Conditional
          { check = ty names tvars on
          ; extends = ty names tvars (Ts_type.Glob (c, []))
          ; yes = ty names tvars t
          ; no = chain rest
          }
    in
    chain arms

and implicit_args names r =
  List.filter_map (Ts_sig.implicit names.sigs r) ~f:(fun g ->
    match find names names.types g with
    | None -> None
    | Some _ -> Some (ty names erased (Ts_type.Glob (g, []))))
;;

let signature names (tparams : Ts_type.tparam list) =
  let letters =
    tvar_names
      names
      ~taken:[]
      (List.count tparams ~f:(fun (p : Ts_type.tparam) -> Option.is_none p.hint))
  in
  let _, _, rev_names =
    List.fold
      tparams
      ~init:(List.fold letters ~init:names.type_names ~f:Set.add, letters, [])
      ~f:(fun (used, letters, acc) (p : Ts_type.tparam) ->
        match p.hint, letters with
        | None, l :: rest -> used, rest, l :: acc
        | None, [] ->
          CErrors.anomaly (Pp.str "Ts_names.signature: a letter per parameter.")
        | Some id, _ ->
          let n = next used (upper (Id.to_string id)) in
          Set.add used n, letters, n :: acc)
  in
  let params = List.rev rev_names in
  let tvars = numbered params in
  ( tvars
  , List.map2_exn params tparams ~f:(fun name (p : Ts_type.tparam) ->
      { Ts_print.name; bound = Option.map p.bound ~f:(ty names tvars) }) )
;;

let function_type names (tvars, tparams) t ~arity =
  let taken, result = Ts_type.split arity t in
  let taken = List.filter taken ~f:(fun a -> not (Ts_type.is_erased a)) in
  Ts_print.Fn
    { tparams
    ; params = List.mapi taken ~f:(fun i a -> Printf.sprintf "_%d" i, ty names tvars a)
    ; result = ty names tvars result
    }
;;

type avoid = Set.M(String).t

let avoid names =
  let taken =
    match names.file with
    | Whole -> names.root_values
    | File { bound; _ } ->
      List.fold bound ~init:names.root_values ~f:(fun s b -> Set.add s b.local)
  in
  let taken = Set.union taken !(names.lifts) in
  let taken = Refmap.fold (fun _ l s -> Set.add s l) names.methods taken in
  match names.scope with
  | Top -> taken
  | Body { taken = locals; _ } -> Set.union taken locals
;;

let lift names x = names.lifts := Set.add !(names.lifts) x
let lifted names = !(names.lifts)
let restore names a = names.lifts := a

let type_params names abstracts =
  List.zip_exn
    (List.map abstracts ~f:(fun (a : Ts_sig.abstract) -> a.global))
    (tparams (named names (List.map abstracts ~f:(fun (a : Ts_sig.abstract) -> a.id))))
;;

let in_scope names params =
  { names with
    types = List.fold params ~init:names.types ~f:(fun m (g, n) -> Refmap.add g n m)
  ; type_names = List.fold params ~init:names.type_names ~f:(fun s (_, n) -> Set.add s n)
  ; abstracts = List.fold params ~init:names.abstracts ~f:(fun s (g, _) -> Refset.add g s)
  }
;;

let is_abstract names r = Refset.mem r names.abstracts

let lambda_name names base =
  let taken = Set.union names.type_names !(names.lambdas) in
  let n = next taken (if is_reserved base then base ^ "0" else base) in
  names.lambdas := Set.add !(names.lambdas) n;
  n
;;

let in_body names ~body ~params ~locals ~holders ~hoisted ~modules =
  let taken =
    Set.of_list
      (module String)
      (List.map params ~f:snd
       @ List.map modules ~f:snd
       @ List.map locals ~f:snd
       @ List.map holders ~f:snd)
  in
  let outer_paths, outer_params, outer_locals, outer_holders, outer_taken =
    match names.scope with
    | Body { paths; params; locals; holders; taken } ->
      paths, params, locals, holders, taken
    | Top -> [], ModPath.Map.empty, Refmap.empty, Refmap.empty, Set.empty (module String)
  in
  { names with
    hoisted = List.fold hoisted ~init:names.hoisted ~f:(fun s r -> Refset.add r s)
  ; scope =
      Body
        { paths = body :: outer_paths
        ; params =
            List.fold (params @ modules) ~init:outer_params ~f:(fun m (mp, n) ->
              ModPath.Map.add mp n m)
        ; locals =
            List.fold locals ~init:outer_locals ~f:(fun m (r, n) -> Refmap.add r n m)
        ; holders =
            List.fold holders ~init:outer_holders ~f:(fun m (r, n) -> Refmap.add r n m)
        ; taken = Set.union outer_taken taken
        }
  }
;;

let reserve avoid base =
  let n = next avoid base in
  n, Set.add avoid n
;;

let add = Set.add
let merge = Set.union
let apart = Set.of_list (module String)

let fresh avoid (b : ml_ident) =
  match b with
  | Dummy -> reserve avoid "_unused"
  | Id id | Tmp id ->
    (match camel id with
     | "" -> reserve avoid "_unused"
     | s -> reserve avoid s)
;;

let key avoid id =
  let s = camel id in
  if Set.mem builtin_methods s
  then (
    let k = method_key avoid s in
    k, Set.add avoid k)
  else fresh avoid (Id id)
;;

let referenced_globals sels =
  let seen = ref Refset.empty
  and order = ref [] in
  let add r =
    if not (Refset.mem r !seen)
    then (
      seen := Refset.add r !seen;
      order := r :: !order)
  in
  let inductive c =
    match c.glob with
    | GlobRef.ConstructRef (ind, _) -> Some { c with glob = GlobRef.IndRef ind }
    | GlobRef.VarRef _ | GlobRef.ConstRef _ | GlobRef.IndRef _ -> None
  in
  let rec ast a =
    (match a with
     | MLglob r | MLcons (_, r, _) -> add r
     | MLcase (_, _, branches) ->
       let ctor (_, p, _) =
         match p with
         | Pcons (c, _) | Pusual c -> inductive c
         | Prel _ | Pwild | Ptuple _ -> None
       in
       Option.iter (Array.find_map branches ~f:ctor) ~f:add
     | MLrel _
     | MLapp _
     | MLlam _
     | MLletin _
     | MLtuple _
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
  fold_decls sels ~init:() ~f:(fun () d ->
    match d with
    | Dterm (r, a, _) -> if not (Table.is_custom r) then ast a
    | Dfix (rv, av, _) ->
      Array.iteri av ~f:(fun i a -> if not (Table.is_custom rv.(i)) then ast a)
    | Dind _ | Dtype _ -> ());
  List.rev !order
;;

let local_module names mp =
  match names.file with
  | Whole -> true
  | File { dp; _ } -> Option.is_none (foreign dp mp)
;;

let rec in_functor_body names = function
  | ModPath.MPdot (parent, _) ->
    Option.is_some (Ts_sig.functor_ names.sigs parent) || in_functor_body names parent
  | ModPath.MPfile _ | ModPath.MPbound _ -> false
;;

let with_methods names ~taken sels =
  let rec path = function
    | Ts_print.Var root -> Some (root, [])
    | Ts_print.Field (e, f) ->
      Option.map (path e) ~f:(fun (root, mods) -> root, mods @ [ f ])
    | _ -> None
  in
  let bind (taken, methods, sources) r =
    let mp = Table.modpath_of_r r in
    match find names names.values r with
    | Some member
      when is_method member
           && (not (Refmap.mem r methods))
           && local_module names mp
           && not (in_functor_body names mp) ->
      (match Option.bind (object_path names mp) ~f:path with
       | Some source ->
         let local = next taken member in
         let field = member, local in
         ( Set.add taken local
         , Refmap.add r local methods
         , if List.Assoc.mem sources ~equal:[%equal: string * string list] source
           then
             List.map sources ~f:(fun (s, fields) ->
               ( s
               , if [%equal: string * string list] s source
                 then fields @ [ field ]
                 else fields ))
           else sources @ [ source, [ field ] ] )
       | None -> taken, methods, sources)
    | Some _ | None -> taken, methods, sources
  in
  let _, methods, sources =
    List.fold (referenced_globals sels) ~init:(taken, names.methods, []) ~f:bind
  in
  { names with methods; own_bound = sources }
;;

let bind_methods names sels = with_methods names ~taken:(avoid names) sels

let methods_of names root =
  List.filter names.own_bound ~f:(fun ((root', _), _) -> String.equal root root')
;;

let in_file names mp sels =
  match mp with
  | ModPath.MPfile dp when names.modular ->
    let taken =
      Option.value (ModPath.Map.find_opt mp names.file_values) ~default:reserved
    in
    let bind (taken, bound) r =
      match foreign dp (Table.modpath_of_r r) with
      | Some dp' when Refmap.mem r names.values ->
        let mods = path names r
        and member = member_name names r in
        if binds mods member
        then (
          let local = next taken member in
          Set.add taken local, { source = dp', mods; member; local } :: bound)
        else taken, bound
      | Some _ | None -> taken, bound
    in
    let taken, bound = List.fold (referenced_globals sels) ~init:(taken, []) ~f:bind in
    with_methods
      { names with
        file = File { dp; referenced = ref []; bound = List.rev bound }
      ; lifts = ref (Set.empty (module String))
      ; methods = Refmap.empty
      ; own_bound = []
      }
      ~taken
      sels
  | ModPath.MPfile _ | ModPath.MPdot _ | ModPath.MPbound _ -> names
;;

let imports names =
  match names.file with
  | Whole -> []
  | File { referenced; _ } ->
    List.rev_map !referenced ~f:(fun dp -> alias names dp, file_name names dp)
;;

let bindings names =
  match names.file with
  | Whole -> []
  | File { referenced; bound; _ } ->
    let sources =
      List.concat_map (List.rev !referenced) ~f:(fun dp ->
        List.fold bound ~init:[] ~f:(fun acc b ->
          if
            DirPath.equal (fst b.source) dp
            && not (List.exists acc ~f:(same_source b.source))
          then acc @ [ b.source ]
          else acc))
    in
    List.map sources ~f:(fun ((dp, mods) as s) ->
      ( (alias names dp, mods)
      , List.filter_map bound ~f:(fun b ->
          if same_source s b.source then Some (b.member, b.local) else None) ))
;;
