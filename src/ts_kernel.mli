(** Signatures of the types that extraction loses, read from the kernel.

    Extraction writes [Tunknown] where a type depends on a term, and keeps
    a type function over terms, [payload : bool -> Type], as a [Dtype]
    whose definition is [Tunknown] and whose references drop their term
    arguments. The kernel keeps both. This module is the only one that
    reads the kernel for types. It walks the kernel type of a declaration
    together with its MiniML type and translates each lost position to a
    {!Ts_type.t}, and copies every other position from MiniML.

    A binder whose type is an enumeration that TypeScript distributes a
    conditional over, and that a later lost position depends on, becomes
    a type parameter bounded by that enumeration. A [match] on such a
    binder becomes a conditional type, and a type function applied to
    terms an application of its alias to the parameter, to the literal
    type of a constructor, or to the bound. A [match] on any other term
    can become the union of its arms when an upper approximation is
    required. Function domains reverse that direction; arbitrary type
    constructors require exact arguments. Each leaf is extracted with
    [Extraction.extract_with_type] in
    the extraction's own state, so its type variables are those of the
    declaration. A lifted binder that the translated signature does not
    mention stays a plain parameter. A binder of a sort inside a type,
    which MiniML keeps as an erased argument, as in
    [h : forall A, A -> A], binds a type parameter of a {!Ts_type.Forall}
    when the type after it is a function. A position that no rule
    translates yet keeps its MiniML type.

    A type family defined by a fold can become a recursive alias when
    its captured types and nonstructural arguments remain fixed. For
    example, folding arrows over a list of types gives
    [Arrows<R> = R | ((_: never) => Arrows<R>)]. The [never] domain is a
    lower bound for the existential input type, not a replacement for
    the action or its result. An unknown positive existential type
    remains unsupported. Applications retain the existing explicit
    casts where extraction erased the relationship between an action
    and its inputs.

    An enumeration is an inductive type without parameters or indices,
    of two constructors or more, none of which takes an argument. One
    that [Extract Inductive] maps is one only when its constructors are
    literals and its type is [boolean] or the union of those literals,
    so that a value of the type is one of the literals. *)

open Extraction_plugin

(** The type for what the kernel gives the declarations of a structure. *)
type t

(** The type for the signatures of constructors: the binders a constructor
    lifts, which its interface and its function are generic over, and the
    types of its arguments, over the type parameters of its inductive,
    then those. *)
type ctor =
  { lifted : Ts_type.tparam list
  ; args : Ts_type.t list
  }

(** [create state struc] reads from the kernel the signature of every
    term and every constructor of [struc] whose MiniML type is lossy, and
    the definition of every type function over terms, in the extraction
    state [state]. Each is read in the environment that extraction types
    it in: a member of a functor body in that of the functor's parameters
    and the body's own fields, and a member of a module in that of its
    fields. A declaration that its environment does not hold, as one of a
    synthetic structure, gets none.

    @raise CErrors.UserError
      for a function whose result is a record with a field of sort Type
      that its body does not give before it runs, and for a constant
      whose values of such a record give a field different types, or
      none that is known before it runs, since TypeScript has no type for
      them without [unknown].
    @raise CErrors.Anomaly
      if a signature does not erase to the MiniML type of its term: each
      lifted parameter to its bound, a conditional or a union to
      [Tunknown], and an application of a type function over terms to its
      arguments of ML. *)
val create : Common.State.t -> Miniml.ml_structure -> t

(** [term kernel r] is the signature of the term [r], over the type
    parameters of its MiniML type, then those it lifts, before
    abbreviations are expanded. *)
val term : t -> Miniml.global -> Ts_type.schema option

(** [member kernel r t] is the signature of [r], a member of a module type,
    of a functor parameter, or of an application, of MiniML type [t],
    when [t] is lossy. It is read in the environment of the innermost
    path around [r] that a module type, a functor parameter, or a module
    of [struc] binds, or in the global environment, where an application
    at the top level is, so a member of an application has its kernel type
    at the argument it was applied to. *)
val member : t -> Miniml.global -> Miniml.ml_type -> Ts_type.schema option

(** [scope kernel mp] is the kernel environment for the innermost scope
    containing [mp], including bound functor parameters when available. *)
val scope : t -> Names.ModPath.t -> Environ.env option

(** [ctor kernel r] is the signature of the constructor [r], before
    abbreviations are expanded. *)
val ctor : t -> Miniml.global -> ctor option

(** [fields kernel r] is a type parameter for each field of sort Type of
    the record [r], named after the field, which the record's interface
    takes after its type parameters of ML. A binder of the record's type
    in the parameters of a signature gets fresh ones, a projection of
    such a binder is its parameter, and the type of a constant reads them
    off the one value its body gives each field. The result of a function
    reads them off its body: a record binder gives its parameters, a
    construction the type of each field, and a match on a lifted binder
    a conditional over the records of its branches. *)
val fields : t -> Miniml.global -> Ts_type.tparam list

(** [constructors r] is the constructors of the enumeration [r], in
    declaration order. *)
val constructors : Miniml.global -> Miniml.global list

(** [alias kernel r] is the definition of the type function over terms
    [r], over the type parameters of its [Dtype], then those it lifts. *)
val alias : t -> Miniml.global -> Ts_type.schema option
