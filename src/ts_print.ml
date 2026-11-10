open Import

type ty =
  | Name of string * ty list
  | Literal of string
  | Fn of
      { tparams : tparam list
      ; params : (string * ty) list
      ; result : ty
      }
  | Union of ty list
  | Tuple of ty list
  | Conditional of
      { check : ty
      ; extends : ty
      ; yes : ty
      ; no : ty
      }
  | Raw of segment list
  | Typeof of string * string list
  | Indexed of ty * string

and segment =
  | Verbatim of string
  | Hole of ty

and tparam =
  { name : string
  ; bound : ty option
  }
[@@deriving compare, equal, hash, sexp_of]

module Ty_key = struct
  type t = ty

  let compare = compare_ty
  let hash = hash_ty
  let sexp_of_t = sexp_of_ty
end

let unbounded = List.map ~f:(fun name -> { name; bound = None })

type helper =
  | Unary_constructor [@rename "__unaryConstructor"]
  | Unary_order [@rename "__unaryOrder"]
  | Fail [@rename "__fail"]
  | Lazy [@rename "__lazy"]
  | Read_cell [@rename "__readCell"]
  | Write_cell [@rename "__writeCell"]
  | Magic [@rename "__magic"]
[@@deriving equal, to_string]

type expr =
  | Var of string
  | Code of string
  | Helper of helper
  | Text of string
  | Bytes of string
  | Bigint of string
  | Number of string
  | Field of expr * string
  | Index of expr * int
  | Cell_read of expr * string
  | Tuple of expr list
  | Call of expr * ty list * expr list
  | Arrow of tparam list * (string * ty) list * ty option * body
  | Cond of expr * expr * expr
  | Equals of expr * expr
  | Not_equals of expr * expr
  | Add of expr * expr
  | Not of expr
  | Record of (string * expr) list
  | Module_object of (string * expr) list
  | Satisfies of expr * ty

and body =
  | Expr of expr
  | Block of stmt list

and stmt =
  | Const of string * ty option * expr
  | Bind of (string * string) list * expr
  | Let of string * ty
  | Variable of string * expr
  | Assign of string * expr
  | Cell_write of string * string * expr
  | Bump of string * int
  | Eval of expr
  | Return of expr
  | Break
  | Continue
  | Switch of expr * case list
  | If of expr * stmt list * stmt list
  | Loop of stmt list
  | While of string * stmt list

and case =
  { label : expr option
  ; body : stmt list
  }
[@@deriving equal]

type type_decl =
  | Alias of
      { name : string
      ; tparams : tparam list
      ; def : ty
      }
  | Interface of
      { name : string
      ; tparams : tparam list
      ; fields : (string * ty) list
      }
  | Lambda of
      { name : string
      ; base : string
      ; def : ty
      }
  | Kind of
      { name : string
      ; base : string
      ; slots : (string * string) list
      }

type value =
  { name : string
  ; ty : ty option
  ; value : expr
  }

type path = string * string list

type decl =
  | Type of type_decl
  | Value of value
  | Members of
      { fields : (string * string) list
      ; source : path
      }

type top =
  { exported : bool
  ; decl : decl
  }

type import =
  { alias : string
  ; file : string
  ; type_only : bool
  }

type program =
  { header : string option
  ; imports : import list
  ; decls : top list
  }

let of_path (root, members) =
  List.fold members ~init:(Var root) ~f:(fun e m -> Field (e, m))
;;

let helper_definition = function
  | Read_cell ->
    [ {|const __readCell = <T>(cells: readonly (readonly [T])[], index: number): T => {
  const cell = cells[index];

  if (cell === undefined) {
    throw new Error("Invalid continuation stack access");
  }

  return cell[0];
};|}
    ]
  | Write_cell ->
    [ {|const __writeCell = <T>(cells: [T][], index: number, value: T): void => {
  const cell = cells[index];

  if (cell === undefined) {
    cells[index] = [value];
  } else {
    cell[0] = value;
  }
};|}
    ]
  | Unary_constructor ->
    [ {|const __unaryConstructor = <T extends object>(
  __unaryBuild: (__unaryChild: T) => T
): ((__unaryChild: T) => T) => {
  const __unarySuccessors = new WeakMap<T, WeakRef<T>>();

  return (__unaryChild: T): T => {
    const __unaryExisting = __unarySuccessors.get(__unaryChild)?.deref();

    if (__unaryExisting !== undefined) {
      return __unaryExisting;
    }

    const __unaryValue = Object.freeze(__unaryBuild(__unaryChild));
    __unarySuccessors.set(__unaryChild, new WeakRef(__unaryValue));

    return __unaryValue;
  };
};|}
    ]
  | Unary_order ->
    [ {|/* oxlint-disable anti-slop/no-runtime-typeof -- Numbers mark complete entries. */
const __unaryOrder = <T extends object, R extends object>(
  __unaryTag: string,
  __unaryZero: string,
  __unarySuccessor: string,
  __unaryField: string,
  __unaryChild: (value: T) => T | undefined,
  __unaryYes: R,
  __unaryNo: R,
  __unaryFallback: (__unaryLeft: T, __unaryRight: T) => R
): ((__unaryLeft: T, __unaryRight: T) => R) => {
  interface __UnaryPrefix {
    readonly depth: number;
    readonly rest: T;
  }

  const __unaryPrefixes = new WeakMap<T, number | __UnaryPrefix>();

  const __unarySave = (
    __unaryRoot: T,
    __unaryDepth: number,
    __unaryRest: T | undefined
  ): void => {
    if (__unaryDepth === 0 && __unaryRest !== undefined) {
      return;
    }

    const __unaryPrevious = __unaryPrefixes.get(__unaryRoot);

    if (
      typeof __unaryPrevious === "number" ||
      (__unaryPrevious !== undefined &&
        __unaryPrevious.depth >= __unaryDepth &&
        __unaryRest !== undefined)
    ) {
      return;
    }

    __unaryPrefixes.set(
      __unaryRoot,
      __unaryRest === undefined
        ? __unaryDepth
        : { depth: __unaryDepth, rest: __unaryRest }
    );

    if (__unaryDepth === 0) {
      return;
    }

    const __unaryFirst = __unaryChild(__unaryRoot);

    if (__unaryFirst === undefined) {
      return;
    }

    const __unaryPreviousFirst = __unaryPrefixes.get(__unaryFirst);

    if (
      __unaryPreviousFirst === undefined ||
      (typeof __unaryPreviousFirst !== "number" &&
        (__unaryPreviousFirst.depth < __unaryDepth - 1 ||
          __unaryRest === undefined))
    ) {
      __unaryPrefixes.set(
        __unaryFirst,
        __unaryRest === undefined
          ? __unaryDepth - 1
          : { depth: __unaryDepth - 1, rest: __unaryRest }
      );
    }
  };

  const __unaryDecide = (
    __unaryLeftDepth: number,
    __unaryLeftRest: T | undefined,
    __unaryRightDepth: number,
    __unaryRightRest: T | undefined
  ): R | undefined => {
    if (
      __unaryLeftRest === undefined &&
      __unaryRightDepth >= __unaryLeftDepth
    ) {
      return __unaryYes;
    }

    if (
      __unaryRightRest === undefined &&
      __unaryLeftDepth > __unaryRightDepth
    ) {
      return __unaryNo;
    }

    return undefined;
  };

  const __unaryStep = (
    __unaryCurrent: T | undefined
  ): T | undefined | false => {
    if (__unaryCurrent === undefined) {
      return false;
    }

    const __unaryKind = Object.getOwnPropertyDescriptor(
      __unaryCurrent,
      __unaryTag
    );

    if (
      __unaryKind === undefined ||
      !Object.hasOwn(__unaryKind, "value") ||
      __unaryKind.writable !== false ||
      __unaryKind.configurable !== false
    ) {
      return false;
    }

    if (__unaryKind.value === __unaryZero) {
      return undefined;
    }

    if (__unaryKind.value !== __unarySuccessor) {
      return false;
    }

    const __unaryNext = Object.getOwnPropertyDescriptor(
      __unaryCurrent,
      __unaryField
    );

    if (
      __unaryNext === undefined ||
      !Object.hasOwn(__unaryNext, "value") ||
      __unaryNext.writable !== false ||
      __unaryNext.configurable !== false
    ) {
      return false;
    }

    const __unaryValue = __unaryChild(__unaryCurrent);

    if (Object(__unaryValue) !== __unaryValue) {
      return false;
    }

    return __unaryValue;
  };

  const __unarySlow = (
    __unaryLeft: T,
    __unaryRight: T,
    __unaryLeftPrefix: number | __UnaryPrefix | undefined,
    __unaryRightPrefix: number | __UnaryPrefix | undefined
  ): R => {
    let __unaryLeftDepth = 0;
    let __unaryRightDepth = 0;
    let __unaryLeftRest: T | undefined = __unaryLeft;
    let __unaryRightRest: T | undefined = __unaryRight;

    if (typeof __unaryLeftPrefix === "number") {
      __unaryLeftDepth = __unaryLeftPrefix;
      __unaryLeftRest = undefined;
    } else if (__unaryLeftPrefix !== undefined) {
      __unaryLeftDepth = __unaryLeftPrefix.depth;
      __unaryLeftRest = __unaryLeftPrefix.rest;
    }

    if (typeof __unaryRightPrefix === "number") {
      __unaryRightDepth = __unaryRightPrefix;
      __unaryRightRest = undefined;
    } else if (__unaryRightPrefix !== undefined) {
      __unaryRightDepth = __unaryRightPrefix.depth;
      __unaryRightRest = __unaryRightPrefix.rest;
    }

    const __unaryKnown = __unaryDecide(
      __unaryLeftDepth,
      __unaryLeftRest,
      __unaryRightDepth,
      __unaryRightRest
    );

    if (__unaryKnown !== undefined) {
      return __unaryKnown;
    }

    let __unaryAnswer: R | undefined;

    for (;;) {
      __unaryAnswer = __unaryDecide(
        __unaryLeftDepth,
        __unaryLeftRest,
        __unaryRightDepth,
        __unaryRightRest
      );

      if (__unaryAnswer !== undefined) {
        break;
      }

      const __unaryAdvanceLeft =
        __unaryRightRest === undefined ||
        (__unaryLeftRest !== undefined &&
          __unaryLeftDepth <= __unaryRightDepth);

      const __unaryCurrent = __unaryAdvanceLeft
        ? __unaryLeftRest
        : __unaryRightRest;

      const __unaryDepth = __unaryAdvanceLeft
        ? __unaryLeftDepth
        : __unaryRightDepth;

      const __unaryNext = __unaryStep(__unaryCurrent);

      if (__unaryNext === false) {
        break;
      }

      let __unaryNextDepth = __unaryDepth;
      let __unaryNextRest: T | undefined;

      if (__unaryNext === undefined) {
        __unaryNextRest = undefined;
      } else {
        const __unarySuffix = __unaryPrefixes.get(__unaryNext);
        __unaryNextDepth = __unaryDepth + 1;
        __unaryNextRest = __unaryNext;

        if (typeof __unarySuffix === "number") {
          __unaryNextDepth += __unarySuffix;
          __unaryNextRest = undefined;
        } else if (__unarySuffix !== undefined) {
          __unaryNextDepth += __unarySuffix.depth;
          __unaryNextRest = __unarySuffix.rest;
        }

        if (!Number.isSafeInteger(__unaryNextDepth)) {
          break;
        }
      }

      if (__unaryAdvanceLeft) {
        __unaryLeftDepth = __unaryNextDepth;
        __unaryLeftRest = __unaryNextRest;
      } else {
        __unaryRightDepth = __unaryNextDepth;
        __unaryRightRest = __unaryNextRest;
      }
    }

    __unarySave(__unaryLeft, __unaryLeftDepth, __unaryLeftRest);
    __unarySave(__unaryRight, __unaryRightDepth, __unaryRightRest);

    return __unaryAnswer ?? __unaryFallback(__unaryLeft, __unaryRight);
  };

  return (__unaryLeft: T, __unaryRight: T): R => {
    const __unaryLeftPrefix = __unaryPrefixes.get(__unaryLeft);
    const __unaryRightPrefix = __unaryPrefixes.get(__unaryRight);

    if (
      typeof __unaryLeftPrefix === "number" &&
      typeof __unaryRightPrefix === "number"
    ) {
      return __unaryLeftPrefix <= __unaryRightPrefix ? __unaryYes : __unaryNo;
    }

    return __unarySlow(
      __unaryLeft,
      __unaryRight,
      __unaryLeftPrefix,
      __unaryRightPrefix
    );
  };
};
/* oxlint-enable anti-slop/no-runtime-typeof */|}
    ]
  | Fail ->
    [ "const __fail = (message: string): never => {\n  throw new Error(message);\n};" ]
  | Lazy ->
    [ "const __lazy = <T>(force: () => T): (() => T) => {\n\
      \  let cell: { readonly value: T } | undefined;\n\n\
      \  return () => {\n\
      \    if (cell === undefined) {\n\
      \      cell = { value: force() };\n\
      \    }\n\n\
      \    return cell.value;\n\
      \  };\n\
       };"
    ]
  | Magic ->
    [ "const __coerces = <From, To>(_value: From): _value is From & To => true;"
    ; "const __magic = <From, To>(value: From): To =>\n\
      \  __coerces<From, To>(value) ? value : __fail(\"unreachable cast\");"
    ]
;;

let helpers_used decls =
  let used = ref [] in
  let rec expr = function
    | Helper h -> used := h :: !used
    | Var _ | Code _ | Text _ | Bytes _ | Bigint _ | Number _ -> ()
    | Field (e, _) | Index (e, _) -> expr e
    | Cell_read (e, _) ->
      used := Read_cell :: !used;
      expr e
    | Tuple es -> List.iter es ~f:expr
    | Call (f, _, args) ->
      expr f;
      List.iter args ~f:expr
    | Arrow (_, _, _, Expr e) -> expr e
    | Arrow (_, _, _, Block ss) -> List.iter ss ~f:stmt
    | Cond (a, b, c) -> List.iter [ a; b; c ] ~f:expr
    | Equals (a, b) | Not_equals (a, b) | Add (a, b) -> List.iter [ a; b ] ~f:expr
    | Record fields | Module_object fields -> List.iter fields ~f:(fun (_, e) -> expr e)
    | Satisfies (e, _) | Not e -> expr e
  and stmt = function
    | Const (_, _, e) | Bind (_, e) | Variable (_, e) | Assign (_, e) | Eval e | Return e
      -> expr e
    | Cell_write (_, _, e) ->
      used := Write_cell :: !used;
      expr e
    | Let _ | Bump _ | Break | Continue -> ()
    | Switch (e, cases) ->
      expr e;
      List.iter cases ~f:(fun (c : case) ->
        Option.iter c.label ~f:expr;
        List.iter c.body ~f:stmt)
    | If (e, ss, rest) ->
      expr e;
      List.iter ss ~f:stmt;
      List.iter rest ~f:stmt
    | Loop ss | While (_, ss) -> List.iter ss ~f:stmt
  in
  List.iter decls ~f:(fun t ->
    match t.decl with
    | Value { value; _ } -> expr value
    | Type _ | Members _ -> ());
  let used = if List.mem !used Magic ~equal:equal_helper then Fail :: !used else !used in
  List.filter
    [ Fail; Lazy; Magic; Unary_constructor; Unary_order; Read_cell; Write_cell ]
    ~f:(fun h -> List.mem used h ~equal:equal_helper)
