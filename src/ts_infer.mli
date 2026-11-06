(** Type reconstruction, from optimised MiniML to a typed core.

    MiniML keeps types on declarations, constructors, and matches only, but
    [tsc --strict] needs a type on every binder that has no contextual
    type. Reconstruction re-runs ML type inference over each declaration
    body with {!Ts_type.unify}, which is extraction's own unifier on the
    ML fragment, and records the result in {!expr}. Every binder
    carries its type. Every reference to a global, and every constructor,
    carries the instantiation of its type parameters, which the printer
    writes as explicit type arguments where TypeScript could not infer
    them from the arguments, so TypeScript checks these types. Every
    [MLmagic], and every place where reconstruction fails, is a [Cast].

    Reconstruction cannot fail as a whole. A unification failure becomes a
    [Cast] at that node and leaves unbound every meta that was unbound
    before it. Metas are otherwise only ever bound, never rebound, so every
    unification that succeeded still holds in the final substitution, and
    the printed types agree everywhere except at casts. A cast prints as a
    call to [__magic] that names the type of its expression and the type
    it casts to. The expression has the first, since the printed types
    agree up to the cast, so the call typechecks.

    A position of the declared type that MiniML lost and the kernel does
    not give is a {!Ts_type.lost} meta, which reconstruction solves from
    the body, as it types a tuple that a plugin's MiniML leaves
    [Tunknown]; one that nothing solves has no TypeScript type, and
    {!Ts_type.zonk} raises {!Ts_type.Lost} on it. A match that nothing
    constrains infers each branch on its own, through the casts that
    extraction wrote in it, and gets the one type they share or their
    union, so no cast appears at those returns, since every branch is
    assignable to the union.

    MiniML has no type for an [MLtuple], so a tuple is typed with the
    types of its elements, as a value is typed with a union, and a match
    whose every branch is a tuple of the same length is typed element by
    element. A match of one branch whose pattern is a [Ptuple] reads the
    elements of its scrutinee. When the scrutinee has another type than a
    tuple, as a parameter typed [Tunknown] does, the read goes through a
    [Cast] to a tuple of the elements' types.

    A literal of a primitive type has that type, [PrimInt63.int] for an
    [MLuint], as {!Ts_primitives} gives it, and an [MLparray] has
    [PrimArray.array] applied to the one type that its elements and its
    default share.

    A signature that {!Ts_kernel} reads may lift a binder to a type
    parameter bounded by an enumeration. A value of that parameter's type
    fits where its bound is expected, with no cast, and a match on the
    parameter knows, in each branch, the branch's constructor. A type that
    TypeScript reduces to one ML's unifier handles, as [Payload<true>] is,
    is checked as that type. One that only those constructors reduce, as
    a conditional over the parameter is, is checked as the reduced type
    and cast to it, once per branch, since TypeScript does not narrow a
    conditional type when it narrows the parameter's value. A term checked
    against a union fits it when it fits a member. A call instantiates a
    lifted parameter with the type of its argument, a constant
    constructor giving its literal type, and reduces the signature at that
    instantiation, so [dep(true)] needs no cast. A reference that no
    argument instantiates gives the parameter its bound, which TypeScript
    distributes to the union.

    A value of a {!Ts_type.Forall}, which TypeScript calls without type
    arguments, takes none of the erased arguments that extraction passes
    for them, each of which instantiates a type parameter with a fresh
    meta, and needs no cast where extraction put one at the head of the
    call. A lambda checked against it drops the lambda that extraction
    keeps for each type parameter, and is a {!Lambda} generic over fresh
    rigid parameters, eta-expanded when nothing else is left, as the
    argument [fun _ => id] is.

    A [let] generalises its definition as ML does when the definition is a
    lambda chain or a local recursive group. Once the definition is typed,
    every meta of its type that no enclosing binder mentions becomes a
    type parameter of the function, and each use instantiates them with
    fresh metas, so a local function can be used at several types without
    a cast. The functions of a group are monomorphic within the group, and
    each takes the type parameters of the group that its own type
    mentions. A definition of any other shape, such as a partial
    application or a constructor, stays monomorphic, since a TypeScript
    [const] that is not a function cannot be generic. So does the type of
    a parameter that extraction leaves unnamed, a [Dummy] binder, when it
    is a meta, since extraction leaves unnamed both a parameter it erases
    and one the body does not read. Only the uses tell them apart, so the
    uses fix its type, [Tdummy] for an erased one.

    Reconstruction rejects deep patterns, which the standard extraction
    does not produce, with a user error. They do not exist in {!expr}. *)

open Extraction_plugin

(** The type for reconstructed types. A reconstructed type has no
    [Meta], because an unsolved meta becomes [Never]. [Var i] is type
    parameter [i] of the enclosing declaration when [i] is at most the
    number of its type parameters, a type parameter of the generalised
    local function whose [Let] or {!fixdef} lists [i], or, when [i] is
    negative, of the [Forall] or the {!Lambda} that lists it. No two local
    functions of a declaration list the same [i].

    A [Union] is the type of a match whose branches reconstruction could
    not give one type, as {!match_} says: the types of its branches, two
    or more, none of which unifies with another. A
    [Tuple] is the type of a tuple, the types of its elements. A meta
    ranges over every type, these and a conditional included, so a
    generic call over a dependent value, as [pair(dep(b), dep(b))] is,
    instantiates its type parameters with the conditional and needs no
    cast. *)
type ty = Ts_type.t

(** The type for binders and their types. *)
type binder =
  { id : Miniml.ml_ident
  ; ty : ty
  }

