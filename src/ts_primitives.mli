(** The primitive types of the kernel and how the backend represents them.

    [PrimInt63.int], [PrimFloat.float], [PrimString.string], and
    [PrimArray.array] are declared with [Primitive] and have no body, so
    extraction gives each the axiom type. The backend owns their
    representation instead, so that their literals, which extraction
    writes as [MLuint], [MLfloat], [MLstring], and [MLparray], are typed
    and a program that uses them extracts without a preset. [int] is
    [bigint], [float] is [number], [string] is [string], with one UTF-16
    code unit per byte, and [array A] is the interface [PArray<A>] of the
    file that declares it,
    [{ readonly default: A; readonly items: readonly A[] }], whose [items]
    are the elements and whose [default] is the value of every index out
    of range. An [Extract] directive on one of the four types wins over
    the backend, as it does for any type. *)

open Extraction_plugin

(** The type for the primitive types. *)
type t =
  | Int63
  | Float64
  | Pstring
  | Parray

(** [equal p q] is [true] if [p] and [q] are the same primitive type. *)
val equal : t -> t -> bool

(** [owned r] is the primitive type that [r] is when the backend
    represents it. The backend does so when the kernel registers [r] as
    that type and no [Extract] directive maps [r]. *)
val owned : Miniml.global -> t option

(** [builtin r] is the TypeScript keyword that stands for [r] when
    {!owned} gives it [Int63], [Float64], or [Pstring]. The keywords are
    [bigint], [number], and [string]. [Parray] has no keyword, since its
    interface is declared. *)
val builtin : Miniml.global -> string option

(** [global p] is the global of the type [p], if the kernel registers
    one, as a literal of [p] is typed. *)
val global : t -> Miniml.global option

(** [remove_owned_axioms table] removes the primitive types that the
    backend represents from the unrealised axioms of [table]. Primitive
    operations and ordinary axioms remain in [table]. *)
val remove_owned_axioms : Table.t -> unit

(** [parameter] is the name of the type parameter of [PArray], as an
    identifier that {!Ts_names.named} names. *)
val parameter : Names.Id.t