;;

let print_width = 80

type line =
  | Soft
  | Space
  | Hard

type role =
  | Binding
  | Keyword
  | Clause
  | Plain
[@@deriving equal]

type doc =
  | Text of string
  | Concat of doc list
  | Line of line
  | Group of group
  | Indent of doc
  | Align of int * doc
  | If_break of
      { id : int option
      ; broken : doc
      ; flat : doc
      }
  | Indent_if_break of
      { id : int
      ; contents : doc
      }
  | Break_parent
  | Statements of spaced list
  | Fill of doc list

and group =
  { id : int option
  ; break : bool
  ; contents : doc
  ; states : doc list
  }

and spaced =
  { role : role
  ; block_like : bool
  ; doc : doc
  }

let empty = Text ""
let text s = Text s
let softline = Line Soft
let line = Line Space
let hardline = Line Hard
let indent d = Indent d
let align n d = Align (n, d)
let if_break ?id broken flat = If_break { id; broken; flat }

let join sep = function
  | [] -> empty
  | docs -> Concat (List.intersperse docs ~sep)
;;

let joined items = join hardline (List.map items ~f:(fun s -> s.doc))

let rec string_end s q i =
  if i >= String.length s
  then None
  else if Char.equal s.[i] '\\'
  then string_end s q (i + 2)
  else if Char.equal s.[i] q
  then Some (i + 1)
  else string_end s q (i + 1)
;;

let rec template_end s i =
  let n = String.length s in
  let rec text i holes =
    if i >= n
    then None
    else (
      match s.[i] with
      | '\\' -> text (i + 2) holes
      | '`' -> Some (i + 1, List.rev holes)
      | '$' when i + 1 < n && Char.equal s.[i + 1] '{' -> hole (i + 2) (i + 2) 0 holes
      | _ -> text (i + 1) holes)
  and hole from i depth holes =
    if i >= n
    then None
    else (
      match s.[i] with
      | '"' | '\'' | '`' ->
        Option.bind (literal_end s i) ~f:(fun j -> hole from j depth holes)
      | '{' -> hole from (i + 1) (depth + 1) holes
      | '}' when depth > 0 -> hole from (i + 1) (depth - 1) holes
      | '}' -> text (i + 1) ((from, i) :: holes)
      | _ -> hole from (i + 1) depth holes)
  in
  text i []

and literal_end s i =
  match s.[i] with
  | '`' -> Option.map (template_end s (i + 1)) ~f:fst
  | q -> string_end s q (i + 1)
;;

let code_newlines s =
  let n = String.length s in
  let rec go i acc =
    if i >= n
    then List.rev acc
    else (
      match s.[i] with
      | '"' | '\'' | '`' ->
        (match literal_end s i with
         | Some j -> go j acc
         | None -> List.rev acc)
      | '\n' -> go (i + 1) (i :: acc)
      | _ -> go (i + 1) acc)
  in
  go 0 []
;;

let indented ind s =
  match code_newlines s with
  | [] -> s
  | cuts ->
    let b = Buffer.create (String.length s + (ind * List.length cuts)) in
    let rec go start = function
      | [] -> Buffer.add_substring b s ~pos:start ~len:(String.length s - start)
      | i :: rest ->
        Buffer.add_substring b s ~pos:start ~len:(i - start + 1);
        if i + 1 < String.length s && Char.( <> ) s.[i + 1] '\n'
        then Buffer.add_string b (String.make ind ' ');
        go (i + 1) rest
    in
    go 0 cuts;
    Buffer.contents b
;;

let spans_lines s = String.contains s '\n' && not (List.is_empty (code_newlines s))

let rec breaks ~into_groups = function
  | Line Hard | Break_parent -> true
  | Text s -> spans_lines s
  | Line (Soft | Space) -> false
  | Concat ds | Fill ds -> List.exists ds ~f:(breaks ~into_groups)
  | Group g -> g.break || (into_groups && breaks ~into_groups g.contents)
  | Indent d | Align (_, d) | Indent_if_break { contents = d; _ } -> breaks ~into_groups d
  | If_break { broken; flat; _ } -> breaks ~into_groups broken || breaks ~into_groups flat
  | Statements items -> breaks ~into_groups (joined items)
;;

let forces = breaks ~into_groups:false
let will_break = breaks ~into_groups:true

let rec can_break = function
  | Line _ -> true
  | Text _ | Break_parent -> false
  | Concat ds | Fill ds -> List.exists ds ~f:can_break
  | Group g -> can_break g.contents
  | Indent d | Align (_, d) | Indent_if_break { contents = d; _ } -> can_break d
  | If_break { broken; flat; _ } -> can_break broken || can_break flat
  | Statements items -> can_break (joined items)
;;

let last_id = ref 0

let fresh_id () =
  Int.incr last_id;
  !last_id
;;

let group ?(should_break = false) ?id contents =
  Group { id; break = should_break || forces contents; contents; states = [] }
;;

let conditional_group = function
  | [] -> empty
  | first :: _ as states -> Group { id = None; break = false; contents = first; states }
;;

let rec remove_lines = function
  | Line Soft -> empty
  | Line Space -> text " "
  | If_break { flat; _ } -> remove_lines flat
  | Concat ds -> Concat (List.map ds ~f:remove_lines)
  | Fill ds -> Fill (List.map ds ~f:remove_lines)
  | Group ({ states = []; _ } as g) -> Group { g with contents = remove_lines g.contents }
  | Group g ->
    let states = List.map g.states ~f:remove_lines in
    Group { g with contents = List.hd_exn states; states }
  | Indent d -> Indent (remove_lines d)
  | Align (n, d) -> Align (n, remove_lines d)
  | Indent_if_break i -> Indent_if_break { i with contents = remove_lines i.contents }
  | Statements items ->
    Statements (List.map items ~f:(fun s -> { s with doc = remove_lines s.doc }))
  | (Text _ | Line Hard | Break_parent) as d -> d
;;

(* Prettier counts one column per code point, two for an East Asian wide
   character, and none for a control character or a combining mark. *)
let width s =
  if String.for_all s ~f:(fun c -> Char.( >= ) c ' ' && Char.( <= ) c '\x7f')
  then String.length s
  else (
    let wide u =
      (u >= 0x1100 && u <= 0x115F)
      || (u >= 0x2E80 && u <= 0x303E)
      || (u >= 0x3041 && u <= 0x33FF)
      || (u >= 0x3400 && u <= 0x4DBF)
      || (u >= 0x4E00 && u <= 0x9FFF)
      || (u >= 0xA000 && u <= 0xA4CF)
      || (u >= 0xAC00 && u <= 0xD7A3)
      || (u >= 0xF900 && u <= 0xFAFF)
      || (u >= 0xFE30 && u <= 0xFE4F)
      || (u >= 0xFF00 && u <= 0xFF60)
      || (u >= 0xFFE0 && u <= 0xFFE6)
      || (u >= 0x1F300 && u <= 0x1F64F)
      || (u >= 0x1F900 && u <= 0x1F9FF)
      || (u >= 0x20000 && u <= 0x3FFFD)
    in
    let zero u =
      u <= 0x1F
      || (u >= 0x7F && u <= 0x9F)
      || (u >= 0x300 && u <= 0x36F)
      || (u >= 0x1AB0 && u <= 0x1AFF)
      || (u >= 0x1DC0 && u <= 0x1DFF)
      || (u >= 0x20D0 && u <= 0x20FF)
      || (u >= 0xFE00 && u <= 0xFE0F)
      || (u >= 0xFE20 && u <= 0xFE2F)
    in
    String.Utf8.fold (String.Utf8.of_string s) ~init:0 ~f:(fun acc u ->
      let u = Uchar.to_scalar u in
      acc + if zero u then 0 else if wide u then 2 else 1))
;;

type mode =
  | Flat
  | Broken
[@@deriving equal]

let fits ?(must_be_flat = false) modes next rest room =
  let rec go room pending stack rest =
    if room < 0
    then false
    else (
      match stack with
      | [] ->
        (match rest with
         | [] -> true
         | (_, m, d) :: rest -> go room pending [ m, d ] rest)
      | (m, d) :: stack ->
        (match d with
         | Line Hard -> true
         | Line _ when equal_mode m Broken -> true
         | Text "" | Break_parent | Line Soft -> go room pending stack rest
         | Text s ->
           let room = room - Bool.to_int pending in
           (match String.index s '\n' with
            | Some i -> room - width (String.prefix s i) >= 0
            | None -> go (room - width s) false stack rest)
         | Concat ds | Fill ds ->
           go room pending (List.map ds ~f:(fun d -> m, d) @ stack) rest
         | Indent d | Align (_, d) | Indent_if_break { contents = d; _ } ->
           go room pending ((m, d) :: stack) rest
         | Group g ->
           let m = if g.break && not must_be_flat then Broken else m in
           let d =
             match g.states with
             | _ :: _ when equal_mode m Broken -> List.last_exn g.states
             | _ -> g.contents
           in
           go room pending ((m, d) :: stack) rest
         | If_break { id; broken; flat } ->
           let gm =
             match id with
             | None -> m
             | Some id -> Option.value (Hashtbl.find modes id) ~default:Flat
           in
           go
             room
             pending
             ((m, if equal_mode gm Broken then broken else flat) :: stack)
             rest
         | Statements items -> go room pending ((m, joined items) :: stack) rest
         | Line Space -> go room true stack rest))
  in
  go room false [ next ] rest
;;

let trim_trailing_blanks b =
  let n = ref (Buffer.length b) in
  while
    !n > 0
    && (Char.equal (Buffer.nth b (!n - 1)) ' ' || Char.equal (Buffer.nth b (!n - 1)) '\t')
  do
    Int.decr n
  done;
  Stdlib.Buffer.truncate b !n
;;

