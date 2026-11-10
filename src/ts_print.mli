(** The subset of TypeScript the backend emits, and its rendering.

    Lowering builds this tree and nothing else writes TypeScript text, so
    precedence, parentheses, string escaping, line breaking, and the runtime
    helper definitions live here only. Rendering is a pure function that
    lays the tree out as Oxfmt does with the options of Ultracite's preset,
    in lines of at most 80 columns where the code allows it, with
    two-space indentation, double quotes, semicolons, and a trailing comma
    in a broken object literal or list of type parameters but not in a
    broken list of arguments or parameters. A blank line comes before a
    [return], an [if], a [switch], or a [for], around a [const] or a [let]
    that takes more than one line, and after a statement or a case whose
    last token closes a block, as the require-readable-spacing rule of
    anti-slop asks, and nowhere else inside a function.
    [oxfmt --check] accepts the output unchanged, except where user code in
    a {!Code} is longer than its line. The width is fixed, so a golden file
    does not depend on [Set Printing Width].

    Every construct here is erasable syntax. The output passes
    [tsc --erasableSyntaxOnly] and runs under Node's built-in type
    stripping. There is no constructor for a [namespace], an [enum], an
    ambient [declare], [import x = require], or a [function] declaration,
    so a function is an arrow bound by a [const]. Nor is there one for a type
    assertion. The output never uses [<T>e] or [!], and uses [as] only in
    the const assertion of a module object, helpers included. *)

