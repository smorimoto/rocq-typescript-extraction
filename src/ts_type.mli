(** The types of the typed core.

    MiniML's [ml_type] is read in one place, {!of_ml}, and every later
    stage, from the environment through reconstruction to the namer,
    works on this type. Its ML fragment, type parameters, metas, globals,
    arrows, and the erased type, unifies as extraction's own unifier
    [Mlutil.mgu] does. A tuple and a union are the types of values that
    MiniML has no type for. There is no type for a type that MiniML lost:
    such a position is a meta, which reconstruction solves from the body
    of the declaration, or the declaration has no TypeScript type. *)

open Extraction_plugin

(** The type for types. *)
type t =
  | Var of int
  (** Type parameter [i] of the enclosing signature, or of a local function
      that a [let] generalises. Rigid. *)
  | Meta of meta (** An unknown of reconstruction, bound at most once. *)
  | Glob of Miniml.global * t list (** A declared type at its arguments. *)
  | Arrow of t * t (** A curried function value. [Arrow (Erased, b)] is [() => b]. *)
  | Erased (** The type of an erased value, [undefined]. *)
  | Never
  (** The type of no value, for an unconstrained type argument or a lower
      bound of an existential type in a function domain. *)
  | Tuple of t list
  | Union of t list (** Two members or more, distinct, none a union. *)
  | Cond of
      { on : t
      ; arms : (Miniml.global * t) list
      }
  (** [on extends C1 ? T1 : on extends C2 ? T2 : Tn] over the constructors
      of the enumeration that bounds [on], in declaration order. The last
      arm is not tested. [on] is a [Var] in a signature and anything once
      instantiated. A constructor global as a type, [Glob (c, [])], is the
      type of the values it builds: its interface, or its literal when
      [Extract Inductive] realises it with one. *)
  | Forall of int list * t
  (** [<A>(_: A) => A], a generic function type over [Var i] for each [i]
      of the list, which no type outside it mentions. Its body is an
      [Arrow]. A value of it takes no argument for the type parameters,
      which extraction passes as erased arguments. *)

(** The type for the unknowns of reconstruction. *)
and meta

(** The exception for a meta of a position that MiniML lost, which nothing
    solved where a type is printed. *)
exception Lost

(** The type for the type parameters of a signature: the binder a
    parameter is named after, and the type that bounds it. A type
    parameter of ML has neither. *)
type tparam =
  { hint : Names.Id.t option
  ; bound : t option
  }

(** The type for signatures. [Var i] in [ty] is the [i]th of [tparams]. *)
type schema =
  { tparams : tparam list
  ; ty : t
  }

(** [of_ml t] is [t] in the typed core. [Tvar i] and [Tvar' i] are
    [Var i], [Tdummy] is [Erased], [Tunknown], [Taxiom], and an unbound
    [Tmeta] are each a fresh {!lost} meta, and a bound [Tmeta] is the type
    it is bound to. *)
val of_ml : Miniml.ml_type -> t

(** [schema n t] is the signature of [t] over [n] type parameters of
    ML. *)
val schema : int -> t -> schema

(** [meta ()] is a fresh unbound meta. *)
val meta : unit -> t

(** [lost ()] is a fresh unbound meta for a position that MiniML lost.
    Reconstruction solves it as any other, and {!zonk} raises {!Lost} on
    it when nothing did. *)
val lost : unit -> t

(** [fresh ()] is a type parameter that no other has, for a [Forall] to
    bind. It is negative, so that it is never one of a signature. *)
val fresh : unit -> int

(** [resolve t] is the type that [t] is bound to, through every bound
    meta at its head. *)
val resolve : t -> t

(** [unify a b] binds metas so that [a] and [b] are equal, and is [true]
    if it can. When it cannot, it unbinds every meta it bound and is
    [false]. On the ML fragment it is [Mlutil.mgu], and [Erased] unifies
    with itself and with a meta only. A tuple
    and a union unify member by member, and two [Forall] of as many type
    parameters body by body, the parameters of each renamed to the same
    fresh ones. *)
val unify : t -> t -> bool

(** [equal a b] is [true] if [a] and [b] are the same type through
    their bound metas, an unbound meta being equal to itself only. *)
val equal : t -> t -> bool

(** [metas ts] is the unbound metas of [ts], each once, in order of first
    occurrence. *)
val metas : t list -> meta list

(** [same m m'] is [true] if [m] and [m'] are one meta. *)
val same : meta -> meta -> bool

(** [bind m t] binds the unbound meta [m] to [t].

    @raise CErrors.Anomaly if [m] is bound. *)
val bind : meta -> t -> unit

(** [instantiate vars tys t] is [t] where [Var i], for the [k]th [i] of
    [vars], is the [k]th type of [tys], except under a [Forall] that binds
    [i]. *)
val instantiate : int list -> t list -> t -> t

(** [subst tys t] is [t] where [Var i] is the [i]th type of [tys], from
    [1]. *)
val subst : t list -> t -> t

(** [split k t] is the types of the first [k] parameters of the function
    type [t], and the type of its result once they are applied. It has
    fewer than [k] parameters when [t] has fewer than [k] arrows. *)
val split : int -> t -> t list * t

(** [curried params result] is the function type from [params] to
    [result]. *)
val curried : t list -> t -> t

(** [is_erased t] is [true] if [t] is [Erased], through its bound metas. *)
val is_erased : t -> bool

(** [vars ts] is the [i] of every [Var i] in [ts] that no [Forall] binds,
    sorted, each once. *)
val vars : t list -> int list

(** [zonk t] is [t] with every bound meta replaced by its type and every
    unbound one of reconstruction by [Never], since nothing constrains it.
    A [Never] member adds nothing to a union.

    @raise Lost if [t] mentions an unbound {!lost} meta. *)
val zonk : t -> t

(** [is_ctor r] is [true] if [r] is a constructor. *)
val is_ctor : Miniml.global -> bool

(** [union ts] is the union of [ts], flattened, each member once, in order
    of first occurrence, or the one member. *)
val union : t list -> t

(** [reduce t ~unfold] is [t] as TypeScript reduces it at its head:
    [unfold r args] is the definition of the type function [r] at [args],
    if [r] is one, and is unfolded; a conditional whose [on] is one of its
    constructors is that arm; one whose [on] is a type other than a
    parameter or a meta is the union of its arms, as TypeScript
    distributes a conditional over the enumeration that [on] is; and the
    elements of a tuple are reduced. *)
val reduce : t -> unfold:(Miniml.global -> t list -> t option) -> t
