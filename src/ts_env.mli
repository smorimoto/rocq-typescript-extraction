(** Types and representations of extracted globals.

    An environment describes the declarations of an optimised structure,
    including terms realised by [Extract Inlined Constant] and types
    realised by [Extract Inductive]. Every referenced global has an
    entry. A lookup of a missing entry raises an anomaly. *)

open Extraction_plugin

(** The type for environments. *)
type t

(** The type for what an environment knows about a term. *)
type term =
  { schema : Ts_type.schema (** The declared type with abbreviations expanded. *)
  ; arity : int
    (** The number of arguments the TypeScript declaration takes, uncurried.
        For a module or module type member, it is the number of arrows of
        the declared type with aliases unexpanded. An application member
        uses the arity of the corresponding member of the functor body,
        or the declared arrows when that member is unavailable.

        A top-level custom term, [MLaxiom], or [MLexn] body uses the arrows
        of the expanded type. Other top-level terms count their leading
        lambdas and any arguments still missing from a trailing global or
        an application of one to {!atomic} arguments. The count never
        exceeds the arrows of the expanded type. An arity of zero makes
        a [const]. *)
  }

(** The type for what an environment knows about an inductive type. *)
type ind =
  { repr : Ts_repr.t
  ; unary : Ts_repr.unary option
  ; optimise_unary : bool
  ; nparams : int
    (** The number of type parameters of the inductive. These are the ML
        parameters followed by one per record field of sort Type, as
        {!Ts_kernel.fields} gives them. *)
  }

(** The type for what an environment knows about a constructor. *)
type ctor =
  { ind : Miniml.global (** The inductive type of the constructor. *)
  ; index : int (** The position of the constructor in its type, from [0]. *)
  ; args : Ts_type.t list
    (** The types of the arguments, expanded, over [Var 1] to [Var n] for
        the [n] type parameters of the inductive, then [Var (n + 1)] and on
        for those of [lifted]. *)
  ; lifted : Ts_type.tparam list
    (** The binders the constructor lifts, as {!Ts_kernel.val-ctor} gives
        them. *)
  }

(** [atomic a] is [true] if the argument [a] may be evaluated at every call
    of a function rather than once. Such an argument is a variable, a
    global other than an inline custom, a literal, a dummy, or a
    constructor applied to atomic arguments. Evaluating one again at most
    re-creates a closure or an object. *)
val atomic : Miniml.ml_ast -> bool

(** [create state sigs struc] is the environment of the declarations in
    [struc], with kernel types from [state] and module signatures from
    [sigs]. It includes declarations in nested modules and functor bodies.

    Module type members occur under the module type's path, the bound
    paths of its functor parameters, and the paths of its applications.
    Functor signature results occur under the signature's path. Recovered
    signatures resolve module aliases, including those in parameter bounds
    and constructor signatures. A member
    whose MiniML type is lossy has the signature {!Ts_kernel.member}
    reads at its own path. *)
val create : Common.State.t -> Ts_sig.t -> Miniml.ml_structure -> t

(** [term env r] is what [env] knows about the term [r].

    Raises [CErrors.Anomaly] if [env] has no term [r]. *)
val term : t -> Miniml.global -> term

(** [ind env r] is what [env] knows about the inductive type [r].

    Raises [CErrors.Anomaly] if [env] has no inductive type [r]. *)
val ind : t -> Miniml.global -> ind

(** [ctor env r] is what [env] knows about the constructor [r].

    Raises [CErrors.Anomaly] if [env] has no constructor [r]. *)
val ctor : t -> Miniml.global -> ctor

(** [signature env c] is the signature that {!Ts_kernel.val-ctor} reads for
    the constructor [c], before abbreviations are expanded. *)
val signature : t -> Miniml.global -> Ts_kernel.ctor option

(** [fields env r] is {!Ts_kernel.fields} of the record [r]. *)
val fields : t -> Miniml.global -> Ts_type.tparam list

(** [refined env r] is [true] if the signature of the term [r] is the one
    that the kernel gives, and it translates, abbreviations expanded,
    every position that MiniML lost, so it has no meta. *)
val refined : t -> Miniml.global -> bool

(** [alias env r] is the definition that {!Ts_kernel.alias} gives the type
    function over terms [r], which no abbreviation expands. *)
val alias : t -> Miniml.global -> Ts_type.schema option

(** [missing_dependencies env sigs struc] is the globals mentioned by
    reconstructed signatures and type aliases but not declared in
    [struc]. Members reached through functor parameters or applications
    are compared at their canonical paths in [sigs]. Extraction must add
    these declarations, and close their own dependencies, before naming
    or printing the structure. *)
val missing_dependencies : t -> Ts_sig.t -> Miniml.ml_structure -> Miniml.global list

(** [unfold env r args] is the definition of the type function over terms
    [r] at the type arguments [args], expanded. *)
val unfold : t -> Miniml.global -> Ts_type.t list -> Ts_type.t option

(** [expand env t] is [t] with module alias paths resolved, including paths
    introduced by substituting functor arguments, and every non-custom [Dtype]
    abbreviation of
    [env] and every singleton inductive of [env] replaced by its
    definition, regardless of the [TypeExpand] flag. *)
val expand : t -> Miniml.ml_type -> Miniml.ml_type

(** [optimise_unary env inputs] is [env] with cached comparison and weak
    constructor sharing enabled for the unary types in [inputs]. Other
    types retain ordinary allocation. *)
val optimise_unary : t -> Miniml.global list -> t