(** The type for TypeScript types. *)
type ty =
  | Name of string * ty list
  (** A type by name, with type arguments when the list is not empty. The
      name is a type variable, a keyword such as [unknown], a declared type
      through its import path when another file declares it, or the name an
      [Extract Inductive] gives. *)
  | Literal of string (** A string literal type, the tag of a constructor. *)
  | Fn of
      { tparams : tparam list
      ; params : (string * ty) list
      ; result : ty
      } (** [<A>(_0: A) => B]. *)
  | Union of ty list (** Two members or more. *)
  | Tuple of ty list
  (** [readonly [A, B]], the type of a tuple, broken one element per line
      with a trailing comma when it does not fit. *)
  | Conditional of
      { check : ty
      ; extends : ty
      ; yes : ty
      ; no : ty
      }
  (** [C extends E ? Y : N]. A chain of conditionals breaks as one, an
      arm per line, each nested conditional a step deeper, and is in
      parentheses as a member of a union and as the element of an array
      type. *)
  | Raw of segment list
  (** Type code from [Extract Constant] or [Extract Inductive], printed as
      written with a type in each hole. A hole is printed as a type
      argument is, without parentheses, so the code must place it where a
      type argument may stand, such as a tuple element, or as the element
      of an array type [$1[]], where it is in parentheses unless it is a
      name, a path, or a tuple. *)
  | Typeof of string * string list
  (** [typeof M.N], the type of the module object at the path of a root
      and the members read from it, which a type of the members of a
      functor's result reads as a value. *)
  | Indexed of ty * string (** [T["k"]], the type of the property [k] of [T]. *)

(** The type for the pieces of type code. *)
and segment =
  | Verbatim of string
  | Hole of ty

(** The type for type parameters, [A] or [B extends boolean]. *)
and tparam =
  { name : string
  ; bound : ty option
  }

(** [equal_ty a b] is [true] if [a] and [b] are the same tree. The members
    of a union are compared in order. *)
val equal_ty : ty -> ty -> bool

(** Types as hash table keys, compared as {!equal_ty} compares them. *)
module Ty_key : Base.Hashtbl.Key.S with type t = ty

(** [unbounded names] is a type parameter of each name, without a bound. *)
val unbounded : string list -> tparam list

(** The type for the runtime helpers, which the output defines when it
    uses them. *)
type helper =
  | Unary_constructor
  (** [__unaryConstructor(build)], a frozen successor builder with weak
      identity sharing for a compared unary type. *)
  | Unary_order
  (** [__unaryOrder(...)], a comparison factory caching certified stable
      prefixes and retaining the original function as its fallback. *)
  | Fail (** [__fail(message): never], which throws an [Error]. *)
  | Lazy (** [__lazy(thunk)], a memoising thunk for coinductive values. *)
  | Read_cell
  (** A checked read that distinguishes absent cells from stored
      [undefined]. *)
  | Write_cell (** A write that reuses cells up to the column's high-water mark. *)
  | Magic
  (** [__magic<From, To>(e)], which is [e], of type [From], at type [To],
      unchecked. It is the one way the output changes the type of a
      value. Its definition narrows [e] to [From & To] with the type
      predicate [__coerces], defined with it, which always holds, and calls
      {!Fail} in the branch that never runs, so it needs no [any] and no
      assertion. *)

(** The type for expressions. *)
type expr =
  | Var of string
  (** A binding, which is a local, a flat global such as [add] or [M$two],
      or a module object. *)
  | Code of string
  (** User code from [Extract Constant] or [Extract Inductive], printed as
      written. As a callee, a member object, a conditional test, or an
      operand of [===], it is put in parentheses unless it is an identifier,
      a dotted path, a literal, or already parenthesised. Elsewhere only
      code with a top-level comma is. An arrow function is split at its
      top-level [=>], so that its parameter list may break and its body
      move to the next line. The parameters and the body stay as written.
      Code that spans lines keeps its lines, with the lines after the
      first indented by the indentation of the line it starts, except its
      blank lines and the lines of its template literals, so only its first
      line counts toward the width of that line, and it breaks the groups
      around it, as a hard line does. Code enclosed in braces is an object
      literal, which an arrow hugs and a call expands as its last
      argument. *)
  | Helper of helper
  | Text of string (** A string literal from UTF-8 text, for tags and messages. *)
  | Bytes of string
  (** A string literal from a primitive string, with one UTF-16 code unit
      per byte. A byte that is not printable ASCII is an escape [\uXXXX]
      with uppercase digits, as unicorn's no-hex-escape and escape-case
      ask. *)
  | Bigint of string
  (** Decimal digits, rendered with the [n] suffix and, from five digits,
      an underscore every three digits from the right, as unicorn's
      numeric-separators-style asks. *)
  | Number of string
  (** A JavaScript number literal, including [Infinity], [-Infinity], and
      [-0], with the separators of {!Bigint} in its integer part and
      exponent, and none in its fraction, or [NaN], which is rendered
      [Number.NaN], as unicorn's prefer-number-properties asks. *)
  | Field of expr * string (** [e.f]. *)
  | Index of expr * int (** [e[k]], the read of element [k] of a tuple. *)
  | Cell_read of expr * string
  (** A checked read of a singleton-cell column at the index in variable [i]. *)
  | Tuple of expr list
  (** [[a, b]], an array literal, broken one element per line with a
      trailing comma when it does not fit, except that elements that are
      all numeric literals fill the lines. *)
  | Call of expr * ty list * expr list
  (** The callee, the explicit type arguments, which are omitted when there
      are none, and the arguments. *)
  | Arrow of tparam list * (string * ty) list * ty option * body
  (** The type parameters, the annotated parameters, the result type, and
      the body. A curried chain annotates the result of its innermost arrow
      only. *)
  | Cond of expr * expr * expr (** [c ? a : b]. *)
  | Equals of expr * expr (** [a === b]. *)
  | Not_equals of expr * expr (** [a !== b]. *)
  | Add of expr * expr (** [a + b], used for exact bigint accumulators. *)
  | Not of expr
  (** [!e], whose operand is in parentheses when it is an arrow, a
      conditional, a comparison, or [satisfies]. *)
  | Record of (string * expr) list
  (** An object literal, on one line when it fits and one field per line
      otherwise, [{ x }] when the value is [Var x]. The fields are in
      ascending byte order of their keys, as the sort-keys rule asks, and
      so are those of {!Module_object} and the pattern of {!Members}. *)
  | Module_object of (string * expr) list
  (** [{ ... } as const], one field per line. A module object among the
      fields is a plain object literal, because the outer const assertion
      already makes its members readonly. *)
  | Satisfies of expr * ty
  (** [e satisfies T], which checks that [e] has type [T] and asserts
      nothing. The [default] of a [switch] over every constructor returns
      the scrutinee [satisfies never], so tsc checks that the cases cover
      the type, with no runtime helper. The expression is laid out as an
      operand, in parentheses when it is an arrow, a conditional, or a
      comparison. *)

(** The type for the bodies of arrows. *)
and body =
  | Expr of expr
  | Block of stmt list

(** The type for statements. *)
and stmt =
  | Const of string * ty option * expr
  (** [const x: T = e;]. The type is [None] only for a local function, an
      annotated arrow whose type TypeScript reads off the arrow, and for an
      object of mutually recursive local functions. A type that is the
      keyword of a literal's primitive type, as [number] is for [1], or
      [boolean] for a negation, is not written, as typescript-eslint's
      no-inferrable-types asks. Local
      functions are arrows rather than [function] declarations because
      TypeScript forgets narrowing inside a hoisted declaration. *)
  | Bind of (string * string) list * expr
  (** [const { k: x } = e;], which binds [x] to the member [k] of [e] for
      each pair [(k, x)], written [k] alone when [x] is [k], as {!Members}
      does at the top level. *)
  | Let of string * ty
  (** [let x: T;], a variable that every branch of the statement after it
      assigns, so it is definitely assigned after that statement. *)
  | Variable of string * expr
  (** [let x = e;], a variable of the type of [e] that later statements
      assign. *)
  | Assign of string * expr
  (** [x = e;], or [[x] = t;] for an element [t[k]] of a tuple, with [k]
      holes before [x], as prefer-destructuring asks. *)
  | Cell_write of string * string * expr
  (** A write to a singleton-cell column, which reuses an existing cell when
      present. *)
  | Bump of string * int (** [x += n;], or [x -= n;] for a negative [n]. *)
  | Eval of expr
  (** An expression evaluated for its effects, with [void] before one that
      is not a call, so that an object literal is not parsed as a statement
      block. *)
  | Return of expr
  | Break (** [break;], which ends a case that does not return. *)
  | Continue
  (** [continue;], which starts the next iteration of the innermost
      {!Loop} or {!While}. *)
  | Switch of expr * case list (** The body of every case is wrapped in braces. *)
  | If of expr * stmt list * stmt list
  (** [if (test) { ... } else { ... }], with no [else] when its statements
      are empty and [else if] when they are one [If]. With no [else], the
      body ends in [return] or [continue], so the statements after it are
      the branches the test does not pick. *)
  | Loop of stmt list
  (** [for (;;) { ... }], which only a [return] leaves. It has no test, so
      no-constant-condition has none to read. *)
  | While of string * stmt list
  (** [while (x) { ... }], on a variable that the body assigns. *)

(** The type for the cases of a [switch]. *)
and case =
  { label : expr option (** [None] renders as [default]. *)
  ; body : stmt list
  }

(** [equal_expr a b] is [true] if [a] and [b] are the same tree. *)
val equal_expr : expr -> expr -> bool

(** [equal_stmt a b] is [true] if [a] and [b] are the same tree. *)
val equal_stmt : stmt -> stmt -> bool

(** The type for type declarations. *)
type type_decl =
  | Alias of
      { name : string
      ; tparams : tparam list
      ; def : ty
      }
  (** [type N<P> = T;], for unions and abbreviations. A union that does not
      fit puts each member on its own line after a [|]. *)
  | Interface of
      { name : string
      ; tparams : tparam list
      ; fields : (string * ty) list
      } (** [interface N<P> { readonly f: T; ... }], one field per line. *)
  | Lambda of
      { name : string
      ; base : string
      ; def : ty
      }
  (** [interface N extends B { readonly type: T; }], a type lambda, whose
      [def] reads its arguments as [this["Target"]]. *)
  | Kind of
      { name : string
      ; base : string
      ; slots : (string * string) list
      }
  (** [type N<F, A> = F extends B ? (F & { readonly Target: A })["type"] : never;],
      the application of a type lambda [F] to the type parameters of
      [slots], each given to its slot. The conditional breaks before [?]
      and [:], and the object of the slots one per line when it does not
      fit, as Oxfmt does. *)

(** The type for the values that a [const] declares. [ty] is [None] only
    for a function, an annotated arrow whose type TypeScript reads off the
    arrow, for a module object, whose type TypeScript infers from its
    fields, and for {!Code} that [Extract Inductive] gives, which carries
    its own types. *)
type value =
  { name : string
  ; ty : ty option
  ; value : expr
  }

(** The type for the bindings that a declaration refers to. A binding is
    the identifier at the root and the members read from it, as
    [("add", [])] for the call [add(n, m)] and
    [("$Datatypes", ["M"; "x"])] for [$Datatypes.M.x] or for the type
    [$Datatypes.Nat]. *)
type path = string * string list

(** The type for top-level declarations. *)
type decl =
  | Type of type_decl
  | Value of value (** [const]. *)
  | Members of
      { fields : (string * string) list
      ; source : path
      }
  (** [const { k: x } = source;], which binds [x] to the member [k] of the
      object at [source] for each pair [(k, x)] of [fields], written [k]
      alone when [x] is [k]. *)

(** The type for the statements of a module, each with whether it is
    exported. *)
type top =
  { exported : bool
  ; decl : decl
  }

(** The type for imports, [import * as alias from "./file.ts"], or
    [import type * as alias from "./file.ts"] when [type_only] holds, for
    a file that the program refers to in type positions only. *)
type import =
  { alias : string
  ; file : string
  ; type_only : bool
  }

(** The type for modules. *)
type program =
  { header : string option
  ; imports : import list
  ; decls : top list
  }

(** [reads d] is the paths that [d] refers to, as values and as types.
    They are every {!Var} and the member chain on it, the name of every
    {!Name} that is a path, in both lists every identifier of a {!Code},
    and, as types with the members read after it, every identifier of a
    {!Verbatim} or of a {!Name} that is not a path, so that
    [$Dep.Point] in type code is the path of [Point] through the import
    [$Dep]. An identifier of code counts when it is outside the string
    literals and the comments of the code, the holes of a template literal
    included, and is neither a member read after a dot, which the three
    dots of a spread are not, nor a property key, an identifier directly
    inside braces that a colon follows, unless [?] or [case] precedes it,
    nor a name the code binds. A bound name is a parameter of one of its
    arrows, a const or let of its body, a type parameter of an arrow whose
    parameter list is followed by [(], the name after [infer], or the key
    of a mapped type [[K in ...]]. The backend does not parse code. A
    shorthand property and a computed key are references. An identifier
    of type code, and an identifier in a type annotation of value code,
    is a type. The operand of [typeof] is one of them, since it is a type
    position, which a type import can name. Any other identifier of value
    code is both, since it may name either. *)
val reads : decl -> path list * path list

(** [signature v] is the type paths that a consumer of [v] sees. They are
    those of its annotation, of the parameters and results of its arrow
    and of the arrows it curries, or, when [v] is an unannotated {!Code},
    every identifier that {!reads} finds in it, since any of them may
    name a type. *)
val signature : value -> path list

(** [code_identifier_spans s] is the start and end offsets in [s] of the
    identifiers of the code [s] that {!reads} counts as references, in
    order. *)
val code_identifier_spans : string -> (int * int) list

(** [typeof_operand s i] is [true] when the identifier of [s] that starts
    at [i] is the operand of [typeof], with only spaces or a block comment
    between the keyword and the name. *)
val typeof_operand : string -> int -> bool

(** [balanced s] is [true] if every bracket of the code [s] closes in
    order and every string literal of [s] ends. The layout of a {!Code}
    reads the structure of the code from them, so it expects balanced
    code. *)
val balanced : string -> bool

(** [code_parameters s] is the names of the parameters of the code [s]
    when it is an arrow, as [["x"; "y"]] for
    ["((x: bigint, y: bigint): bigint => x + y)"], and the empty list
    otherwise. *)
val code_parameters : string -> string list

(** [is_atom s] is [true] if the code [s] is an identifier, a dotted
    path, or a literal. *)
val is_atom : string -> bool

(** [with_scrutinee code s] is the expression that the code [code] of a
    selector of [TypeScript Extract Match] gives for the scrutinee [s].
    It is [s] itself when [code] is {!hole}, the element or property read
    when it is [$0[k]] or [$0.f], a property path on, and otherwise
    {!Code} of [code] with the text of [s], a variable or a property
    path, in place of each [$0].

    @raise Invalid_argument
      if [code] is not {!hole} and [s] is not a variable or a property
      path. *)
val with_scrutinee : string -> expr -> expr

(** [hole] is [$0], which stands for the scrutinee in the code of a
    selector of [TypeScript Extract Match]. *)
val hole : string

(** [negated e] is the negation of the test [e]. It is {!Not_equals} for
    {!Equals} and the converse, the operand of a {!Not}, for {!Code}, [!x]
    for a variable or a path, [a !== b] for [a === b] and [a === b] for
    [a !== b] when that is the only operator at its top level, and [!(e)]
    otherwise, and {!Not} of any other expression. *)
val negated : expr -> expr

(** [union_members s] is the members of the type code [s] when it is a
    union at its top level, outside its brackets and string literals, as
    [["\"Eq\""; "\"Lt\""]] for ["\"Eq\" | \"Lt\""], and [[s]] otherwise. A
    function type is one member, since a union after its [=>] is its
    result. *)
val union_members : string -> string list

(** [type_text t] is the text of [t] laid out on its own, as a type
    argument is. *)
val type_text : ty -> string

(** [program p] is the source text of [p]. It holds the header comment,
    the imports in the order of Oxfmt's sortImports, by module specifier,
    such as [./pair-ext.ts], compared without regard to case and with a run
    of digits by its value, so that [./pair-ext.ts] comes before
    [./pair.ts] and [./lib2.ts] before [./lib10.ts], the definitions of
    exactly the helpers that occur in [p.decls], and then
    the declarations, separated by blank lines except between two consts
    on one line each, which stay together, as require-readable-spacing
    allows. *)
val program : program -> string
