(** Module types, and the paths through which their members are reached.

    A module type enters the structure as [SEmodtype], under its own path,
    when something extracted names it. A functor parameter, [X : S], and a
    module type defined as another, [Module Type SN := S], reach the
    members of [S] under their own paths, [<X>.f] and [SN.f], and an
    application [Module B := F A] reaches the members of the body of [F]
    under [B]. This module resolves a module type to its members at the
    path where they are used, and tells, for a global reached through such
    a path, the global it stands for.

    An abstract type of a module type, [Parameter t : Type], becomes a type
    parameter of the TypeScript interface, of the functor that takes the
    module type, and of every type declared in the module type or in the
    functor's body that mentions it. A declaration takes only the
    parameters it mentions, so {!implicit} gives, for each such type, the
    abstract types it mentions, transitively through the types it names. *)

open Extraction_plugin

(** The type for the module types of a structure. *)
type t

(** The type for an abstract type: its global, the identifier its type
    parameter is named after, which joins the labels from the module type
    down to the type, as [Inner_t] for the type [t] of a module [Inner] of
    the module type, and the number of parameters it takes, as [1] for
    [Parameter t : Type -> Type]. *)
type abstract =
  { global : Miniml.global
  ; id : Names.Id.t
  ; arity : int
  }

(** The type for the body of a functor: a structure, at its path, or the
    module expression a functor is defined as, an application or a module
    name, as [Module G (Y : T) := F A Y]. *)
type body =
  | Structure of Names.ModPath.t * Miniml.ml_module_structure
  | Applied of Miniml.ml_module_expr

(** The type for a functor: its parameters, outermost first, each with the
    module type it is declared with, and its body. *)
type functor_ =
  { params : (Names.MBId.t * Miniml.ml_module_type) list
  ; body : body
  }

(** The type for a functor signature, the module type of a functor: its
    parameters, outermost first, each with the module type it is declared
    with, and the module type of its result. *)
type signature_ =
  { parameters : (Names.MBId.t * Miniml.ml_module_type) list
  ; result : Miniml.ml_module_type
  }

(** [create struc] is the module types of [struc]: every [SEmodtype] and
    every [Smodtype] of a signature, by path, with the paths that reach
    their members: those of the module types defined as another, of the
    parameters and the bodies of the functors, of the parameters and the
    results of the functor signatures, and of the applications, of a
    functor, of a parameter declared with a functor signature, or of a
    partial application of either. *)
val create : Miniml.ml_structure -> t

(** [resolve t ~at mt] is the members of the module type [mt] under the
    path [at]. An [MTsig] gives its members, rebased from its own path to
    [at], an [MTident] those of the module type it names, and an [MTwith]
    those of the module type it constrains, with the type that
    [with Definition] names defined as the constraint says, and with every
    abstract type of the module that [with Module] names defined as the
    type of the same name in the module it is replaced by, so neither is
    abstract there. A nested module keeps the module type it is declared
    with, under a constraint of its own. A functor signature has no
    member, since the members of a functor are reached by applying it.

    @raise CErrors.UserError if [mt] names a module type that is not in the structure. *)
val resolve : t -> at:Names.ModPath.t -> Miniml.ml_module_type -> Miniml.ml_module_sig

(** [origin t mt] is the path of the [MTsig] that [mt] resolves to, which
    is where its interface is declared, through the constraints of an
    [MTwith], or the path of the functor signature that [mt] names, where
    its arrow type and the interface of its result are declared.

    @raise CErrors.UserError as {!resolve}.
    @raise CErrors.Anomaly if [mt] is an [MTfunsig], which has no path of its own. *)
val origin : t -> Miniml.ml_module_type -> Names.ModPath.t

(** [functor_signature t mt] is the functor signature that [mt] is, or
    names through module types defined as others, if any.

    @raise CErrors.UserError as {!resolve}. *)
val functor_signature : t -> Miniml.ml_module_type -> signature_ option

(** [parameter t id] is the module type that the functor parameter [id],
    of a functor or of a functor signature, is declared with, if [id] is
    one. *)
val parameter : t -> Names.MBId.t -> Miniml.ml_module_type option

