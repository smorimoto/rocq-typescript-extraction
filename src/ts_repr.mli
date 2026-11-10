(** How an inductive type is represented in TypeScript.

    {!decide} is the only place that chooses a representation and names
    the fields of a constructor, and the encoders below are the only code
    that writes a tag, a field read, a constructor interface, or a laziness
    wrapper. Declarations in {!Typescript} and expressions in {!Ts_expr}
    both go through them, so changing a representation is an edit to this
    module alone. *)

open Extraction_plugin

(** The type for the code that [Extract Inductive] gives a type. *)
type custom =
  { match_code : string option
    (** The optional match function. It is called uncurried with one
        function per branch, then the scrutinee. A branch function takes the
        constructor's arguments uncurried, and a nullary one is a thunk. *)
  ; selectors : Ts_match.selector array option
    (** The selectors of [TypeScript Extract Match], one per constructor,
        when the directive is given. A match then lowers inline, as
        {!Ts_expr} describes, and the match function is only a realiser
        that custom code may call. *)
  }

(** The type for the representations of constructors. *)
type ctor =
  { fields : string list
    (** One property per argument. The properties are the constructor's
        binder names from the kernel, camelCased, when MiniML keeps every
        argument and the names are distinct, can name a binding, and are
        not [tag]. They are [arg0], [arg1], and so on otherwise. The
        constructor function's parameters have the same names. *)
  ; params : int list
    (** The type parameters of the inductive that the arguments use, in
        order, then the binders the constructor lifts, as
        {!Ts_kernel.val-ctor} numbers them. The constructor's interface and
        function are generic over these only, so a constant constructor
        fits every instance. *)
  }

(** The type for the representations of inductive types. *)
type t =
  | Tagged of ctor array
  (** A discriminated union of one interface per constructor,
      [{ readonly tag: "C"; readonly f: T; ... }]. A nullary constructor is
      a constant typed with its interface, which mentions no type
      parameter, so it is a value of every instance of the union. A
      constructor with arguments is an uncurried function, which builds a
      value of the union when the type has two or more constructors, with
      [never] for the type parameters the constructor does not mention,
      since TypeScript narrows a const of a union type to the type of its
      initialiser, and of the interface when the type has one. *)
  | Record of string list
  (** One constructor with projections, as an interface whose
      properties are the projections, camelCased. It has no tag and no
      constructor function. *)
  | Lazy of ctor array
  (** A coinductive type, [type S<A> = () => U], where [U] is the union of
      the interfaces. A constructor builds its interface, which the thunk
      keeps from narrowing. A construction is wrapped in [__lazy], and a
      match forces the scrutinee first. *)
  | Erased
  (** A singleton, whose constructor extraction has already removed and
      whose matches it has turned into lets. Only the type alias is
      printed. *)
  | Custom of custom (** [Extract Inductive]. *)

(** [decide ~kernel ~signature ~scope ind i] is the representation of
    packet [i] of [ind]. The first rule that applies wins. A custom packet
    type gives [Custom], [Singleton] gives [Erased], [Record] gives
    [Record], [Coinductive] gives [Lazy], and anything else gives
    [Tagged]. The binder names of a constructor [c] are read from the
    kernel's declaration of [kernel c], which is [c] itself by default,
    and the constructor of the module type or of the functor's body for
    one reached through a functor parameter or an application, as
    {!Ts_sig.canon} gives it. [signature c] is the signature that
    {!Ts_kernel.val-ctor} reads for the constructor [c], whose argument types
    are then those of the signature. [signature] defaults to giving none.
    [scope] supplies the environment of a constructor inside a module type
    or functor parameter. It defaults to supplying none, and the global
    environment is then read.

    @raise CErrors.UserError
      if a [TypeScript Extract Match] directive is given for the type
      without an [Extract Inductive], if a selector of the directive does
      not give one expression per argument that extraction keeps, or if
      the code of a selector is not {!Ts_print.balanced}. *)
val decide
  :  ?kernel:(Miniml.global -> Miniml.global)
  -> ?signature:(Miniml.global -> Ts_kernel.ctor option)
  -> ?scope:(Names.ModPath.t -> Environ.env option)
  -> Miniml.ml_ind
  -> int
  -> t

(** The type for ordinary monomorphic unary types, with one nullary
    constructor and one constructor whose sole field is the same type.
    Both constructors are generated, with no custom realisations or lifted
    binders. *)
type unary =
  { zero : Miniml.global
  ; successor : Miniml.global
  ; predecessor : string
  }

(** [unary ~signature p repr] is the zero and successor constructors of
    the packet [p] represented by [repr] when it is a unary type, which
    frozen constructors and the unary comparison need, or [None] for
    other representations and uncertain shapes. [signature] gives the
    kernel signature of a constructor, if it has one, and defaults to
    giving none. *)
val unary
  :  ?signature:(Miniml.global -> Ts_kernel.ctor option)
  -> Miniml.ml_ind_packet
  -> t
  -> unary option

(** [unary_descriptor names u] is the tag property, the tags of the zero
    and successor constructors of [u], and its predecessor property, as
    string expressions for the unary comparison helper. *)
val unary_descriptor : Ts_names.t -> unary -> Ts_print.expr list

(** {1 Declarations} *)

(** The type for what a packet declares. *)
type declared =
  { types : Ts_print.type_decl list
    (** The constructor interfaces, then the type itself. It is empty for
        [Custom]. *)
  ; values : (Miniml.global * Ts_print.value) list
    (** The constructor constants and functions, keyed by constructor.
        For [Custom], they are the constants of {!Ts_names.realisers},
        keyed by constructor or, for the match function, by the inductive
        type. *)
  }

(** [declare ~freeze ~signature ~fields names ind i repr] is what packet
    [i] of [ind] declares under [repr], with the names of [names] and the
    realisers that {!Ts_names.realisers} finds. {!Typescript} decides
    which of them the output keeps and exports. [freeze] shares and
    freezes eligible unary constructors, preserving the existing
    constructor function types. It defaults to [false]. [signature c] is
    the signature that {!Ts_kernel.val-ctor} reads for the constructor [c],
    and [signature] defaults to giving none. [fields r] is
    {!Ts_kernel.fields} of the record [r], and [fields] defaults to giving
    none. *)
val declare
  :  ?freeze:bool
  -> ?signature:(Miniml.global -> Ts_kernel.ctor option)
  -> ?fields:(Miniml.global -> Ts_type.tparam list)
  -> Ts_names.t
  -> Miniml.ml_ind
  -> int
  -> t
  -> declared

(** {1 Expressions} *)

(** [construct names repr ctor ~index ~explicit tyargs args] is the value
    of constructor [ctor], number [index] of its type, applied to [args],
    with the type parameters instantiated by [tyargs] and the names of
    [names]. Under [Tagged] it is the constant, or [c<tyargs>(args)]
    keeping only the type arguments that the constructor uses, and none
    when [explicit] is [false], since TypeScript infers them. Under
    [Record] it is an object literal. Under [Lazy] it is the cell
    [c<tyargs>(args)], which {!delay} suspends. Under [Custom] it is the
    constructor as {!Ts_names.value} refers to it, applied uncurried to
    [args] when there are any. Closed binary integer constructor
    applications using the preset realisers become literals. [number]
    folding stops at the safe-integer bound so that runtime rounding is
    preserved.

    @raise CErrors.Anomaly if [repr] is [Erased]. *)
val construct
  :  Ts_names.t
  -> t
  -> Miniml.global
  -> index:int
  -> explicit:bool
  -> Ts_print.ty list
  -> Ts_print.expr list
  -> Ts_print.expr

(** [delay names repr ctor ~index tyargs] is [Some wrap] when [repr] is
    [Lazy], where [wrap body] is [__lazy((): C<tyargs> => body)] for the
    body that computes the cell of constructor [ctor], whose annotation
    keeps its type arguments, and [None] for a representation that
    builds its values at once. *)
val delay
  :  Ts_names.t
  -> t
  -> Miniml.global
  -> index:int
  -> Ts_print.ty list
  -> (Ts_print.body -> Ts_print.expr) option

(** [forced repr s] is [Some s()] when [repr] is [Lazy], because the value
    to match is the forced cell. It is [None] otherwise. *)
val forced : t -> Ts_print.expr -> Ts_print.expr option

(** [discriminant repr s] is what a multi-branch match on [s] compares. It
    is [s.tag] when [repr] is [Tagged] or [Lazy], and [s] itself for a
    [Custom] without a match function.

    @raise CErrors.Anomaly if [repr] is [Record] or [Erased]. *)
val discriminant : t -> Ts_print.expr -> Ts_print.expr

(** [label names repr ctor ~index] is what the discriminant is compared
    with for constructor [ctor], number [index]. It is the tag that
    [names] gives [ctor], or the code of a constant custom constructor.

    @raise CErrors.Anomaly if [repr] is [Record] or [Erased]. *)
val label : Ts_names.t -> t -> Miniml.global -> index:int -> Ts_print.expr

(** [field repr ~index s k] is the read of argument [k] of constructor
    number [index] in [s], such as [s.l], [s.arg0], or [s.px] for a
    record.

    @raise CErrors.Anomaly if [repr] is [Erased] or [Custom]. *)
val field : t -> index:int -> Ts_print.expr -> int -> Ts_print.expr
