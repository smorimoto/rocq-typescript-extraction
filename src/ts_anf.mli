(** The calls of a recursive group, each made the definition of a [let],
    so that the stack machine of {!Ts_expr} can suspend there.

    A member of the group is a global of a top-level fixpoint, or a
    function of a local [fix]. A call of a member with at least its arity
    in arguments, outside a lambda, a local [fix], a lazy cell, and the
    branch functions of a match function, is a step of the machine. At
    the tail of the function it is a jump. Anywhere else, the machine
    pushes a frame and jumps, and the frame resumes with the rest of the
    function, so that rest must be a part of the term: the body of a
    [let] whose definition is the call, and the bodies of the [let]s
    whose definitions hold that [let], innermost first.

    {!normalise} gives the term that shape. A call in an operand of a
    call, a constructor, a tuple, a cast, or a scrutinee is bound first,
    and so is a match or a [let] in such an operand when it holds a call,
    floated out as a [let] of its own. An operand to the left of a call
    that computes is bound before it, so the operands are still evaluated
    from left to right, unless the term does not give its type, as for a
    call of a local function, which is then evaluated after the call. A
    call in the definition of a [let] that is not the whole definition,
    as one at the tail of a branch, is the definition of a [let] whose
    body is its variable. Nothing moves out of a lambda, a lazy cell, or a
    branch, and nothing is evaluated twice. *)

open Extraction_plugin

(** The type for how a term refers to a member: a global, or a local,
    by its de Bruijn index at the root of the term. *)
type head =
  | Global of Miniml.global
  | Local of int

(** The type for the members of a group. [result] is the type of a call
    with [arity] arguments. [accepts] holds of the instantiation of a
    reference to the member that keeps the group monomorphic, as its own
    type parameters do; a call at another instantiation is not a step. *)
type member =
  { head : head
  ; arity : int
  ; result : Ts_infer.ty
  ; accepts : Ts_infer.ty list -> bool
  }

(** [member_at members d f] is the index in [members] of the member that
    [f], at [d] binders below the root, refers to. *)
val member_at : member list -> int -> Ts_infer.expr -> int option

(** [steps env members e] is [true] if the term [e] calls a member outside
    a lambda, a local [fix], a lazy cell, and the branch functions of a
    match function. *)
val steps : Ts_env.t -> member list -> Ts_infer.expr -> bool

(** [steps_at env members d e] is {!steps} of [e] at [d] binders below
    the root. *)
val steps_at : Ts_env.t -> member list -> int -> Ts_infer.expr -> bool

(** [tails_only env members e] is [true] if every step of [e] is a call
    of a member with its arity in arguments at a tail of [e], and no
    argument of it steps. *)
val tails_only : Ts_env.t -> member list -> Ts_infer.expr -> bool

(** [calls env members e] is the steps of [e], in order: the index of the
    member each calls, the number of binders above it below the root, and
    its arguments. *)
val calls
  :  Ts_env.t
  -> member list
  -> Ts_infer.expr
  -> (int * int * Ts_infer.arg list) list

(** [delays env e ~arities] is [true] if [e] builds a function or a lazy
    cell that may read a variable after the statement that builds it.
    [arities] gives each free local's uncurried arity, in de Bruijn order,
    so that partial applications count as functions too. *)
val delays : Ts_env.t -> Ts_infer.expr -> arities:int list -> bool

(** [normalise env members e] is [e] with every call of a member, outside
    a lambda, a local [fix], a lazy cell, and the branch functions of a
    match function, either at the tail of [e] or the whole definition of
    a [let]. *)
val normalise : Ts_env.t -> member list -> Ts_infer.expr -> Ts_infer.expr

(** [lift_fixes env members lambdas] is the group of [members], whose
    lambdas are [lambdas], with one member more, when the body of a member
    is a local [fix] of one monomorphic function that calls a member, as
    Stdlib's [merge] is through [merge_aux]: the function of the [fix],
    which takes the parameters of the member that it reads, then its own,
    and is the local [1] of a scope with one more local than the scope of
    the group. Each call of the function is then a call of the new member
    with those parameters first, and so is each reference to it, or the
    group is [None]. *)
val lift_fixes
  :  Ts_env.t
  -> member list
  -> (Ts_infer.binder list * Ts_infer.ty * Ts_infer.expr) list
  -> (member list * (Ts_infer.binder list * Ts_infer.ty * Ts_infer.expr) list) option

(** [free e] is the indices of the locals that are free in [e], once
    each. *)
val free : Ts_infer.expr -> int list