(** [abstracts t ~at members] is the abstract types of the members
    [members] of a module type resolved at [at], in declaration order,
    those of its nested modules included, after the module's own. *)
val abstracts : t -> at:Names.ModPath.t -> Miniml.ml_module_sig -> abstract list

(** [arity t r] is the number of parameters of the abstract type [r] of a
    module type, as reached at any path that uses the module type, and [0]
    for any other global. [kinds t mp] is the greatest arity of the
    abstract types of the module types declared in the file [mp], and [0]
    when it declares none that takes parameters. *)
val arity : t -> Miniml.global -> int

val kinds : t -> Names.ModPath.t -> int

(** [home t r] is the file of the module type that the abstract type [r]
    that takes parameters is reached from, whose helper types its
    applications use, if [r] is one. *)
val home : t -> Miniml.global -> Names.ModPath.t option

(** [signature_abstracts t ~at s] is the abstract types of the parameters
    of the functor signature [s], in order, and those left in its result
    when the result is a module type it names or a signature written as
    its body, used at [at]. A type left in the result is one that each
    implementation picks from the abstract types of its parameters, so it
    takes all of them as parameters, before its own, and its type
    parameter is named [R]. A result that is itself a functor signature
    contributes none.
    [parameter_abstracts t ~at mt] is the abstract types that a functor
    parameter declared with [mt] at [at] brings: those left in the result
    for a functor signature, and those of {!abstracts} for any other
    module type. *)
val signature_abstracts
  :  t
  -> at:Names.ModPath.t
  -> signature_
  -> abstract list * abstract list

val parameter_abstracts
  :  t
  -> at:Names.ModPath.t
  -> Miniml.ml_module_type
  -> abstract list

(** [canon t r] is the global that [r] stands for: for a member of a
    functor parameter, the member of the module type it is declared with;
    for a member of an application, the member of the functor's body; for
    a member of a module type defined as another, the member of that one;
    and [r] itself otherwise. It follows the paths through nested modules
    and through module types defined as others, and is where the names of
    [r] come from. *)
val canon : t -> Miniml.global -> Miniml.global

(** [reaches t r] is the global that [r] stands for one step along the
    paths that {!canon} follows: the member of the functor's body for a
    member of an application, which may itself be a member of an
    application in that body, and [r] itself when no path reaches
    another. *)
val reaches : t -> Miniml.global -> Miniml.global

(** [pruned t mp] is [true] if the interface of the module type at [mp]
    lists only the members that something uses, which it does unless the
    module type types what a functor returns, directly or through the
    module types its nested modules are declared with, since a body
    returns every member the module type lists. An interface with fewer
    members accepts more objects, so a consumer building an argument
    module by hand supplies only what the functors read. *)
val pruned : t -> Names.ModPath.t -> bool

(** [used t r] is [true] if a term of the structure reads the member [r]
    of a module type through a functor parameter, at any path along the
    way from the parameter to the module type that declares [r], and
    [used_under t mp] if it reads any member under the path [mp], or an
    application applies a functor under [mp] through a parameter. *)
val used : t -> Miniml.global -> bool

val used_under : t -> Names.ModPath.t -> bool

(** [canon_path t mp] is the path that the members under [mp] are
    declared at, as {!canon} resolves a global: [mp] itself when none
    reaches another. *)
val canon_path : t -> Names.ModPath.t -> Names.ModPath.t

(** [step t mp] is the path that [mp] reaches one step along the paths
    that {!canon_path} follows, with the prefix of [mp] that the step
    replaces and the path that replaces it, if a path reaches another
    from [mp]. *)
val step
  :  t
  -> Names.ModPath.t
  -> (Names.ModPath.t * (Names.ModPath.t * Names.ModPath.t)) option

(** [implicit t r] is the abstract types that the type or constructor [r],
    declared in a module type or in a functor body, mentions: in its
    definition or its arguments, or through another type of the same
    module type or body, transitively. They are the type parameters that
    its TypeScript declaration takes beyond its own, in the order of
    {!abstracts}. For a type reached through a functor parameter, an
    application, or a module type defined as another, they are those of
    the type it stands for, under the path of [r], so a type parameter
    that a constraint fixes is among them, as the type argument that the
    constraint gives. It is empty for any other global. *)
val implicit : t -> Miniml.global -> Miniml.global list

(** [fixed t r] is the parameters and the definition of the abstract type
    [r] of a module type, as reached under a path where a constraint
    defines it: the constraint's type for a [with Definition], and the
    type of the same name in the module that a [with Module] gives, or
    what {!sealed} gives. It is [None] for any other global. *)
val fixed : t -> Miniml.global -> (Names.Id.t list * Miniml.ml_type) option

(** [sealed t r] is the parameters and the definition of the abstract type
    [r] that the module type a functor is sealed with defines by a
    constraint, as [L.t] is [X.t] in the body of
    [Module F (X : S) : T with Module L := X], and under each
    application of the functor, with the parameters replaced by the
    arguments, at any depth of applications in the bodies of others.
    Extraction keeps no such definition in the module type of an
    application. It is [None] for any other global. *)
val sealed : t -> Miniml.global -> (Names.Id.t list * Miniml.ml_type) option

(** [alias t mp] is the module that the alias declared at [mp], in a
    structure or in the body of a functor, stands for, if [mp] is one. *)
val alias : t -> Names.ModPath.t -> Names.ModPath.t option

(** [functor_ t mp] is the functor declared at [mp], if any. *)
val functor_ : t -> Names.ModPath.t -> functor_ option

(** [qualified r] is the name of [r] as a message names a member of a
    module type, which the name table does not know: its label under the
    shortest name of the innermost module type or module on its path that
    the table knows, as [FT.t]. *)
val qualified : Miniml.global -> string

(** [rebase ~from ~to_ r] is [r] with the prefix [from] of its module path
    replaced by [to_], and [r] itself when its path does not start with
    [from]. *)
val rebase : from:Names.ModPath.t -> to_:Names.ModPath.t -> Miniml.global -> Miniml.global

(** [rebase_type ~from ~to_ t] is [t] with every global rebased as
    {!rebase} does. *)
val rebase_type
  :  from:Names.ModPath.t
  -> to_:Names.ModPath.t
  -> Miniml.ml_type
  -> Miniml.ml_type