(** The type for the reasons of a cast. *)
type cause =
  | Magic (** Extraction's own [MLmagic]. *)
  | Mismatch (** Reconstruction disagreed with extraction here. *)

(** The type for typed expressions. *)
type expr =
  | Local of int * ty list
  (** A de Bruijn index, as [MLrel], and the instantiation of the type
      parameters of the local, in order. The instantiation is empty when
      the local is monomorphic, and when it is a function of a local
      recursive group that a function of the same group refers to, since
      the group is monomorphic within itself. *)
  | Global of Miniml.global * ty list
  (** A term and the instantiation of its type parameters, in order. *)
  | Apply of expr * arg list
  | Lambda of int list * binder list * ty * expr
  (** The type parameters of the arrow, which a value of a
      {!Ts_type.Forall} is generic over and which are empty otherwise, all
      the leading lambdas of a chain, outermost first, and the type of the
      body. [Local 1] in the body is the last binder. *)
  | Let of binder * int list * expr * expr * ty
  (** The binder, the type parameters that a use of it instantiates, its
      definition, the body, and the type of the whole [let]. The type
      parameters are empty unless the definition is a [Lambda], or a [Fix]
      whose function they are the type parameters of. *)
  | Construct of Miniml.global * ty list * expr list
  (** A constructor, the instantiation of its inductive's parameters, and
      its arguments. *)
  | Match of match_
  | Unpack of unpack
  | Fix of int * fixdef array
  (** [Fix (i, defs)] is function [i] of a local recursive group. In each
      body, [Local 1] is the last function of the group. *)
  | Fail of string
  (** A call to [__fail(message)], for an [MLexn], or for an [MLaxiom] with
      the message [AXIOM TO BE REALIZED (name)]. *)
  | Dummy (** The erased value. *)
  | Cast of expr * ty * ty * cause
  (** An expression, its type, the type it is cast to, and why. *)
  | Uint of Uint63.t
  | Float of Float64.t
  | String of Pstring.t
  | Parray of expr list * expr
  (** An [MLparray], the elements of a primitive array and its default. *)
  | Tuple of expr list (** An [MLtuple]. *)

(** The type for the arguments of an application. *)
and arg =
  { expr : expr
  ; atomic : bool (** {!Ts_env.atomic} of the MiniML argument. *)
  }

(** The type for matches. *)
and match_ =
  { scrutinee : expr
  ; ind : Miniml.global (** The inductive matched on. *)
  ; tyargs : ty list (** The instantiation of the parameters of [ind]. *)
  ; branches : branch list
    (** The branches in MiniML order. At least one of them is a [Ctor]. *)
  ; result : ty
    (** The type of the match. When nothing expected a type of the match,
        each branch is inferred on its own, and the result is the one type
        the branches share, or the [Union] of the types they have when
        they share none. Branches share a type when their types unify. *)
  }

(** The type for the branches of a match. *)
and branch =
  { binders : binder list
    (** MiniML's branch identifiers, in order. The last is [Local 1] in
        [body]. *)
  ; pattern : pattern
  ; body : expr
  }

(** The type for the patterns of a branch. *)
and pattern =
  | Ctor of Miniml.global * int option list
  (** The constructor and, for each of its arguments, the de Bruijn index
      within the branch of the binder it binds, if any. *)
  | Default of { binds_scrutinee : bool }
  (** [Pwild], or [Prel 1] from branch factoring, whose single binder is
      the scrutinee itself. *)

(** The type for the matches of one branch whose pattern is a [Ptuple] of
    variables and wildcards, which read the elements of the scrutinee. *)
and unpack =
  { tuple : expr
  ; elements : ty list (** The types of the elements of [tuple]. *)
  ; binders : binder list
    (** MiniML's branch identifiers, in order. The last is [Local 1] in
        [body]. *)
  ; positions : int option list
    (** For each element, the de Bruijn index within the branch of the
        binder it binds, if any. *)
  ; body : expr
  ; result : ty
  }

(** The type for the functions of a local recursive group. *)
and fixdef =
  { name : Names.Id.t
  ; tparams : int list
    (** The type parameters of the function, those of the group that
        [ty] mentions, in order of first occurrence. They are empty unless
        a [let] binds the group. *)
  ; ty : ty
  ; body : expr
  }

(** The type for statistics about a reconstruction. [reconstruction_casts]
    is the number of casts left in the output because reconstruction
    disagreed with extraction. The TypeScript checker does not check the
    code at those casts. *)
type stats = { reconstruction_casts : int }

(** [declaration env r a] is the typed body [a] of the declaration [r],
    the type of that body, and the statistics of its reconstruction.
    {!Ts_env.term} gives the signature of [r] and its arity, and the types
    of the globals that [a] refers to. The type parameters of the
    signature are rigid. The typed body is a [Lambda] with exactly as many
    binders as the arity when it is positive, and a body with fewer
    leading lambdas is eta-expanded to get them. The type of the body is
    the signature's, with each {!Ts_type.lost} meta at the type that
    reconstruction found for the body.

    @raise Ts_type.Lost if the body solves no type for such a meta. *)
val declaration : Ts_env.t -> Miniml.global -> Miniml.ml_ast -> expr * ty * stats

(** [arity e] is the number of binders of [e] when [e] is a [Lambda], and
    [0] otherwise. *)
val arity : expr -> int

(** [position positions j] is the index in [positions] of the element
    that is [Some j], or [None] if no element is. The binders of a branch
    or an unpack are numbered from the last, so binder [i] of [n] is the
    element at [position positions (n - i)]. *)
val position : int option list -> int -> int option