(* The break-mode group case of Prettier's [printDocToString]. *)
let choose_group modes cmds ~room g =
  let fits d = fits modes (Flat, d) cmds room in
  if (not g.break) && fits g.contents
  then Flat, g.contents
  else (
    match g.states with
    | [] -> Broken, g.contents
    | states when g.break -> Broken, List.last_exn states
    | _ :: middle ->
      let rec try_states = function
        | [] | [ _ ] -> Broken, List.last_exn g.states
        | s :: rest -> if fits s then Flat, s else try_states rest
      in
      try_states middle)
;;

let blank_line (prev, prev_broken) (next, next_broken) =
  equal_role next.role Keyword
  || prev.block_like
  || (equal_role prev.role Binding && prev_broken)
  || (equal_role next.role Binding && next_broken)
;;

let layout doc =
  let modes = Hashtbl.create (module Int) ~size:16 in
  let rec go b pos remeasure = function
    | [] -> pos, remeasure
    | (ind, m, d) :: cmds ->
      (match d with
       | Text s ->
         let s = indented ind s in
         Buffer.add_string b s;
         let pos =
           match String.rindex s '\n' with
           | Some i -> width (String.drop_prefix s (i + 1))
           | None -> pos + width s
         in
         go b pos remeasure cmds
       | Concat ds -> go b pos remeasure (List.map ds ~f:(fun d -> ind, m, d) @ cmds)
       | Indent d -> go b pos remeasure ((ind + 2, m, d) :: cmds)
       | Align (n, d) -> go b pos remeasure ((ind + n, m, d) :: cmds)
       | Group g ->
         let (gm, gd), remeasure =
           if equal_mode m Flat && not remeasure
           then ((if g.break then Broken else Flat), g.contents), remeasure
           else choose_group modes cmds ~room:(print_width - pos) g, false
         in
         Option.iter g.id ~f:(fun id -> Hashtbl.set modes ~key:id ~data:gm);
         go b pos remeasure ((ind, gm, gd) :: cmds)
       | If_break { id; broken; flat } ->
         let gm =
           match id with
           | None -> Some m
           | Some id -> Hashtbl.find modes id
         in
         (match gm with
          | Some Broken -> go b pos remeasure ((ind, m, broken) :: cmds)
          | Some Flat -> go b pos remeasure ((ind, m, flat) :: cmds)
          | None -> go b pos remeasure cmds)
       | Indent_if_break { id; contents } ->
         (match Hashtbl.find modes id with
          | Some Broken -> go b pos remeasure ((ind + 2, m, contents) :: cmds)
          | Some Flat -> go b pos remeasure ((ind, m, contents) :: cmds)
          | None -> go b pos remeasure cmds)
       | Line Soft when equal_mode m Flat -> go b pos remeasure cmds
       | Line Space when equal_mode m Flat ->
         Buffer.add_char b ' ';
         go b (pos + 1) remeasure cmds
       (* Oxfmt's printer breaks a line only after text, so a break on a
          line that holds nothing but its indentation changes only the
          indentation. *)
       | Line _ ->
         trim_trailing_blanks b;
         let n = Buffer.length b in
         if n > 0 && Char.( <> ) (Buffer.nth b (n - 1)) '\n' then Buffer.add_char b '\n';
         Buffer.add_string b (String.make ind ' ');
         go b ind (remeasure || equal_mode m Flat) cmds
       | Statements items ->
         let pos, remeasure = statements b ind m pos remeasure items in
         go b pos remeasure cmds
       | Fill parts -> go b pos remeasure (fill ind m (print_width - pos) parts @ cmds)
       | Break_parent -> go b pos remeasure cmds)
  and fill ind m room = function
    | [] -> []
    | [ content ] -> [ ind, (if fits_flat room content then Flat else Broken), content ]
    | [ content; separator ] ->
      let mode = if fits_flat room content then Flat else Broken in
      [ ind, mode, content; ind, mode, separator ]
    | content :: separator :: (next :: _ as rest) ->
      let content_mode = if fits_flat room content then Flat else Broken in
      let separator_mode =
        if fits_flat room (Concat [ content; separator; next ]) then Flat else Broken
      in
      [ ind, content_mode, content; ind, separator_mode, separator; ind, m, Fill rest ]
  and fits_flat room d = fits ~must_be_flat:true modes (Flat, d) [] room
  and statements b ind m pos remeasure items =
    let print pos remeasure s =
      let sb = Buffer.create 256 in
      let pos, remeasure = go sb pos remeasure [ ind, m, s.doc ] in
      let text = Buffer.contents sb in
      (s, String.contains text '\n'), text, pos, remeasure
    in
    let rec next prev pos remeasure = function
      | [] -> pos, remeasure
      | s :: rest ->
        let s, text, pos, remeasure = print ind (remeasure || equal_mode m Flat) s in
        trim_trailing_blanks b;
        Buffer.add_string b (if blank_line prev s then "\n\n" else "\n");
        Buffer.add_string b (String.make ind ' ');
        Buffer.add_string b text;
        next s pos remeasure rest
    in
    match items with
    | [] -> pos, remeasure
    | first :: rest ->
      let first, text, pos, remeasure = print pos remeasure first in
      Buffer.add_string b text;
      next first pos remeasure rest
  in
  let b = Buffer.create 1024 in
  ignore (go b 0 false [ 0, Broken, doc ] : int * bool);
  Buffer.contents b
;;

(* Prettier picks double quotes unless the text has more of them than
   single quotes. *)
let string_literal s ~bytes =
  let count q = String.count s ~f:(Char.equal q) in
  let q = if count '"' > count '\'' then '\'' else '"' in
  let b = Buffer.create (String.length s + 2) in
  Buffer.add_char b q;
  String.iter s ~f:(fun c ->
    match c with
    | '\\' -> Buffer.add_string b "\\\\"
    | '\n' -> Buffer.add_string b "\\n"
    | '\r' -> Buffer.add_string b "\\r"
    | '\t' -> Buffer.add_string b "\\t"
    | c when Char.equal c q ->
      Buffer.add_char b '\\';
      Buffer.add_char b c
    | c
      when Char.to_int c < 0x20 || Char.to_int c = 0x7f || (bytes && Char.to_int c > 0x7f)
      -> Printf.bprintf b "\\u%04X" (Char.to_int c)
    | c -> Buffer.add_char b c);
  Buffer.add_char b q;
  Buffer.contents b
;;

(* unicorn's numeric-separators-style as Oxlint implements it. An integer
   part or an exponent of five digits or more takes an underscore every
   three digits from the right, and a fraction takes none. *)
let grouped d =
  let n = String.length d in
  if n < 5
  then d
  else (
    let b = Buffer.create (n + (n / 3)) in
    String.iteri d ~f:(fun i c ->
      if i > 0 && Int.rem (n - i) 3 = 0 then Buffer.add_char b '_';
      Buffer.add_char b c);
    Buffer.contents b)
;;

let separated s =
  let split c s =
    match String.index s c with
    | Some i -> String.prefix s i, Some (String.drop_prefix s (i + 1))
    | None -> s, None
  in
  let sign, s =
    match String.chop_prefix s ~prefix:"-" with
    | Some s -> "-", s
    | None -> "", s
  in
  let mantissa, exponent = split 'e' s in
  let integer, fraction = split '.' mantissa in
  let exponent_sign, power =
    match exponent with
    | Some p when String.is_prefix p ~prefix:"-" -> "-", Some (String.drop_prefix p 1)
    | p -> "", p
  in
  String.concat
    [ sign
    ; grouped integer
    ; (match fraction with
       | Some f -> "." ^ f
       | None -> "")
    ; (match power with
       | Some p -> "e" ^ exponent_sign ^ grouped p
       | None -> "")
    ]
;;

(* Prettier writes an exponent without a plus sign or leading zeros, and
   unicorn's prefer-number-properties asks for [Number.NaN] over the
   global. *)
let number n =
  if String.equal n "NaN"
  then "Number.NaN"
  else (
    let signed = String.is_prefix n ~prefix:"-" in
    let numeric =
      String.length n > Bool.to_int signed
      &&
      match n.[Bool.to_int signed] with
      | '0' .. '9' | '.' -> true
      | _ -> false
    in
    if not numeric
    then n
    else (
      match String.index n 'e' with
      | None -> separated n
      | Some i ->
        let exponent = String.drop_prefix n (i + 1) in
        let sign, digits =
          match exponent.[0] with
          | '+' -> "", String.drop_prefix exponent 1
          | '-' -> "-", String.drop_prefix exponent 1
          | _ -> "", exponent
        in
        let rec strip d =
          if String.length d > 1 && Char.equal d.[0] '0'
          then strip (String.drop_prefix d 1)
          else d
        in
        separated (String.prefix n i ^ "e" ^ sign ^ strip digits)))
;;

let is_ident_char = function
  | 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_' | '$' -> true
  | c -> Char.to_int c >= 0x80
;;

let is_path s =
  List.for_all (String.split s ~on:'.') ~f:(fun seg ->
    (not (String.is_empty seg))
    && (not (Char.is_digit seg.[0]))
    && String.for_all seg ~f:is_ident_char)
;;

let is_number s =
  (not (String.is_empty s))
  && Char.is_digit s.[0]
  && String.for_all s ~f:(fun c -> is_ident_char c || Char.equal c '.')
;;

let is_string_literal s =
  String.( <> ) s ""
  &&
  match s.[0] with
  | ('"' | '\'') as q -> [%equal: int option] (string_end s q 1) (Some (String.length s))
  | _ -> false
;;

let is_template_literal s =
  String.is_prefix s ~prefix:"`"
  && Option.exists (template_end s 1) ~f:(fun (j, _) -> j = String.length s)
;;

let template_holes s =
  match template_end s 1 with
  | Some (_, holes) ->
    List.map holes ~f:(fun (from, upto) -> String.sub s ~pos:from ~len:(upto - from))
  | None -> []
;;

let scan_index s f =
  let n = String.length s in
  let rec go depth i =
    if i >= n
    then None
    else (
      match s.[i] with
      | '"' | '\'' | '`' -> Option.bind (literal_end s i) ~f:(go depth)
      | c when f c depth i -> Some i
      | '(' | '[' | '{' -> go (depth + 1) (i + 1)
      | ')' | ']' | '}' -> go (depth - 1) (i + 1)
      | _ -> go depth (i + 1))
  in
  go 0 0
;;

let scan s f = Option.is_some (scan_index s f)

let is_enclosed s opening =
  let n = String.length s in
  n > 0
  && Char.equal s.[0] opening
  && not
       (scan s (fun c depth i ->
          (Char.equal c ')' || Char.equal c ']' || Char.equal c '}')
          && depth = 1
          && i < n - 1))
;;

let has_top_level_comma s = scan s (fun c depth _ -> Char.equal c ',' && depth = 0)

let top_level_index s tok =
  scan_index s (fun _ depth i ->
    depth = 0 && String.is_substring_at s ~pos:i ~substring:tok)
;;

let has_top_level_token s tok = Option.is_some (top_level_index s tok)

let has_top_level_assignment s =
  let n = String.length s in
  scan s (fun c depth i ->
    Char.equal c '='
    && depth = 0
    && (i = 0 || not (List.mem [ '='; '!'; '<'; '>' ] s.[i - 1] ~equal:Char.equal))
    && (i + 1 >= n || not (List.mem [ '='; '>' ] s.[i + 1] ~equal:Char.equal)))
;;

let union_members s =
  let n = String.length s in
  let rec go depth i cuts =
    if i >= n
    then Some (List.rev cuts)
    else (
      match s.[i] with
      | '"' | '\'' | '`' -> Option.bind (literal_end s i) ~f:(fun j -> go depth j cuts)
      | '=' when i + 1 < n && Char.equal s.[i + 1] '>' ->
        if depth = 0 then None else go depth (i + 2) cuts
      | '(' | '[' | '{' | '<' -> go (depth + 1) (i + 1) cuts
      | ')' | ']' | '}' | '>' -> go (depth - 1) (i + 1) cuts
      | '|' when depth = 0 -> go depth (i + 1) (i :: cuts)
      | _ -> go depth (i + 1) cuts)
  in
  let pieces cuts =
    let rec split start = function
      | [] -> [ String.sub s ~pos:start ~len:(n - start) ]
      | cut :: rest -> String.sub s ~pos:start ~len:(cut - start) :: split (cut + 1) rest
    in
    List.map (split 0 cuts) ~f:String.strip
  in
  match go 0 0 [] with
  | Some (_ :: _ as cuts) ->
    let members = pieces cuts in
    if List.exists members ~f:(fun m -> String.equal m "") then [ s ] else members
  | Some [] | None -> [ s ]
;;

let balanced s =
  let n = String.length s in
  let rec go opened i =
    if i >= n
    then List.is_empty opened
    else (
      match s.[i] with
      | '"' | '\'' | '`' ->
        (match literal_end s i with
         | Some j -> go opened j
         | None -> false)
      | ('(' | '[' | '{') as c -> go (c :: opened) (i + 1)
      | (')' | ']' | '}') as c ->
        (match opened, c with
         | '(' :: rest, ')' | '[' :: rest, ']' | '{' :: rest, '}' -> go rest (i + 1)
         | _ -> false)
      | _ -> go opened (i + 1))
  in
  go [] 0
;;

let atomic_code s =
  String.( <> ) s ""
  && (is_path s
      || is_number s
      || is_string_literal s
      || is_template_literal s
      || is_enclosed s '(')
;;

let is_signed_number s =
  String.length s > 1 && Char.equal s.[0] '-' && is_number (String.drop_prefix s 1)
;;

let strip_parens s =
  if is_enclosed s '('
  then String.strip (String.sub s ~pos:1 ~len:(String.length s - 2))
  else s
;;

let type_scan t ~from ~stop =
  let n = String.length t in
  let rec go depth i =
    if i >= n
    then None
    else if stop depth i
    then Some i
    else (
      match t.[i] with
      | '"' | '\'' | '`' -> Option.bind (literal_end t i) ~f:(go depth)
      | '=' when i + 1 < n && Char.equal t.[i + 1] '>' -> go depth (i + 2)
      | '(' | '[' | '{' | '<' -> go (depth + 1) (i + 1)
      | ')' | ']' | '}' | '>' -> go (depth - 1) (i + 1)
      | _ -> go depth (i + 1))
  in
  go 0 from
;;

let type_operator_index t ~operator =
  type_scan t ~from:0 ~stop:(fun depth i ->
    depth = 0 && String.is_substring_at t ~pos:i ~substring:operator)
;;

let has_top_level_arrow t = Option.is_some (type_operator_index t ~operator:"=>")

let code_arrow s =
  let s = strip_parens s in
  match type_operator_index s ~operator:"=>" with
  | Some i when i > 0 ->
    let signature = String.strip (String.prefix s i) in
    let body = String.strip (String.drop_prefix s (i + 2)) in
    if
      String.( <> ) body ""
      && String.( <> ) signature ""
      && (is_path signature
          || Char.equal signature.[0] '('
          || Char.equal signature.[0] '<')
    then Some (signature, body)
    else None
  | _ -> None
;;

let closing t i =
  type_scan t ~from:i ~stop:(fun depth j ->
    depth = 1
    &&
    match t.[j] with
    | ')' | ']' | '}' | '>' -> true
    | _ -> false)
;;

let split_top_level t =
  let comma depth i = depth = 0 && Char.equal t.[i] ',' in
  let rec go start acc =
    match type_scan t ~from:start ~stop:comma with
    | Some i -> go (i + 1) (String.strip (String.sub t ~pos:start ~len:(i - start)) :: acc)
    | None -> List.rev (String.strip (String.drop_prefix t start) :: acc)
  in
  if String.equal (String.strip t) "" then [] else go 0 []
;;

let code_signature s =
  let n = String.length s in
  let open Option.Let_syntax in
  let%bind tparams, i =
    if n > 0 && Char.equal s.[0] '<'
    then (
      let%map j = closing s 0 in
      split_top_level (String.sub s ~pos:1 ~len:(j - 1)), j + 1)
    else Some ([], 0)
  in
  if i < n && Char.equal s.[i] '('
  then (
    let%bind j = closing s i in
    let params = split_top_level (String.sub s ~pos:(i + 1) ~len:(j - i - 1)) in
    let rest = String.strip (String.drop_prefix s (j + 1)) in
    if String.equal rest ""
    then Some (tparams, params, None)
    else if Char.equal rest.[0] ':'
    then Some (tparams, params, Some (String.strip (String.drop_prefix rest 1)))
    else None)
  else None
;;

let code_arrow_type s =
  let open Option.Let_syntax in
  let%bind i = type_operator_index s ~operator:"=>" in
  let head = String.strip (String.prefix s i) in
  let result = String.strip (String.drop_prefix s (i + 2)) in
  match%bind code_signature head with
  | tparams, params, None -> Some (tparams, params, result)
  | _, _, Some _ -> None
;;

let code_parameters s =
  let name p =
    let p = String.chop_prefix_if_exists p ~prefix:"..." in
    match String.index p ':' with
    | Some i -> String.strip (String.prefix p i)
    | None -> String.strip p
  in
  match code_arrow s with
  | None -> []
  | Some (signature, _) ->
    (match code_signature signature with
     | Some (_, params, _) -> List.map params ~f:name
     | None -> if is_path signature then [ signature ] else [])
;;

let has_top_level_question s =
  let n = String.length s in
  scan s (fun c depth i ->
    Char.equal c '?'
    && depth = 0
    && (i + 1 >= n || (Char.( <> ) s.[i + 1] '.' && Char.( <> ) s.[i + 1] '?'))
    && (i = 0 || Char.( <> ) s.[i - 1] '?'))
;;

let negated = function
  | Code s when is_path s -> Code ("!" ^ s)
  | Code s ->
    let simple =
      not
        (has_top_level_token s "&&"
         || has_top_level_token s "||"
         || has_top_level_token s "??"
         || has_top_level_question s
         || has_top_level_comma s
         || has_top_level_arrow s
         || has_top_level_assignment s)
    in
    let flipped from to_ =
      match top_level_index s from with
      | Some i when simple ->
        let n = String.length s
        and k = String.length from in
        Some (Code (String.prefix s i ^ to_ ^ String.sub s ~pos:(i + k) ~len:(n - i - k)))
      | Some _ | None -> None
    in
    (match flipped "===" "!==", flipped "!==" "===" with
     | Some e, None | None, Some e -> e
     | Some _, Some _ | None, None -> Code ("!(" ^ s ^ ")"))
  | Equals (a, b) -> Not_equals (a, b)
  | Not_equals (a, b) -> Equals (a, b)
  | Not e -> e
  | e -> Not e
;;

let hole = "$0"

let with_scrutinee code s =
  let rec path = function
    | Var x -> x
    | Field (e, f) -> path e ^ "." ^ f
    | Index (e, k) -> path e ^ "[" ^ Int.to_string k ^ "]"
    | Cell_read (e, i) -> [%string "%{string_of_helper Read_cell}(%{path e}, %{i})"]
    | _ -> invalid_arg "Ts_print.with_scrutinee: the scrutinee is a path"
  in
  (* [path s] raises on a scrutinee that is not a path, so it runs only when
     [code] has a hole. *)
  let substituted () =
    Code
      (if String.is_substring code ~substring:hole
       then String.substr_replace_all code ~pattern:hole ~with_:(path s)
       else code)
  in
  match String.chop_prefix code ~prefix:hole with
  | None -> substituted ()
  | Some rest ->
    let digits d = (not (String.is_empty d)) && String.for_all d ~f:Char.is_digit in
    if String.is_empty rest
    then s
    else if
      is_enclosed rest '['
      && digits (String.sub rest ~pos:1 ~len:(String.length rest - 2))
    then Index (s, Int.of_string (String.sub rest ~pos:1 ~len:(String.length rest - 2)))
    else if Char.equal rest.[0] '.' && is_path (String.drop_prefix rest 1)
    then
      List.fold
        (String.split (String.drop_prefix rest 1) ~on:'.')
        ~init:s
        ~f:(fun e f -> Field (e, f))
    else substituted ()
;;

type code_body =
  | Hug
  | Conditional of string
  | Expression

let code_body b =
  let inner = strip_parens b in
  if
    Char.equal b.[0] '{'
    || Char.equal b.[0] '['
    || (String.( <> ) inner b && String.is_prefix inner ~prefix:"{")
  then Hug
  else if has_top_level_question inner
  then Conditional inner
  else Expression
;;

let is_call_text b =
  match String.index b '(' with
  | Some i when i > 0 ->
    is_path (String.prefix b i) && is_enclosed (String.drop_prefix b i) '('
  | _ -> false
;;

type kind =
  | Identifier
  | Member
  | Call_like
  | Arrow_function
  | Conditional
  | Binary
  | Object_literal
  | Array_literal
  | String_literal
  | Template_literal
  | Numeric_literal
  | Other_literal
  | Unary
  | Cast
  | Opaque
[@@deriving equal]

let code_kind s =
  match s with
  | "true" | "false" | "null" -> Other_literal
  | _ when Option.is_some (code_arrow s) -> Arrow_function
  | _ when is_path s -> if String.contains s '.' then Member else Identifier
  | _ when is_number s ->
    if Char.equal s.[String.length s - 1] 'n' then Other_literal else Numeric_literal
  | _ when is_signed_number s -> Unary
  | _ when is_string_literal s -> String_literal
  | _ when is_template_literal s -> Template_literal
  | _ when is_enclosed s '[' -> Array_literal
  | _ when is_enclosed s '{' -> Object_literal
  | _ -> Opaque
;;

let is_atom s =
  match code_kind s with
  | Identifier
  | Member
  | Numeric_literal
  | Other_literal
  | String_literal
  | Template_literal -> true
  | Call_like
  | Arrow_function
  | Conditional
  | Binary
  | Object_literal
  | Array_literal
  | Unary
  | Cast
  | Opaque -> false
;;

let kind = function
  | Var _ | Helper _ -> Identifier
  | Code s -> code_kind s
  | Text _ | Bytes _ -> String_literal
  | Bigint _ -> Other_literal
  | Number n when Char.equal n.[0] '-' -> Unary
  | Not _ -> Unary
  | Number "NaN" -> Member
  | Number "Infinity" -> Identifier
  | Number _ -> Numeric_literal
  | Field _ | Index _ -> Member
  | Tuple _ -> Array_literal
  | Call _ | Cell_read _ -> Call_like
  | Module_object _ | Satisfies _ -> Cast
  | Arrow _ -> Arrow_function
  | Cond _ -> Conditional
  | Equals _ | Not_equals _ | Add _ -> Binary
  | Record _ -> Object_literal
;;

let name_of = function
  | Var x | Code x -> x
  | Helper h -> string_of_helper h
  | Number n -> n
  | _ -> ""
;;

let numeric_or_boolean e =
  match kind e with
  | Numeric_literal -> true
  | Other_literal -> equal_expr e (Code "true") || equal_expr e (Code "false")
  | Identifier
  | Member
  | Call_like
  | Arrow_function
  | Conditional
  | Binary
  | Object_literal
  | Array_literal
  | String_literal
  | Template_literal
  | Unary
  | Cast
  | Opaque -> false
;;

let call_parts = function
  | Call (f, tys, xs) -> Some (f, tys, xs)
  | _ -> None
;;

type parent =
  | Return_argument
  | Initializer
  | Assigned
  | Property_value
  | Argument
  | Element
  | Callee of
      { top : bool
      ; args : int
      }
  | Member_object of { top : bool }
  | Test of parent
  | Consequent of parent
  | Alternate of parent
  | Operand
  | Arrow_body
  | Case_test
  | Discriminant
[@@deriving equal]

let is_top = function
  | Initializer | Assigned | Return_argument -> true
  | Callee { top; _ } | Member_object { top } -> top
  | Property_value
  | Argument
  | Element
  | Test _
  | Consequent _
  | Alternate _
  | Operand
  | Arrow_body
  | Case_test
  | Discriminant -> false
;;

type assignment =
  | Break_after_operator
  | Never_break_after_operator
  | Fluid
  | Break_lhs
[@@deriving equal]

type expand =
  | Expand_none
  | Expand_first
  | Expand_last
[@@deriving equal]

type args =
  { expand : expand
  ; assignment : assignment option
  ; decorated : bool
  }

let no_args = { expand = Expand_none; assignment = None; decorated = false }

type type_parent =
  | Arrow_return
  | Union_member
  | Type_argument
  | Array_element
  | Other_type
[@@deriving equal]

let raw_text segments =
  String.concat
    (List.map segments ~f:(function
       | Verbatim s -> s
       | Hole _ -> "T"))
;;

let type_code_needs_parens code ~parent =
  let has operator = Option.is_some (type_operator_index code ~operator) in
  match parent with
  | Arrow_return -> has "=>"
  | Union_member -> has "=>" || has "?"
  | Array_element ->
    has "=>" || has "?" || has "|" || has "&" || String.is_prefix code ~prefix:"readonly "
  | Type_argument | Other_type -> false
;;

(* Prettier's [isSimpleType] and [shouldHugType] for the types of [ty]. *)
let simple_type = function
  | Name (s, []) -> not (has_top_level_arrow s)
  | Raw [ Verbatim s ] -> is_path s
  | Name (_, _ :: _)
  | Literal _ | Fn _ | Union _ | Tuple _ | Conditional _ | Raw _ | Typeof _ | Indexed _ ->
    false
;;

let comma_line = Concat [ text ","; line ]
let trailing_comma = if_break (text ",") empty

let braces inner =
  Concat [ text "{"; indent (Concat [ hardline; inner ]); hardline; text "}" ]
;;

let rec type_ ?(inline = true) ~parent t =
  let doc =
    match t with
    | Name (n, []) ->
      (match code_arrow_type n with
       | Some (tparams, params, result) ->
         group
           (Concat
              [ type_parameters (unbounded tparams)
              ; parameter_list (List.map params ~f:text)
              ; text " => "
              ; text result
              ])
       | None -> text n)
    | Name (n, args) -> Concat [ text n; type_arguments ~inline args ]
    | Raw segments ->
      let rec go = function
        | [] -> []
        | Verbatim s :: rest -> text s :: go rest
        | Hole t :: (Verbatim s :: _ as rest) when String.is_prefix s ~prefix:"[]" ->
          type_ ~parent:Array_element t :: go rest
        | Hole t :: rest -> type_ ~parent:Type_argument t :: go rest
      in
      Concat (go segments)
    | Literal s -> text (string_literal s ~bytes:false)
    | Fn { tparams; params; result } ->
      group
        (Concat
           [ type_parameters tparams
           ; parameters params
           ; text " => "
           ; type_ ~parent:Other_type result
           ])
    | Union ts -> union ~parent ts
    | Conditional { check; extends; yes; no } -> group (conditional check extends yes no)
    | Tuple ts ->
      Concat
        [ text "readonly "
        ; group
            (Concat
               [ text "["
               ; indent
                   (Concat
                      [ softline
                      ; join
                          comma_line
                          (List.map ts ~f:(fun t -> group (type_ ~parent:Type_argument t)))
                      ])
               ; trailing_comma
               ; softline
               ; text "]"
               ])
        ]
    | Typeof (root, members) -> text ("typeof " ^ String.concat ~sep:"." (root :: members))
    | Indexed (t, key) ->
      Concat
        [ type_ ~parent:Array_element t
        ; text "["
        ; text (string_literal key ~bytes:false)
        ; text "]"
        ]
  in
  let parens =
    match parent, t with
    | Arrow_return, Fn _ | (Union_member | Array_element), (Fn _ | Union _ | Conditional _)
      -> true
    | Array_element, Tuple _ -> true
    | Array_element, Raw segments ->
      let code = raw_text segments in
      not (is_path code || String.is_prefix code ~prefix:"[")
    | _, Name (s, []) -> type_code_needs_parens s ~parent
    | _, Raw segments -> type_code_needs_parens (raw_text segments) ~parent
    | _ -> false
  in
  if parens then Concat [ text "("; doc; text ")" ] else doc

and type_arguments ?(inline = true) = function
  | [] -> empty
  | [ t ] when inline && simple_type t ->
    Concat [ text "<"; type_ ~parent:Type_argument t; text ">" ]
  | ts ->
    group
      (Concat
         [ text "<"
         ; indent
             (Concat
                [ softline
                ; join comma_line (List.map ts ~f:(type_ ~parent:Type_argument))
                ])
         ; softline
         ; text ">"
         ])

and conditional check extends yes no =
  let arm ~first (t : ty) =
    match t with
    | Conditional { check; extends; yes; no } when first ->
      Concat
        [ if_break empty (text "(")
        ; conditional check extends yes no
        ; if_break empty (text ")")
        ]
    | Conditional { check; extends; yes; no } -> conditional check extends yes no
    | t -> align 2 (type_ ~parent:Other_type t)
  in
  Concat
    [ type_ ~parent:Other_type check
    ; text " extends "
    ; type_ ~parent:Other_type extends
    ; indent
        (Concat
           [ line; text "? "; arm ~first:true yes; line; text ": "; arm ~first:false no ])
    ]

and type_parameters = function
  | [] -> empty
  | ps ->
    let param { name; bound } =
      match bound with
      | None -> text name
      | Some t ->
        let id = fresh_id () in
        Concat
          [ text name
          ; text " extends"
          ; group ~id (indent line)
          ; Indent_if_break { id; contents = type_ ~parent:Other_type t }
          ]
    in
    group
      (Concat
         [ text "<"
         ; indent (Concat [ softline; join comma_line (List.map ps ~f:param) ])
         ; trailing_comma
         ; softline
         ; text ">"
         ])

(* Oxfmt's union. Unlike Prettier's, the line break before the first [|]
   belongs to the union's own group, so a union that does not fit puts
   every member on its own line. *)
and union ~parent ts =
  let should_indent = not (equal_type_parent parent Type_argument) in
  let members =
    join
      (Concat [ line; text "| " ])
      (List.map ts ~f:(fun t -> align 2 (type_ ~parent:Union_member t)))
  in
  let content =
    group
      (Concat
         [ if_break (Concat [ (if should_indent then line else empty); text "| " ]) empty
         ; members
         ])
  in
  if should_indent then group (indent content) else group content

(* Prettier's [printFunctionParameters]. *)
and parameters ps =
  parameter_list
    (List.map ps ~f:(fun (x, t) ->
       Concat [ text x; text ": "; type_ ~parent:Other_type t ]))

and parameter_list = function
  | [] -> text "()"
  | ps ->
    Concat
      [ text "("; indent (Concat [ softline; join comma_line ps ]); softline; text ")" ]
;;

(* Prettier's [isSimpleCallArgument]. *)
let rec simple ?(depth = 2) e =
  depth > 0
  &&
  match e with
  | Var _ | Helper _ | Text _ | Bytes _ | Bigint _ | Number _ -> true
  | Code s ->
    (match code_kind s with
     | Identifier | Member | String_literal | Numeric_literal | Other_literal | Unary ->
       true
     | Template_literal ->
       List.for_all (template_holes s) ~f:(fun h -> is_atom (String.strip h))
     | Array_literal -> String.equal s "[]"
     | Call_like | Arrow_function | Conditional | Binary | Object_literal | Cast | Opaque
       -> false)
  | Record fields ->
    List.for_all fields ~f:(fun (k, v) ->
      (match v with
       | Var x -> String.equal x k
       | _ -> false)
      || simple ~depth:(depth - 1) v)
  | Field (o, _) | Index (o, _) | Cell_read (o, _) | Not o -> simple ~depth o
  | Tuple es -> List.for_all es ~f:(simple ~depth:(depth - 1))
  | Call (f, _, xs) ->
    simple ~depth f
    && List.length xs <= depth
    && List.for_all xs ~f:(simple ~depth:(depth - 1))
  | Arrow _ | Cond _ | Equals _ | Not_equals _ | Add _ | Module_object _ | Satisfies _ ->
    false
;;

(* Prettier's [isNumericLiteral] or [isSignedNumericLiteral], which hold of
   a number and its negation, not of [NaN] or [Infinity], which are
   identifiers. *)
let numeric e =
  match e with
  | Number n ->
    String.( <> ) n "NaN" && String.( <> ) n "Infinity" && String.( <> ) n "-Infinity"
  | Code s -> is_number s || is_signed_number s
  | _ -> false
;;

(* Prettier's [isConciselyPrintedArray]. *)
let concise = function
  | Tuple (_ :: _ as es) -> List.for_all es ~f:numeric
  | _ -> false
;;

(* Prettier's [isLoneShortArgument]. *)
let rec lone_short e =
  let threshold = print_width / 4 in
  match e with
  | (Var x | Code x) when equal_kind (kind e) Identifier -> width x <= threshold
  | Helper h -> width (string_of_helper h) <= threshold
  | Number "Infinity" -> true
  | Not e -> lone_short e
  | Text s -> width (string_literal s ~bytes:false) <= threshold
  | Bytes s -> width (string_literal s ~bytes:true) <= threshold
  | Code s when equal_kind (kind e) String_literal -> width s <= threshold
  | Code s when equal_kind (kind e) Template_literal ->
    List.is_empty (template_holes s) && width s <= threshold
  | Call (f, _, []) when equal_kind (kind f) Identifier ->
    width (name_of f) <= threshold - 2
  | e ->
    (match kind e with
     | Numeric_literal | Other_literal | Unary -> true
     | _ -> false)
;;

type link =
  | Head of expr
  | Access of string
  | Element of int
  | Invoke of ty list * expr list

let rec links acc e =
  match e with
  | Call (((Field _ | Index _ | Call _) as f), tys, xs) ->
    links (Invoke (tys, xs) :: acc) f
  | Field (o, f) -> links (Access f :: acc) o
  | Index (o, k) -> links (Element k :: acc) o
  | head -> Head head :: acc
;;

let is_memberish = function
  | Access _ | Element _ -> true
  | Head _ | Invoke _ -> false
;;

let is_invoke = function
  | Invoke _ -> true
  | Head _ | Access _ | Element _ -> false
;;

(* The groups of Prettier's [printMemberChain]. *)
let chain_groups ls =
  let head_is_call =
    match ls with
    | Head h :: _ -> equal_kind (kind h) Call_like
    | _ -> false
  in
  let rec leading acc = function
    | ((Invoke _ | Element _) as l) :: rest -> leading (l :: acc) rest
    | rest -> acc, rest
  in
  let rec accesses acc = function
    | a :: (b :: _ as rest) when is_memberish a && is_memberish b ->
      accesses (a :: acc) rest
    | rest -> acc, rest
  in
  let first, rest =
    match ls with
    | [] -> [], []
    | l :: rest ->
      let acc, rest = leading [ l ] rest in
      if head_is_call then acc, rest else accesses acc rest
  in
  let rec split current seen_call acc = function
    | [] -> List.rev (if List.is_empty current then acc else List.rev current :: acc)
    | l :: rest ->
      (match l with
       | Access _ when seen_call -> split [ l ] false (List.rev current :: acc) rest
       | Access _ | Element _ | Head _ | Invoke _ ->
         split (l :: current) (seen_call || is_invoke l) acc rest)
  in
  List.rev first :: split [] false [] rest
;;

let is_factory name =
  (not (String.is_empty name))
  && (Char.is_uppercase name.[0]
      || String.for_all name ~f:(fun c -> Char.equal c '$' || Char.equal c '_'))
;;

let should_merge groups =
  match groups with
  | [ Head h ] :: _ :: _ -> equal_kind (kind h) Identifier && is_factory (name_of h)
  | first :: _ :: _ ->
    (match List.last_exn first with
     | Access f -> is_factory f
     | Head _ | Element _ | Invoke _ -> false)
  | _ -> false
;;

let cutoff groups = if should_merge groups then 3 else 2

let rec member_chain e =
  match e with
  | Call ((Field _ | Index _), _, _) ->
    let groups = chain_groups (links [] e) in
    List.length groups > cutoff groups
  | Field (o, _) | Index (o, _) -> member_chain o
  | _ -> false
;;

let is_call e = equal_kind (kind e) Call_like

let call_args e =
  match call_parts e with
  | Some (_, _, xs) -> xs
  | None -> []
;;

(* Prettier's [isPoorlyBreakableMemberOrCallChain]. *)
let rec poorly_breakable e ~deep =
  match call_parts e with
  | Some (f, tys, xs) ->
    (not (member_chain e))
    && (match xs with
        | [] -> true
        | [ x ] -> lone_short x
        | _ -> false)
    && (match tys with
        | [] -> true
        | [ Union _ ] -> false
        | [ _ ] -> true
        | _ -> false)
    && poorly_breakable f ~deep:true
  | None ->
    (match e with
     | Field (o, _) | Index (o, _) -> poorly_breakable o ~deep:true
     | e when equal_kind (kind e) Member -> true
     | e -> deep && equal_kind (kind e) Identifier)
;;

let rec member_expression_chain = function
  | Field (o, _) | Index (o, _) ->
    equal_kind (kind o) Identifier || member_expression_chain o
  | e -> equal_kind (kind e) Member
;;

let break_after_operator e ~short_key =
  match e with
  | Equals _ | Not_equals _ -> true
  | Cond ((Equals _ | Not_equals _), _, _) -> true
  | _ when short_key -> false
  | Number n when Char.equal n.[0] '-' -> false
  | Not e -> equal_kind (kind e) String_literal || member_expression_chain e
  | e -> equal_kind (kind e) String_literal || poorly_breakable e ~deep:false
;;

(* Prettier's [couldExpandArg]. *)
let rec could_expand ?(chain = false) = function
  | Record (_ :: _) | Module_object (_ :: _) | Tuple (_ :: _) -> true
  | Code s when equal_kind (code_kind s) Array_literal -> String.( <> ) s "[]"
  | Code s when equal_kind (code_kind s) Object_literal -> String.( <> ) s "{}"
  | Code s when equal_kind (code_kind s) Arrow_function ->
    (match code_arrow s with
     | Some (_, body) ->
       (match code_body body with
        | Hug -> true
        | Conditional _ -> not chain
        | Expression -> (not chain) && is_call_text body)
     | None -> false)
  | Arrow (_, _, _, Block _) -> true
  | Arrow (_, _, _, Expr b) ->
    (match b with
     | Record _ | Tuple _ -> true
     | Code s
       when equal_kind (code_kind s) Array_literal
            || equal_kind (code_kind s) Object_literal -> true
     | (Arrow _ | Code _) when could_expand ~chain:true b -> true
     | Cond _ when not chain -> true
     | b -> (not chain) && is_call b)
  | _ -> false
;;

let is_arrow e = equal_kind (kind e) Arrow_function

let block_bodied = function
  | Arrow (_, _, _, Block _) -> true
  | Code s -> Option.exists (code_arrow s) ~f:(fun (_, body) -> Char.equal body.[0] '{')
  | _ -> false
;;

(* Prettier's [isFunctionCompositionArguments]. *)
let function_composition xs =
  List.length xs > 1
  && (List.count xs ~f:is_arrow > 1
      || List.exists xs ~f:(fun x -> is_call x && List.exists (call_args x) ~f:is_arrow))
;;

(* Prettier's [isHopefullyShortCallArgument]. *)
let hopefully_short = function
  | e when is_call e && List.length (call_args e) > 1 -> false
  | Equals (a, b) | Not_equals (a, b) -> simple ~depth:1 a && simple ~depth:1 b
  | e -> simple e
;;

let needs_parens parent e =
  match e, parent with
  | (Arrow _ | Cond _), (Callee _ | Member_object _ | Test _ | Operand) -> true
  | (Equals _ | Not_equals _ | Add _), (Callee _ | Member_object _ | Operand) -> true
  | Not _, (Callee _ | Member_object _) -> true
  | Number n, (Callee _ | Member_object _) -> Char.equal n.[0] '-'
  | Module_object _, (Callee _ | Member_object _ | Arrow_body | Operand) -> true
  | ( Satisfies _
    , (Callee _ | Member_object _ | Operand | Test _ | Consequent _ | Alternate _) ) ->
    true
  | Record _, Arrow_body -> true
  | Code s, (Callee _ | Member_object _) ->
    equal_kind (kind e) Arrow_function || not (atomic_code s)
  | Code s, Operand ->
    equal_kind (kind e) Arrow_function || not (atomic_code s || is_signed_number s)
  | Code s, Test _ ->
    equal_kind (kind e) Arrow_function
    || has_top_level_question s
    || has_top_level_comma s
    || has_top_level_assignment s
  | Code _, _ when equal_kind (kind e) Arrow_function -> false
  | Code s, Arrow_body -> String.is_prefix s ~prefix:"{" || has_top_level_comma s
  | Code s, _ -> has_top_level_comma s
  | _ -> false
;;

let rec ends_in_block = function
  | Arrow (_, _, _, Block _) -> true
  | Arrow (_, _, _, Expr e) -> (not (needs_parens Arrow_body e)) && ends_in_block e
  | Cond (_, _, e) -> ends_in_block e
  | Code _ as e -> block_bodied e
  | _ -> false
;;

let closes_block = function
  | Const (_, _, e) | Variable (_, e) | Assign (_, e) | Return e -> ends_in_block e
  | Bind _ | Let _ | Cell_write _ | Eval _ | Bump _ | Break | Continue -> false
  | Switch _ | If _ | Loop _ | While _ -> true
;;

(* The primitive type that a literal has, which typescript-eslint's
   no-inferrable-types reads off it, as [-1] has [number] and a negation
   has [boolean] whatever its operand. A const whose annotation is that
   type keyword goes without it. *)
let literal_type : expr -> string option = function
  | Text _ | Bytes _ -> Some "string"
  | Bigint _ -> Some "bigint"
  | Number _ -> Some "number"
  | Not _ -> Some "boolean"
  | Code ("true" | "false") -> Some "boolean"
  | Code s when String.is_prefix s ~prefix:"!" -> Some "boolean"
  | Code "null" -> Some "null"
  | Code "undefined" -> Some "undefined"
  | Code ("NaN" | "Infinity" | "-NaN" | "-Infinity") -> Some "number"
  | Code s when is_number s || is_signed_number s ->
    Some (if Char.equal s.[String.length s - 1] 'n' then "bigint" else "number")
  | Code s when is_string_literal s || is_template_literal s -> Some "string"
  | _ -> None
;;

let should_group_first = function
  | [ first; second ] ->
    block_bodied first
    && (match second with
        | Arrow _ | Cond _ -> false
        | _ -> true)
    && hopefully_short second
    && not (could_expand second)
  | _ -> false
;;

let should_group_last xs =
  let n = List.length xs in
  let last_arg = List.last_exn xs in
  let penultimate = List.nth xs (n - 2) in
  could_expand last_arg
  && Option.for_all penultimate ~f:(fun p -> not (equal_kind (kind p) (kind last_arg)))
  && (not
        (n = 2
         && Option.exists penultimate ~f:is_arrow
         && equal_kind (kind last_arg) Array_literal))
  && not (n > 1 && concise last_arg)
;;

let all_broken_out printed =
  group
    ~should_break:true
    (Concat [ text "("; indent (Concat (line :: printed)); line; text ")" ])
;;

let hug_first ~first ~tail ~all =
  let hugged =
    Concat
      ((text "(" :: group ~should_break:true first :: text ", " :: tail) @ [ text ")" ])
  in
  if will_break first
  then Concat [ Break_parent; conditional_group [ hugged; all ] ]
  else
    conditional_group
      [ Concat ((text "(" :: first :: text ", " :: tail) @ [ text ")" ]); hugged; all ]
;;

let hug_last ~head ~last ~all =
  if will_break last
  then
    Concat
      [ Break_parent
      ; conditional_group
          [ Concat ((text "(" :: head) @ [ group ~should_break:true last; text ")" ])
          ; all
          ]
      ]
  else
    conditional_group
      [ Concat ((text "(" :: head) @ [ last; text ")" ])
      ; Concat ((text "(" :: head) @ [ group ~should_break:true last; text ")" ])
      ; all
      ]
;;

let rec regroup docs = function
  | [] -> []
  | g :: gs ->
    let mine, rest = List.split_n docs (List.length g) in
    Concat mine :: regroup rest gs
;;

(* Prettier's reasons in [printMemberChain] to break a chain whose groups
   would fit on one line. *)
let chain_must_break ls printed_groups =
  let calls =
    (match ls with
     | Head h :: _ when is_call h -> [ call_args h ]
     | _ -> [])
    @ List.filter_map ls ~f:(function
      | Invoke (_, xs) -> Some xs
      | Head _ | Access _ | Element _ -> None)
  in
  let last_group_breaks =
    is_invoke (List.last_exn ls)
    && will_break (List.last_exn printed_groups)
    && List.exists (List.drop_last_exn calls) ~f:(List.exists ~f:is_arrow)
  in
  (List.length calls > 2
   && List.exists calls ~f:(List.exists ~f:(fun x -> not (simple x))))
  || List.exists (List.drop_last_exn printed_groups) ~f:will_break
  || last_group_breaks
;;

let arrow_head tps ps result =
  let return_doc =
    Option.value_map result ~default:empty ~f:(fun t ->
      Concat [ text ": "; type_ ~parent:Arrow_return t ])
  in
  ( group (Concat [ type_parameters tps; parameters ps; return_doc ])
  , (not (List.is_empty tps)) || (Option.is_some result && not (List.is_empty ps)) )
;;

let code_head signature =
  match code_signature signature with
  | Some (tparams, params, result) ->
    ( group
        (Concat
           [ type_parameters (unbounded tparams)
           ; parameter_list (List.map params ~f:text)
           ; Option.value_map result ~default:empty ~f:(fun t -> text (": " ^ t))
           ])
    , (not (List.is_empty tparams))
      || (Option.is_some result && not (List.is_empty params)) )
  | None -> text signature, false
;;

let chain_links tps ps result body =
  let rec collect acc tps ps result body =
    let acc = arrow_head tps ps result :: acc in
    match body with
    | Expr (Arrow (tps, ps, result, body)) -> collect acc tps ps result body
    | Expr (Code s) ->
      (match code_arrow s with
       | Some (signature, b) -> List.rev (code_head signature :: acc), `Code b
       | None -> List.rev acc, `Expr (Code s))
    | Expr e -> List.rev acc, `Expr e
    | Block ss -> List.rev acc, `Block ss
  in
  collect [] tps ps result body
;;

let hugged_head head ~args =
  if (not (equal_expand args.expand Expand_none)) && not args.decorated
  then remove_lines head
  else head
;;

let chain_signatures links ~args ~initial_indent =
  let n = List.length links in
  let signature i (h, _) =
    let s =
      if not (equal_expand args.expand Expand_none)
      then if i = 0 then hugged_head h ~args else Concat [ text " "; remove_lines h ]
      else Concat [ (if i = 0 then empty else line); h ]
    in
    let s = if i = 0 || initial_indent then s else indent s in
    if i = n - 1 then s else Concat [ s; text " =>" ]
  in
  group ~should_break:(List.exists links ~f:snd) (Concat (List.mapi links ~f:signature))
;;

let rec code_literal s =
  let trimmed = String.strip s in
  let wrapped, body =
    if String.length trimmed >= 2 && Char.equal trimmed.[0] '(' && is_enclosed trimmed '('
    then true, String.strip (String.sub trimmed ~pos:1 ~len:(String.length trimmed - 2))
    else false, trimmed
  in
  if
    String.length body >= 2
    && (Char.equal body.[0] '[' || Char.equal body.[0] '{')
    && is_enclosed body body.[0]
  then (
    let inner = String.strip (String.sub body ~pos:1 ~len:(String.length body - 2)) in
    let parts = List.filter (split_top_level inner) ~f:(fun p -> String.( <> ) p "") in
    let doc =
      match parts with
      | [] -> text (if Char.equal body.[0] '[' then "[]" else "{}")
      | parts ->
        let id = fresh_id () in
        let gap = if Char.equal body.[0] '[' then softline else line in
        let printed =
          List.mapi parts ~f:(fun i p ->
            let d = Option.value (code_literal p) ~default:(text p) in
            if i = List.length parts - 1 then d else Concat [ d; comma_line ])
        in
        group
          ~id
          (Concat
             [ text (String.make 1 body.[0])
             ; indent (Concat [ gap; Concat printed; trailing_comma ])
             ; gap
             ; text (if Char.equal body.[0] '[' then "]" else "}")
             ])
    in
    Some
      (if wrapped && Char.equal body.[0] '{'
       then Concat [ text "("; doc; text ")" ]
       else doc))
  else None
;;

let code_doc s = Option.value (code_literal s) ~default:(text s)

let hug_doc s =
  let trimmed = String.strip s in
  if String.is_prefix trimmed ~prefix:"{" then text s else code_doc s
;;

let rec expr ?(args = no_args) ~parent e =
  let doc =
    match e with
    | Code s when equal_kind (kind e) Arrow_function -> code_arrow_doc ~args s
    | Code s -> code_doc s
    | Var x -> text x
    | Helper h -> text (string_of_helper h)
    | Text s -> text (string_literal s ~bytes:false)
    | Bytes s -> text (string_literal s ~bytes:true)
    | Bigint d -> text (grouped d ^ "n")
    | Number n -> text (number n)
    | Field (o, f) -> member ~parent o f
    | Index (o, k) ->
      Concat
        [ expr ~parent:(Member_object { top = is_top parent }) o
        ; text (Printf.sprintf "[%d]" k)
        ]
    | Cell_read (o, i) -> call ~parent (Helper Read_cell) [] [ o; Var i ]
    | Tuple es -> array es
    | Call (f, tys, xs) -> call ~parent f tys xs
    | Module_object fields -> Concat [ object_ ~expanded:true fields; text " as const" ]
    | Satisfies (e, t) ->
      Concat [ expr ~parent:Operand e; text " satisfies "; type_ ~parent:Other_type t ]
    | Arrow (tps, ps, r, b) -> arrow ~parent ~args tps ps r b
    | Cond (c, a, b) -> conditional ~parent c a b
    | Equals (a, b) -> binary ~parent "===" a b
    | Not_equals (a, b) -> binary ~parent "!==" a b
    | Add (a, b) -> binary ~parent "+" a b
    | Not e -> Concat [ text "!"; expr ~parent:Operand e ]
    | Record fields -> object_ ~expanded:false fields
  in
  if needs_parens parent e then Concat [ text "("; doc; text ")" ] else doc

and code_arrow_doc ~args s =
  match code_arrow s with
  | None -> text s
  | Some (signature, body) ->
    let signature =
      Concat [ hugged_head (fst (code_head signature)) ~args; text " =>" ]
    in
    (match code_body body with
     | Hug -> Concat [ signature; text " "; hug_doc body ]
     | Conditional inner ->
       Concat [ signature; moved_body ~args (if_flat_parens (text inner)) ]
     | Expression -> Concat [ signature; moved_body ~args (text body) ])

(* Prettier's [printMemberExpression]. *)
and member ~parent o f =
  let lookup = text ("." ^ f) in
  let inline =
    (equal_kind (kind o) Identifier
     &&
     match parent with
     | Member_object _ -> false
     | _ -> true)
    || ((equal_parent parent Initializer || equal_parent parent Assigned)
        && ((is_call o && not (List.is_empty (call_args o))) || member_chain o))
  in
  Concat
    [ expr ~parent:(Member_object { top = is_top parent }) o
    ; (if inline then lookup else group (indent (Concat [ softline; lookup ])))
    ]

(* Prettier's [printArray]. *)
and array es =
  match es with
  | [] -> text "[]"
  | es ->
    let items es = List.length es > 1 in
    let should_break =
      items es
      && (List.for_all es ~f:(function
            | Record fields -> items fields
            | _ -> false)
          || List.for_all es ~f:(function
            | Tuple es -> items es
            | _ -> false))
    in
    let printed = List.map es ~f:(fun e -> group (expr ~parent:Element e)) in
    let id = fresh_id () in
    let contents =
      if concise (Tuple es)
      then (
        let n = List.length printed in
        Fill
          (List.concat_mapi printed ~f:(fun i d ->
             if i = n - 1
             then [ Concat [ d; if_break ~id (text ",") empty ] ]
             else [ Concat [ d; text "," ]; line ])))
      else Concat [ join comma_line printed; trailing_comma ]
    in
    group
      ~should_break
      ~id
      (Concat [ text "["; indent (Concat [ softline; contents ]); softline; text "]" ])

(* Prettier's [printCallExpression]. *)
and call ~parent f tys xs =
  match f with
  | Field _ | Index _ -> member_chain_doc ~parent (Call (f, tys, xs))
  | _ ->
    let contents =
      Concat
        [ expr ~parent:(Callee { top = is_top parent; args = List.length xs }) f
        ; type_arguments tys
        ; arguments
            ~curried:(curried parent (List.length xs))
            ~decorated:(decorated parent f xs)
            xs
        ]
    in
    if is_call f then group contents else contents

(* Prettier's [isDecoratedFunction], which holds of the sole block-bodied
   arrow argument of a call of a call of a name, as a [const] initializer. *)
and decorated parent f xs =
  equal_parent parent Initializer
  && (match xs with
      | [ x ] -> block_bodied x
      | _ -> false)
  &&
  match f with
  | Call (g, _, _) ->
    equal_kind (kind g) Identifier
    ||
      (match g with
      | Field (o, _) -> equal_kind (kind o) Identifier
      | _ -> false)
  | _ -> false

(* Prettier's [isLongCurriedCallExpression], which holds of the callee of a
   call with fewer arguments. *)
and curried parent n =
  match parent with
  | Callee { args; _ } -> args > 0 && n > args
  | _ -> false

(* Prettier's [printMemberChain]. *)
and member_chain_doc ~parent e =
  let ls = links [] e in
  let printed = link_docs ~parent ls in
  let groups = chain_groups ls in
  let printed_groups = regroup printed groups in
  let one_line = Concat printed_groups in
  if List.length groups <= cutoff groups
  then if curried parent (List.length (call_args e)) then one_line else group one_line
  else (
    let first, rest =
      match printed_groups with
      | g :: h :: rest when should_merge groups -> Concat [ g; h ], rest
      | g :: rest -> g, rest
      | [] -> empty, []
    in
    let expanded = Concat [ first; indent (Concat [ hardline; join hardline rest ]) ] in
    if chain_must_break ls printed_groups
    then group expanded
    else
      Concat
        [ (if will_break one_line then Break_parent else empty)
        ; conditional_group [ one_line; expanded ]
        ])

and link_docs ~parent = function
  | [] -> []
  | Head h :: rest ->
    let p =
      match rest with
      | Invoke (_, xs) :: _ -> Callee { top = is_top parent; args = List.length xs }
      | _ -> Member_object { top = is_top parent }
    in
    expr ~parent:p h :: link_docs ~parent rest
  | Access f :: rest -> text ("." ^ f) :: link_docs ~parent rest
  | Element k :: rest -> text (Printf.sprintf "[%d]" k) :: link_docs ~parent rest
  | Invoke (tys, xs) :: rest ->
    let curried =
      match rest with
      | Invoke (_, ys) :: _ ->
        let n = List.length ys in
        n > 0 && List.length xs > n
      | [] -> curried parent (List.length xs)
      | _ -> false
    in
    Concat [ type_arguments tys; arguments ~curried ~decorated:false xs ]
    :: link_docs ~parent rest

(* Prettier's [printCallArguments]. *)
and arguments ~curried ~decorated xs =
  match xs with
  | [] -> text "()"
  | xs ->
    let n = List.length xs in
    let printed =
      List.mapi xs ~f:(fun i x ->
        let d = expr ~parent:Argument x in
        if i = n - 1 then d else Concat [ d; comma_line ])
    in
    let all = all_broken_out printed in
    if function_composition xs
    then all
    else if should_group_first xs
    then (
      let tail = List.tl_exn printed in
      if List.exists tail ~f:will_break
      then all
      else (
        let first_doc =
          expr
            ~args:{ no_args with expand = Expand_first }
            ~parent:Argument
            (List.hd_exn xs)
        in
        hug_first ~first:first_doc ~tail ~all))
    else if should_group_last xs
    then (
      let head = List.drop_last_exn printed in
      if List.exists head ~f:will_break
      then all
      else (
        let last_doc =
          expr
            ~args:{ no_args with expand = Expand_last; decorated }
            ~parent:Argument
            (List.last_exn xs)
        in
        hug_last ~head ~last:last_doc ~all))
    else (
      let contents =
        Concat [ text "("; indent (Concat (softline :: printed)); softline; text ")" ]
      in
      if curried
      then contents
      else group ~should_break:(List.exists printed ~f:will_break) contents)

and arrow ~parent ~args tps ps result body =
  let chain =
    (not (equal_expand args.expand Expand_first))
    &&
    match body with
    | Expr e -> is_arrow e
    | Block _ -> false
  in
  if chain
  then arrow_chain ~parent ~args tps ps result body
  else (
    let signature =
      Concat [ hugged_head (fst (arrow_head tps ps result)) ~args; text " =>" ]
    in
    match body with
    | Block ss -> Concat [ signature; text " "; block ss ]
    | Expr e
      when is_arrow e
           || equal_kind (kind e) Object_literal
           || equal_kind (kind e) Array_literal ->
      Concat [ signature; text " "; expr ~parent:Arrow_body e ]
    | Expr e ->
      Concat [ signature; moved_body ~args (parenthesised e (expr ~parent:Arrow_body e)) ])

and arrow_chain ~parent ~args tps ps result body =
  let grouped = not (equal_expand args.expand Expand_none) in
  let links, tail = chain_links tps ps result body in
  let is_callee =
    match parent with
    | Callee _ -> true
    | _ -> false
  in
  let separate_line, tail_inner =
    match tail with
    | `Block ss -> false, block ss
    | `Expr e ->
      ( not (equal_kind (kind e) Object_literal || equal_kind (kind e) Array_literal)
      , parenthesised e (expr ~parent:Arrow_body e) )
    | `Code b ->
      (match code_body b with
       | Hug -> false, hug_doc b
       | Conditional inner -> true, if_flat_parens (text inner)
       | Expression -> true, text b)
  in
  let initial_indent =
    is_callee
    || Option.exists args.assignment ~f:(fun layout ->
      not (equal_assignment layout Break_after_operator))
  in
  let signatures = chain_signatures links ~args ~initial_indent in
  let id = fresh_id () in
  let tail_body =
    if separate_line
    then indent (Concat [ line; tail_inner ])
    else Concat [ text " "; tail_inner ]
  in
  group
    (Concat
       [ group
           ~should_break:(is_callee && separate_line)
           ~id
           (if initial_indent
            then indent (Concat [ softline; signatures ])
            else signatures)
       ; text " =>"
       ; (if grouped
          then group tail_body
          else Indent_if_break { id; contents = tail_body })
       ; (if is_callee then if_break ~id softline empty else empty)
       ])

and moved_body ~args d =
  let last = equal_expand args.expand Expand_last in
  group (Concat [ indent (Concat [ line; d ]); (if last then softline else empty) ])

and parenthesised e d =
  match e with
  | Cond _ -> if_flat_parens d
  | _ -> d

and if_flat_parens d = Concat [ if_break empty (text "("); d; if_break empty (text ")") ]

(* Prettier's [printTernaryOld]. *)
and conditional ~parent c a b =
  let in_branch, is_alternate =
    match parent with
    | Consequent _ -> true, false
    | Alternate _ -> true, true
    | _ -> false, false
  in
  let is_test =
    match parent with
    | Test _ -> true
    | _ -> false
  in
  let nested =
    match a with
    | Cond _ -> true
    | _ -> false
  in
  let part =
    Concat
      [ line
      ; text "? "
      ; (if nested then if_break empty (text "(") else empty)
      ; align 2 (expr ~parent:(Consequent parent) a)
      ; (if nested then if_break empty (text ")") else empty)
      ; line
      ; text ": "
      ; align 2 (expr ~parent:(Alternate parent) b)
      ]
  in
  let parts = if in_branch && not is_alternate then align 0 part else part in
  let test_doc = expr ~parent:(Test parent) c in
  let test_doc = if is_alternate then align 2 test_doc else test_doc in
  let extra =
    match parent with
    | Callee { top; _ } | Member_object { top } -> top
    | _ -> false
  in
  let break_closing =
    match parent with
    | Member_object _ -> not extra
    | _ -> false
  in
  let contents =
    Concat
      [ test_doc
      ; (if in_branch then parts else indent parts)
      ; (if break_closing then softline else empty)
      ]
  in
  let result = if in_branch then contents else group contents in
  if is_test || extra
  then group (Concat [ indent (Concat [ softline; result ]); softline ])
  else result

(* Prettier's [printBinaryishExpression] for [===], [!==], and [+]. *)
and binary ~parent op a b =
  let is_equals = function
    | Equals _ | Not_equals _ -> true
    | _ -> false
  in
  let right = Concat [ text op; line; expr ~parent:Operand b ] in
  let right =
    if equal_parent parent Operand || is_equals a || is_equals b
    then right
    else group right
  in
  let left = group (expr ~parent:Operand a) in
  let call_or_return = function
    | Return_argument | Argument | Callee _ -> true
    | _ -> false
  in
  match parent with
  | Callee _ | Member_object _ ->
    group (Concat [ indent (Concat [ softline; left; text " "; right ]); softline ])
  | Discriminant -> Concat [ left; text " "; right ]
  | Return_argument | Arrow_body | Initializer | Assigned | Property_value ->
    group (Concat [ left; text " "; right ])
  | (Test p | Consequent p | Alternate p) when not (call_or_return p) ->
    group (Concat [ left; text " "; right ])
  | _ -> group (Concat [ left; indent (Concat [ text " "; right ]) ])

(* Prettier's [printObject], which gives a pattern that a declarator
   binds no group of its own, so that it breaks whenever the declarator
   does. *)
and object_ ?(grouped = true) ~expanded fields =
  match List.stable_sort fields ~compare:(fun (a, _) (b, _) -> String.compare a b) with
  | [] -> text "{}"
  | fields ->
    let field (k, v) =
      match v with
      | Var x when String.equal x k -> text k
      | v ->
        let short_key = width k < 5 in
        let layout =
          if break_after_operator v ~short_key
          then Break_after_operator
          else if
            short_key || numeric_or_boolean v || equal_kind (kind v) Template_literal
          then Never_break_after_operator
          else Fluid
        in
        assignment
          layout
          ~left:(text k)
          ~op:":"
          (match v with
           | Module_object fields -> object_ ~expanded:true fields
           | v ->
             expr ~args:{ no_args with assignment = Some layout } ~parent:Property_value v)
    in
    let body =
      Concat
        [ text "{"
        ; indent (Concat [ line; join comma_line (List.map fields ~f:field) ])
        ; trailing_comma
        ; line
        ; text "}"
        ]
    in
    if grouped then group ~should_break:expanded body else body

(* Prettier's [printAssignment]. *)
and assignment layout ~left ~op right =
  match layout with
  | Break_after_operator ->
    group (Concat [ group left; text op; group (indent (Concat [ line; right ])) ])
  | Never_break_after_operator -> group (Concat [ group left; text op; text " "; right ])
  | Fluid ->
    let id = fresh_id () in
    group
      (Concat
         [ group left
         ; text op
         ; group ~id (indent line)
         ; Indent_if_break { id; contents = right }
         ])
  | Break_lhs -> group (Concat [ left; text op; text " "; group right ])

(* A [const] declarator, with Prettier's [chooseLayout]. *)
and declarator name ty init =
  let left =
    match ty with
    | None -> text name
    | Some t ->
      Concat
        [ text name; text ": "; type_ ~inline:(not (is_arrow init)) ~parent:Other_type t ]
  in
  let complex_annotation =
    match ty with
    | Some (Name (_, (_ :: _ :: _ as args))) ->
      List.exists args ~f:(function
        | Name (_, _ :: _) | Conditional _ -> true
        | _ -> false)
    | _ -> false
  in
  let long_tuple =
    match ty with
    | Some (Tuple _ as t) ->
      let doc = type_ ~inline:(not (is_arrow init)) ~parent:Other_type t in
      not (fits (Hashtbl.create (module Int) ~size:0) (Flat, doc) [] print_width)
    | _ -> false
  in
  binding ~left ~break_lhs:(complex_annotation || long_tuple) init

(* Prettier's [chooseLayout] for a declarator, or for an assignment when
   [parent] is [Assigned], where [break_lhs] holds of a complex type
   annotation, a tuple annotation that does not fit the print width, or a
   complex destructuring target. That tuple breaks inside itself before
   the initialiser moves, which is where oxfmt breaks one whose text
   alone passes the print width. *)
and binding ?(parent = Initializer) ~left ~break_lhs init =
  let layout =
    if break_lhs || (is_arrow init && can_break left)
    then Break_lhs
    else if break_after_operator init ~short_key:false
    then Break_after_operator
    else if
      (not (can_break left))
      && (numeric_or_boolean init || equal_kind (kind init) Template_literal)
    then Never_break_after_operator
    else Fluid
  in
  assignment
    layout
    ~left
    ~op:" ="
    (expr ~args:{ no_args with assignment = Some layout } ~parent init)

and block = function
  | [] -> text "{}"
  | ss -> braces (statements ss)

and statements ss =
  Statements
    (List.map ss ~f:(fun s ->
       { role =
           (match s with
            | Const _ | Bind _ | Let _ | Variable _ -> Binding
            | Return _ | Switch _ | If _ | Loop _ | While _ -> Keyword
            | Assign _ | Cell_write _ | Eval _ | Bump _ | Break | Continue -> Plain)
       ; block_like = closes_block s
       ; doc = statement s
       }))

(* [[, target] = e;], the element [k] of [e] assigned to [target] by a
   destructuring, as prefer-destructuring asks of a read at a literal
   index. *)
and element_assignment target e k =
  let holes = String.concat (List.init k ~f:(fun _ -> ", ")) in
  group
    (Concat
       [ binding
           ~parent:Assigned
           ~left:(text ("[" ^ holes ^ target ^ "]"))
           ~break_lhs:false
           e
       ; text ";"
       ])

and statement = function
  | Const (x, t, e) ->
    let t =
      match t, literal_type e with
      | Some (Name (k, [])), Some k' when String.equal k k' -> None
      | _ -> t
    in
    group (Concat [ text "const "; declarator x t e; text ";" ])
  | Bind (fields, source) -> destructuring fields source
  | Let (x, t) ->
    group
      (Concat [ text "let "; text x; text ": "; type_ ~parent:Other_type t; text ";" ])
  | Variable (x, e) ->
    group
      (Concat
         [ text "let "
         ; binding ~parent:Assigned ~left:(text x) ~break_lhs:false e
         ; text ";"
         ])
  | Assign (x, Index (e, k)) -> element_assignment x e k
  | Assign (x, Add (Var y, e)) when String.equal x y ->
    group
      (Concat
         [ assignment Fluid ~left:(text x) ~op:" +=" (expr ~parent:Assigned e); text ";" ])
  | Assign (x, e) ->
    group
      (Concat [ binding ~parent:Assigned ~left:(text x) ~break_lhs:false e; text ";" ])
  | Cell_write (a, i, e) ->
    statement (Eval (Call (Helper Write_cell, [], [ Var a; Var i; e ])))
  | Eval e ->
    Concat
      [ (if is_call e then empty else text "void "); expr ~parent:Operand e; text ";" ]
  | Bump (x, n) ->
    text
      (if n >= 0
       then Printf.sprintf "%s += %d;" x n
       else Printf.sprintf "%s -= %d;" x (-n))
  | Break -> text "break;"
  | Continue -> text "continue;"
  | Loop body -> Concat [ text "for (;;) "; block body ]
  | While (x, body) -> Concat [ text "while ("; text x; text ") "; block body ]
  | Return ((Equals _ | Not_equals _) as e) ->
    Concat
      [ text "return "
      ; group
          (Concat
             [ if_break (text "(") empty
             ; indent (Concat [ softline; expr ~parent:Return_argument e ])
             ; softline
             ; if_break (text ")") empty
             ])
      ; text ";"
      ]
  | Return e -> Concat [ text "return "; expr ~parent:Return_argument e; text ";" ]
  | Switch (d, cases) ->
    let case { label; body } =
      { role = Clause
      ; block_like = true
      ; doc =
          Concat
            [ (match label with
               | None -> text "default:"
               | Some l -> Concat [ text "case "; expr ~parent:Case_test l; text ":" ])
            ; text " "
            ; block body
            ]
      }
    in
    Concat
      [ group
          (Concat
             [ text "switch ("
             ; indent (Concat [ softline; expr ~parent:Discriminant d ])
             ; softline
             ; text ")"
             ])
      ; text " {"
      ; (match cases with
         | [] -> empty
         | cases -> indent (Concat [ hardline; Statements (List.map cases ~f:case) ]))
      ; hardline
      ; text "}"
      ]
  | If (test, body, rest) ->
    Concat
      [ group
          (Concat
             [ text "if ("
             ; indent (Concat [ softline; expr ~parent:Discriminant test ])
             ; softline
             ; text ")"
             ])
      ; text " "
      ; block body
      ; (match rest with
         | [] -> empty
         | [ (If _ as s) ] -> Concat [ text " else "; statement s ]
         | ss -> Concat [ text " else "; block ss ])
      ]

and destructuring fields source =
  let renamed = List.exists fields ~f:(fun (k, x) -> String.( <> ) k x) in
  group
    (Concat
       [ text "const "
       ; binding
           ~left:
             (object_
                ~grouped:false
                ~expanded:false
                (List.map fields ~f:(fun (k, x) -> k, Var x)))
           ~break_lhs:(List.length fields > 2 && renamed)
           source
       ; text ";"
       ])
;;

let rec type_has_newline = function
  | Name (n, args) -> String.contains n '\n' || List.exists args ~f:type_has_newline
  | Raw segments ->
    List.exists segments ~f:(function
      | Verbatim s -> String.contains s '\n'
      | Hole t -> type_has_newline t)
  | Literal s -> String.contains s '\n'
  | Fn { params; result; _ } ->
    List.exists params ~f:(fun (_, t) -> type_has_newline t) || type_has_newline result
  | Union ts | Tuple ts -> List.exists ts ~f:type_has_newline
  | Typeof _ -> false
  | Indexed (t, _) -> type_has_newline t
  | Conditional { check; extends; yes; no } ->
    List.exists [ check; extends; yes; no ] ~f:type_has_newline
;;

let rec type_decl = function
  | Alias { name; tparams; def } ->
    let left = Concat [ text "type "; text name; type_parameters tparams ] in
    let right = type_ ~parent:Other_type def in
    let body =
      if type_has_newline def
      then
        group
          ~should_break:true
          (Concat [ group left; text " ="; indent (Concat [ line; right ]) ])
      else (
        (* Prettier's [isComplexTypeAliasParams]. *)
        let complex_params =
          List.length tparams > 1
          && List.exists tparams ~f:(fun p -> Option.is_some p.bound)
        in
        let layout =
          match def with
          | _ when complex_params -> Break_lhs
          | Union _ -> Never_break_after_operator
          | Name _
          | Literal _
          | Fn _
          | Tuple _
          | Conditional _
          | Raw _
          | Typeof _
          | Indexed _ -> Fluid
        in
        assignment layout ~left ~op:" =" right)
    in
    Concat [ body; text ";" ]
  | Interface { name; tparams; fields } ->
    Concat
      [ text "interface "
      ; text name
      ; type_parameters tparams
      ; text " "
      ; (match fields with
         | [] -> text "{}"
         | fields -> braces (join hardline (List.map fields ~f:interface_field)))
      ]
  | Lambda { name; base; def } ->
    Concat
      [ text "interface "
      ; text name
      ; text " extends "
      ; text base
      ; text " "
      ; braces (interface_field ("type", def))
      ]
  | Kind { name; base; slots } ->
    let field (slot, v) = Concat [ text "readonly "; text slot; text ": "; text v ] in
    let target =
      group
        (Concat
           [ text "{"
           ; indent
               (Concat
                  [ line
                  ; join (Concat [ text ";"; line ]) (List.map slots ~f:field)
                  ; if_break (text ";") empty
                  ])
           ; line
           ; text "}"
           ])
    in
    Concat
      [ text "type "
      ; text name
      ; type_parameters (unbounded ("F" :: List.map slots ~f:snd))
      ; text " = F extends "
      ; text base
      ; indent
          (Concat
             [ hardline
             ; text "? "
             ; indent (Concat [ text "(F & "; target; text ")[\"type\"]" ])
             ; hardline
             ; text ": never"
             ])
      ; text ";"
      ]

and interface_field (f, t) =
  Concat
    [ group (Concat [ text "readonly "; text f; text ": "; type_ ~parent:Other_type t ])
    ; text ";"
    ]
;;

let top { exported; decl } =
  let export = text (if exported then "export " else "") in
  match decl with
  | Type td -> Concat [ export; type_decl td ]
  | Value { name; ty; value } -> Concat [ export; statement (Const (name, ty, value)) ]
  | Members { fields; source } -> Concat [ export; destructuring fields (of_path source) ]
;;

let ident_end s i =
  let n = String.length s in
  let rec go i = if i < n && is_ident_char s.[i] then go (i + 1) else i in
  go i
;;

let blank_end s i =
  let n = String.length s in
  let rec go i =
    if i < n && (Char.equal s.[i] ' ' || Char.equal s.[i] '\n') then go (i + 1) else i
  in
  go i
;;

let blank_start s ~floor j =
  let rec go j =
    if j > floor && (Char.equal s.[j - 1] ' ' || Char.equal s.[j - 1] '\n')
    then go (j - 1)
    else j
  in
  go j
;;

let arrow_at s i =
  i + 1 < String.length s && Char.equal s.[i] '=' && Char.equal s.[i + 1] '>'
;;

let arrow_after_result s k =
  let n = String.length s in
  let rec go depth i =
    if i >= n
    then false
    else (
      match s.[i] with
      | '=' when arrow_at s i -> depth = 0 || go depth (i + 2)
      | '(' | '[' | '{' | '<' -> go (depth + 1) (i + 1)
      | ')' | ']' | '}' | '>' -> depth > 0 && go (depth - 1) (i + 1)
      | (',' | ';' | '=') when depth = 0 -> false
      | _ -> go depth (i + 1))
  in
  go 0 (k + 1)
;;

let arrow_follows s j =
  let k = blank_end s (j + 1) in
  arrow_at s k || (k < String.length s && Char.equal s.[k] ':' && arrow_after_result s k)
;;

let keyword_at s i word =
  let k = String.length word in
  let n = String.length s in
  i >= 0
  && i + k <= n
  && String.is_substring_at s ~pos:i ~substring:word
  && (i = 0 || not (is_ident_char s.[i - 1]))
  && (i + k = n || not (is_ident_char s.[i + k]))
;;

let comment_end s i =
  let n = String.length s in
  if i + 1 < n && Char.equal s.[i] '/' && Char.equal s.[i + 1] '/'
  then (
    let rec go j = if j < n && not (Char.equal s.[j] '\n') then go (j + 1) else j in
    Some (go (i + 2)))
  else if i + 1 < n && Char.equal s.[i] '/' && Char.equal s.[i + 1] '*'
  then (
    let rec go j =
      if j + 1 >= n
      then None
      else if Char.equal s.[j] '*' && Char.equal s.[j + 1] '/'
      then Some (j + 2)
      else go (j + 1)
    in
    go (i + 2))
  else None
;;

let rec skip_gap s i =
  let n = String.length s in
  if i >= n
  then i
  else (
    match comment_end s i with
    | Some j -> skip_gap s j
    | None ->
      (match s.[i] with
       | ' ' | '\n' | '\t' | '\r' -> skip_gap s (i + 1)
       | _ -> i))
;;

let ident_at s i =
  let n = String.length s in
  if i < n && is_ident_char s.[i] && not (Char.is_digit s.[i])
  then Some (ident_end s i)
  else None
;;

let rec gap_start s j =
  if j <= 0
  then 0
  else (
    match s.[j - 1] with
    | ' ' | '\n' | '\t' | '\r' -> gap_start s (j - 1)
    | '/' when j >= 2 && Char.equal s.[j - 2] '*' ->
      let rec start k =
        if k <= 0
        then 0
        else if Char.equal s.[k] '/' && Char.equal s.[k + 1] '*'
        then gap_start s k
        else start (k - 1)
      in
      start (j - 3)
    | _ -> j)
;;

let typeof_operand s i =
  let j = gap_start s i in
  let start = j - 6 in
  start >= 0 && keyword_at s start "typeof" && start + 6 = j
;;

let skip_type s i =
  let n = String.length s in
  let rec go i depth =
    if i >= n
    then i
    else (
      match comment_end s i with
      | Some j -> go j depth
      | None ->
        (match s.[i] with
         | '"' | '\'' | '`' ->
           (match literal_end s i with
            | Some j -> go j depth
            | None -> n)
         | '(' | '[' | '{' | '<' -> go (i + 1) (depth + 1)
         | ')' | ']' | '}' | '>' -> if depth = 0 then i else go (i + 1) (depth - 1)
         | ',' when depth = 0 -> i
         | '=' when depth = 0 && not (arrow_at s i) -> i
         | _ -> go (i + 1) depth))
  in
  go i 0
;;

let type_parameter_binders s i =
  let n = String.length s in
  let rec binders i acc =
    let i = skip_gap s i in
    let i = if keyword_at s i "const" then skip_gap s (i + 5) else i in
    let open Option.Let_syntax in
    let%bind j = ident_at s i in
    let name = String.sub s ~pos:i ~len:(j - i) in
    let k = skip_gap s j in
    let k = if keyword_at s k "extends" then skip_type s (skip_gap s (k + 7)) else k in
    let k = skip_gap s k in
    let k =
      if k < n && Char.equal s.[k] '=' && not (arrow_at s k)
      then skip_type s (skip_gap s (k + 1))
      else k
    in
    let k = skip_gap s k in
    if k < n && Char.equal s.[k] ','
    then binders (k + 1) (name :: acc)
    else if k < n && Char.equal s.[k] '>'
    then (
      let after = skip_gap s (k + 1) in
      if after < n && Char.equal s.[after] '(' then Some (name :: acc) else None)
    else None
  in
  binders (i + 1) []
;;

let parameter_name p =
  let p = String.chop_prefix_if_exists p ~prefix:"..." in
  let name =
    String.strip
      (match String.index p ':', String.index p '=' with
       | Some i, Some j -> String.prefix p (min i j)
       | Some i, None | None, Some i -> String.prefix p i
       | None, None -> p)
  in
  if String.( <> ) name "" && String.for_all name ~f:is_ident_char
  then Some name
  else None
;;

let code_binders s =
  let n = String.length s in
  let rec go i acc =
    if i >= n
    then acc
    else (
      match s.[i] with
      | '"' | '\'' | '`' ->
        (match literal_end s i with
         | Some j -> go j acc
         | None -> acc)
      | '/' ->
        (match comment_end s i with
         | Some j -> go j acc
         | None -> go (i + 1) acc)
      | '<' ->
        (match type_parameter_binders s i with
         | Some names -> go (i + 1) (names @ acc)
         | None -> go (i + 1) acc)
      | '[' ->
        let k = skip_gap s (i + 1) in
        (match ident_at s k with
         | Some l when keyword_at s (skip_gap s l) "in" ->
           go (i + 1) (String.sub s ~pos:k ~len:(l - k) :: acc)
         | Some _ | None -> go (i + 1) acc)
      | '(' ->
        (match closing s i with
         | Some j when arrow_follows s j ->
           let parameters =
             split_top_level (String.sub s ~pos:(i + 1) ~len:(j - i - 1))
           in
           go (i + 1) (List.filter_map parameters ~f:parameter_name @ acc)
         | Some _ | None -> go (i + 1) acc)
      | c when is_ident_char c ->
        let j = ident_end s i in
        let word = String.sub s ~pos:i ~len:(j - i) in
        let k = blank_end s j in
        if String.equal word "infer"
        then (
          let k = skip_gap s j in
          match ident_at s k with
          | Some l -> go l (String.sub s ~pos:k ~len:(l - k) :: acc)
          | None -> go j acc)
        else if
          (String.equal word "const" || String.equal word "let" || String.equal word "var")
          && k < n
          && is_ident_char s.[k]
        then (
          let l = ident_end s k in
          go l (String.sub s ~pos:k ~len:(l - k) :: acc))
        else go j (if arrow_at s k then word :: acc else acc)
      | _ -> go (i + 1) acc)
  in
  go 0 []
;;

let rec code_identifier_spans s =
  let n = String.length s in
  let bound = code_binders s in
  let rec ident_start i =
    if i > 0 && is_ident_char s.[i - 1] then ident_start (i - 1) else i
  in
  let member i =
    i > 0
    && Char.equal s.[i - 1] '.'
    && not (i > 2 && Char.equal s.[i - 2] '.' && Char.equal s.[i - 3] '.')
  in
  let key opened i j =
    (match opened with
     | '{' :: _ -> true
     | _ -> false)
    && (let k = blank_end s j in
        k < n && Char.equal s.[k] ':')
    &&
    let k = blank_start s ~floor:0 i in
    k = 0
    || (Char.( <> ) s.[k - 1] '?'
        && String.( <> )
             (String.sub s ~pos:(ident_start k) ~len:(k - ident_start k))
             "case")
  in
  let rec go opened i acc =
    if i >= n
    then List.rev acc
    else (
      match s.[i] with
      | ('"' | '\'') as q ->
        (match string_end s q (i + 1) with
         | Some j -> go opened j acc
         | None -> List.rev acc)
      | '`' ->
        (match template_end s (i + 1) with
         | Some (j, holes) ->
           let inside (from, upto) =
             List.map
               (code_identifier_spans (String.sub s ~pos:from ~len:(upto - from)))
               ~f:(fun (i, j) -> from + i, from + j)
           in
           go opened j (List.rev_append (List.concat_map holes ~f:inside) acc)
         | None -> List.rev acc)
      | '/' ->
        (match comment_end s i with
         | Some j -> go opened j acc
         | None -> go opened (i + 1) acc)
      | ('(' | '[' | '{') as c -> go (c :: opened) (i + 1) acc
      | ')' | ']' | '}' ->
        (match opened with
         | _ :: rest -> go rest (i + 1) acc
         | [] -> go [] (i + 1) acc)
      | c when is_ident_char c ->
        let j = ident_end s i in
        let word = String.sub s ~pos:i ~len:(j - i) in
        go
          opened
          j
          (if member i || key opened i j || List.mem bound word ~equal:String.equal
           then acc
           else (i, j) :: acc)
      | _ -> go opened (i + 1) acc)
  in
  go [] 0 []
;;

let path_at s i j =
  let n = String.length s in
  let rec members j =
    if j + 1 < n && Char.equal s.[j] '.' && is_ident_char s.[j + 1]
    then (
      let k = ident_end s (j + 1) in
      String.sub s ~pos:(j + 1) ~len:(k - j - 1) :: members k)
    else []
  in
  String.sub s ~pos:i ~len:(j - i), members j
;;

let rfind_sub s sub =
  let rec go i =
    if i < 0
    then None
    else if String.is_substring_at s ~pos:i ~substring:sub
    then Some i
    else go (i - 1)
  in
  go (String.length s - String.length sub)
;;

let type_in_param p =
  let open Option.Let_syntax in
  let%bind c = String.index p ':' in
  let rest = String.drop_prefix p (c + 1) in
  let lead = skip_gap rest 0 in
  let stop = blank_start rest ~floor:lead (String.length rest) in
  if lead < stop then Some (c + 1 + lead, c + 1 + stop) else None
;;

let rec locate_params s params i =
  match params with
  | [] -> []
  | p :: rest ->
    (match String.substr_index s ~pos:i ~pattern:p with
     | None -> locate_params s rest i
     | Some j ->
       let here =
         match type_in_param p with
         | None -> []
         | Some (a, b) -> [ j + a, j + b ]
       in
       here @ locate_params s rest (j + String.length p))
;;

let constraint_ranges signature tparams =
  if String.equal signature "" || not (Char.equal signature.[0] '<')
  then []
  else (
    match closing signature 0 with
    | None -> []
    | Some close ->
      let inner = String.sub signature ~pos:1 ~len:(close - 1) in
      let piece p =
        let p = String.strip p in
        let i0 = skip_gap p 0 in
        let i0 = if keyword_at p i0 "const" then skip_gap p (i0 + 5) else i0 in
        match ident_at p i0 with
        | None -> []
        | Some name_end ->
          let k = skip_gap p name_end in
          let acc = ref [] in
          let k =
            if keyword_at p k "extends"
            then (
              let t = skip_gap p (k + 7) in
              let e = skip_type p t in
              if t < e then acc := (t, e) :: !acc;
              e)
            else k
          in
          let k = skip_gap p k in
          if k < String.length p && Char.equal p.[k] '=' && not (arrow_at p k)
          then (
            let t = skip_gap p (k + 1) in
            let e = blank_start p ~floor:t (String.length p) in
            if t < e then acc := (t, e) :: !acc);
          (match String.substr_index inner ~pattern:p with
           | None -> []
           | Some at -> List.map !acc ~f:(fun (a, b) -> 1 + at + a, 1 + at + b))
      in
      List.concat_map tparams ~f:piece)
;;

let result_range signature = function
  | None -> []
  | Some r ->
    (match rfind_sub signature r with
     | None -> []
     | Some j -> [ j, j + String.length r ])
;;

let arrow_slice s =
  let n = String.length s in
  let rec unwrap i limit =
    let i = skip_gap s i in
    if i < limit && Char.equal s.[i] '('
    then (
      match closing s i with
      | Some j when skip_gap s (j + 1) >= limit -> unwrap (i + 1) j
      | Some _ | None -> i, limit)
    else i, limit
  in
  let start, limit = unwrap 0 n in
  if start >= limit
  then None
  else (
    let slice = String.sub s ~pos:start ~len:(limit - start) in
    let open Option.Let_syntax in
    let%map rel = type_operator_index slice ~operator:"=>" in
    let raw = String.prefix slice rel in
    let lead =
      let rec go i =
        if i < String.length raw && Char.( <= ) raw.[i] ' ' then go (i + 1) else i
      in
      go 0
    in
    let body_at = skip_gap slice (rel + 2) in
    let body_end = blank_start slice ~floor:body_at (String.length slice) in
    ( start + lead
    , String.strip raw
    , start + body_at
    , String.sub slice ~pos:body_at ~len:(body_end - body_at) ))
;;

let rec annotation_ranges s =
  match arrow_slice s with
  | None -> []
  | Some (base, signature, body_at, body) ->
    let here =
      match code_signature signature with
      | None -> []
      | Some (tparams, params, result) ->
        List.map
          (constraint_ranges signature tparams
           @ locate_params signature params 0
           @ result_range signature result)
          ~f:(fun (a, b) -> base + a, base + b)
    in
    here @ List.map (annotation_ranges body) ~f:(fun (a, b) -> body_at + a, body_at + b)
;;

let in_ranges i ranges = List.exists ranges ~f:(fun (a, b) -> a <= i && i < b)
let bounds ty tparams = List.iter tparams ~f:(fun p -> Option.iter p.bound ~f:ty)

let collect f =
  let values = ref []
  and types = ref [] in
  let mentions s ~value_positions =
    let ranges = if value_positions then annotation_ranges s else [] in
    List.iter (code_identifier_spans s) ~f:(fun (i, j) ->
      let path = path_at s i j in
      (* [typeof v] is a type position. consistent-type-imports counts it
         as a type use, and tsc accepts it through a type import. *)
      if (not value_positions) || in_ranges i ranges
      then types := path :: !types
      else (
        values := path :: !values;
        types := path :: !types))
  in
  let code s = mentions s ~value_positions:true in
  let type_code s = mentions s ~value_positions:false in
  let rec chain = function
    | Var x -> Some (x, [])
    | Field (e, f) -> Option.map (chain e) ~f:(fun (x, fs) -> x, fs @ [ f ])
    | Code _
    | Helper _
    | Text _
    | Bytes _
    | Bigint _
    | Number _
    | Index _
    | Cell_read _
    | Tuple _
    | Call _
    | Arrow _
    | Cond _
    | Equals _
    | Not_equals _
    | Add _
    | Not _
    | Record _
    | Module_object _
    | Satisfies _ -> None
  in
  let rec ty = function
    | Name (n, args) ->
      (match String.split n ~on:'.' with
       | root :: members when is_path n -> types := (root, members) :: !types
       | _ -> type_code n);
      List.iter args ~f:ty
    | Literal _ -> ()
    | Fn { tparams; params; result } ->
      bounds ty tparams;
      List.iter params ~f:(fun (_, t) -> ty t);
      ty result
    | Union ts | Tuple ts -> List.iter ts ~f:ty
    | Conditional { check; extends; yes; no } ->
      List.iter [ check; extends; yes; no ] ~f:ty
    | Raw segments ->
      List.iter segments ~f:(function
        | Verbatim s -> type_code s
        | Hole t -> ty t)
    | Typeof (root, members) -> values := (root, members) :: !values
    | Indexed (t, _) -> ty t
  and expr = function
    | (Var _ | Field _) as e ->
      (match chain e, e with
       | Some p, _ -> values := p :: !values
       | None, Field (e, _) -> expr e
       | None, _ -> ())
    | Index (e, _) -> expr e
    | Cell_read (e, i) ->
      expr e;
      values := (i, []) :: !values
    | Tuple es -> List.iter es ~f:expr
    | Code s -> code s
    | Helper _ | Text _ | Bytes _ | Bigint _ | Number _ -> ()
    | Call (f, tys, args) ->
      expr f;
      List.iter tys ~f:ty;
      List.iter args ~f:expr
    | Arrow (tparams, params, result, body) ->
      bounds ty tparams;
      List.iter params ~f:(fun (_, t) -> ty t);
      Option.iter result ~f:ty;
      (match body with
       | Expr e -> expr e
       | Block ss -> List.iter ss ~f:stmt)
    | Cond (a, b, c) -> List.iter [ a; b; c ] ~f:expr
    | Equals (a, b) | Not_equals (a, b) | Add (a, b) -> List.iter [ a; b ] ~f:expr
    | Not e -> expr e
    | Record fields | Module_object fields -> List.iter fields ~f:(fun (_, e) -> expr e)
    | Satisfies (e, t) ->
      expr e;
      ty t
  and stmt = function
    | Const (_, t, e) ->
      Option.iter t ~f:ty;
      expr e
    | Let (_, t) -> ty t
    | Bind (_, e) | Variable (_, e) | Assign (_, e) | Eval e | Return e -> expr e
    | Cell_write (a, i, e) ->
      values := (a, []) :: (i, []) :: !values;
      expr e
    | Bump (x, _) -> values := (x, []) :: !values
    | Break | Continue -> ()
    | Switch (e, cases) ->
      expr e;
      List.iter cases ~f:(fun (c : case) ->
        Option.iter c.label ~f:expr;
        List.iter c.body ~f:stmt)
    | If (e, ss, rest) ->
      expr e;
      List.iter ss ~f:stmt;
      List.iter rest ~f:stmt
    | Loop ss -> List.iter ss ~f:stmt
    | While (x, ss) ->
      values := (x, []) :: !values;
      List.iter ss ~f:stmt
  in
  f ~ty ~expr;
  List.rev !values, List.rev !types
;;

let reads d =
  collect (fun ~ty ~expr ->
    match d with
    | Type (Alias { tparams; def; _ }) ->
      bounds ty tparams;
      ty def
    | Type (Interface { tparams; fields; _ }) ->
      bounds ty tparams;
      List.iter fields ~f:(fun (_, t) -> ty t)
    | Type (Lambda { base; def; _ }) ->
      ty (Name (base, []));
      ty def
    | Type (Kind { base; _ }) -> ty (Name (base, []))
    | Value { ty = annotation; value; _ } ->
      Option.iter annotation ~f:ty;
      expr value
    | Members { source; _ } -> expr (of_path source))
;;

let signature { ty = annotation; value; _ } =
  snd
    (collect (fun ~ty ~expr ->
       let rec arrow = function
         | Arrow (tparams, params, result, body) ->
           bounds ty tparams;
           List.iter params ~f:(fun (_, t) -> ty t);
           Option.iter result ~f:ty;
           (match body with
            | Expr e -> arrow e
            | Block _ -> ())
         | _ -> ()
       in
       match annotation, value with
       | Some t, _ -> ty t
       | None, (Arrow _ as a) -> arrow a
       | None, (Code _ as code) -> expr code
       | None, _ -> ()))
;;

let comment c =
  let b = Buffer.create (String.length c + 6) in
  Buffer.add_string b "/* ";
  String.iteri c ~f:(fun i ch ->
    Buffer.add_char b ch;
    if Char.equal ch '*' && i + 1 < String.length c && Char.equal c.[i + 1] '/'
    then Buffer.add_char b ' ');
  Buffer.add_string b " */";
  Buffer.contents b
;;

(* The order of Oxfmt's sortImports on two module specifiers, which it
   compares without regard to case and with a run of digits by its value,
   so that lib2 comes before lib10. *)
let specifier_compare a b =
  let rec run s i =
    if i < String.length s && Char.is_digit s.[i] then run s (i + 1) else i
  in
  let number s i j =
    let rec significant k =
      if k < j - 1 && Char.equal s.[k] '0' then significant (k + 1) else k
    in
    let k = significant i in
    String.sub s ~pos:k ~len:(j - k)
  in
  let rec go i j =
    match i < String.length a, j < String.length b with
    | false, false -> 0
    | false, true -> -1
    | true, false -> 1
    | true, true ->
      if Char.is_digit a.[i] && Char.is_digit b.[j]
      then (
        let i' = run a i
        and j' = run b j in
        let x = number a i i'
        and y = number b j j' in
        match compare (String.length x) (String.length y) with
        | 0 ->
          (match String.compare x y with
           | 0 -> go i' j'
           | c -> c)
        | c -> c)
      else (
        match Char.compare (Char.lowercase a.[i]) (Char.lowercase b.[j]) with
        | 0 -> go (i + 1) (j + 1)
        | c -> c)
  in
  go 0 0
;;

let type_text t = layout (type_ ~parent:Type_argument t)

let program p =
  let header = Option.map p.header ~f:comment in
  let specifier file = "./" ^ file ^ ".ts" in
  let imports =
    match
      List.sort p.imports ~compare:(fun x y ->
        specifier_compare (specifier x.file) (specifier y.file))
    with
    | [] -> []
    | is ->
      [ String.concat
          ~sep:"\n"
          (List.map is ~f:(fun { alias; file; type_only } ->
             let prefix = if type_only then "type " else "" in
             let path = specifier file in
             [%string {|import %{prefix}* as %{alias} from "%{path}";|}]))
      ]
  in
  let helpers = List.map (helpers_used p.decls) ~f:helper_definition in
  let decls = List.map p.decls ~f:(fun d -> layout (top d)) in
  (* A blank line separates the top-level statements, as
     require-readable-spacing asks, except two consts on one line each,
     which it lets stay together. *)
  let one_line_const s =
    (String.is_prefix s ~prefix:"const " || String.is_prefix s ~prefix:"export const ")
    && not (String.contains s '\n')
  in
  let rec join = function
    | [] -> []
    | [ s ] -> [ s ]
    | s :: (t :: _ as rest) ->
      s :: (if one_line_const s && one_line_const t then "\n" else "\n\n") :: join rest
  in
  String.concat (join (Option.to_list header @ imports @ List.concat helpers @ decls))
  ^ "\n"
;;
