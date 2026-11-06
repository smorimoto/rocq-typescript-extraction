(** The typed core to TypeScript, in one translator.

    TypeScript separates statements from expressions and MiniML does not.
    Each construct is translated once, to an expression and the
    statements that must run before the statement it is part of. A
    [let], a local [fix], a scrutinee or a tuple that must be bound, and
    a pattern variable of the one branch of an inline match are [const]
    statements there, since the strict operands of an expression are all
    evaluated whenever it is, in an order that does not matter for pure
    terms. Nothing moves out of a lambda, a branch, or a [__lazy] thunk,
    each of which is a block of its own. A name that such a statement
    declares avoids every name chosen in the expression it comes from,
    which follows it.

    A match of two branches whose bodies are expressions, neither of them
    a conditional, is a conditional expression. Any other match is a
    statement, a [switch] or a chain of [if] statements, which the
    statement it is part of places. A [return] is pushed into its
    branches, and so is the binding of a [let], declared [let x: T;] and
    assigned in each branch, when the expression around the match copies
    only atoms besides the match: it is a spine of calls, tuples, and
    records whose other operands are variables, literals, or property
    paths, so each branch gets one copy of the spine. Otherwise the match
    assigns a variable [result], declared first, which the expression
    reads, and so does every match of a statement but the last. A case
    that assigns ends in [break], and a chain of tests that assigns has
    an [else] for each test. The output is linear in each match, since a
    context is copied once per branch and a context that is copied holds
    no other match.

    A [let] whose definition is a local [fix] declares the group in place,
    and the body refers to the function the [fix] picks.

    A named function, a top-level one or a function of a local [fix],
    whose body calls it with all its arguments, at its own type
    parameters, is a loop, [for (;;)], so that its recursion does not grow
    the JavaScript stack. A parameter that such a call passes something
    else is copied to a [let] before the loop, named apart from the
    parameter, as [n0] is for [n], since no-param-reassign forbids
    assigning a parameter, and the body reads the copy. A self call at a
    tail assigns the copies and continues, or ends the loop's body. No
    assignment overwrites a copy that a later one reads, and where the
    next values read each other's copies, a [const] holds one first, as
    [const b1 = add(a0, b0);] does. A match at a tail is a [switch] or a
    chain of [if] statements, as at the tail of a top-level function.

    A self call anywhere else is a step of a stack machine. {!Ts_anf}
    first binds every such call to a [let], with the operands it reads and
    the matches and [let]s around it, so that the rest of the call is the
    body of that [let] and of the [let]s around it. The call pushes a
    frame and continues: the number of its site, in [frames], when the
    function has several, and each variable that the rest reads, on an
    array of its type, [saved], with its index, [top], while [depth]
    counts the frames. All arrays are local to the invocation, including
    the array of sites. A callback that reenters the function uses its
    own arrays, and an exception needs no shared-state cleanup. A variable
    bound outside the function, and a parameter that every call passes
    unchanged, which stays the parameter,
    are not saved. A tail that is a value assigns [returned], and the code
    after the body pops a frame and runs the rest of its site with
    [returned] as the result of the call, which may call again, until no
    frame is left. Two sites whose rests are the same code are one.
    A single continuation shape that only applies the mapped bigint successor
    or adds one saved bigint can use an exact accumulator instead of frames.
    Only the preset's pure realiser code qualifies; number addition and
    computations performed after the recursive call retain their order.
    A body that builds a function, a lazy cell, a partial application,
    or a branch of a match function reads a [const] copy of each [let] at
    the top of each iteration, since what it builds would otherwise read
    the [let] after the loop assigns it, which no-loop-func rejects.

    A function whose self calls are all at a tail, and whose body builds
    nothing over a copy, has no frames, and is the loop alone. A function
    that the machine cannot take, such as one whose frame would save a
    generic local function, is that loop when its self calls at its tails are
    the only ones and it builds nothing over a copy, and keeps its
    recursion otherwise. A call of the function at other type arguments
    is a call.

    A member of a mutually recursive group, top-level or local, that calls
    another member outside the functions it builds is the loop of the
    whole group: a call of any member is a step. When the members take
    parameters of the same types and return the same type, the loop keeps
    one set of copies, shared by position. In a group of two, a jump to
    the other member at the tail of the code is that member's body in
    place, with its parameters bound to the arguments, and a group of
    three or more keeps the member it runs in [which], which the loop
    dispatches on. When they differ, the loop dispatches on [which], a
    jump to a member other than the first pushes the arguments on the
    columns of their types, which that member pops at its start, and,
    when the group has frames, each member pushes the value it reaches on
    the column of its type, which the rest of a call pops before what its
    frame saved. A group the machine cannot take leaves each member the
    loop of its own self calls, and its calls of other members calls
    through the object of the group.

    A local [fix] of one monomorphic function that is the whole body of a
    member and calls the group, as Stdlib's [merge] is through
    [merge_aux], is a member of the group of its own, which
    {!Ts_anf.lift_fixes} gives: it takes the parameters of the member that
    it reads before its own, and the member calls it with them, so no
    arrow is declared for it.

    A generic local function, one that a [let] generalises, is a generic
    arrow, [const pick = <B>(x: B, y: B): B => ...;], with type parameters
    named apart from those in scope. A call writes its type arguments by
    the rule for globals below, and a call from within its recursive group
    passes the group's own type parameters. A function of a local
    recursive group takes the type parameters of the group that its type
    mentions, and the others are [never] in it. A local function,
    generic or not, that refers to no local, to no global of the
    declaration being translated, and to no type parameter of the
    declaration, is a private constant before the declaration, as a
    statement at the top of a constant is, since Oxlint's
    consistent-function-scoping rejects a local function that captures
    nothing, as one that loops instead of calling itself may, and leaves
    only the body of its [let]. A local function that refers to the
    declaration stays local, because the declaration follows it, and so
    does one whose type mentions a type parameter of the declaration,
    which the top of the file does not bind.

    A [let] bound to a match that must be a statement is declared
    [let x: T;] and assigned in each branch. When its body is an atom,
    or one call, tuple, or record of atoms, as [add(w, w)] is, the body
    goes into each branch instead, after a [const] for the result of
    the branch, so the branch returns, or assigns, the body.

    A named function, such as a declaration, a [let]-bound lambda chain, or
    a local [fix], takes its arity in arguments, uncurried. A function
    value, such as a lambda, a parameter, or a field, is curried, with one
    argument per call. A call with fewer arguments than the arity becomes
    an arrow that takes the rest. A supplied argument that is not
    {!Ts_env.atomic} is a [const] that runs first, as a [let] is, so it is
    evaluated once, when the partial application happens, as in ML. A call
    with more arguments applies the result to the extra ones one at a time.

    An erased parameter, one of type [Tdummy], is dropped. A named
    function keeps its other parameters and is nullary when none remains,
    a function value has a nullary arrow in its place, and a call passes
    nothing at its position, so a body that throws still throws at the
    call. Which parameters of a global are erased, its declared type says,
    not its instantiation, so an erased value that instantiates a type
    parameter is passed as an argument.

    A call of a global or a constructor writes its type arguments only
    when TypeScript could not infer them: when a type variable of the
    callee's declared type occurs in the type of no parameter that an
    argument pins, as in [empty<Nat>()], or where the argument is an erased
    value or a cast, whose type would not pin the variable. A missing
    parameter of a partial application pins through the annotation of the
    arrow that takes it.

    Pattern variables are never bound. Each one is replaced by a field read
    of the scrutinee, such as [t.l] or [p.px], which is a variable or a
    property path, so TypeScript narrows it. Local names never shadow a
    global or an enclosing local, so the substitution is hygienic.

    A tuple is an array literal, [[a, b]], typed [readonly [A, B]], and the
    variables of a tuple pattern read the elements of the scrutinee by
    index, as [p[0]], the way the field reads do, with the scrutinee bound
    to a [const] first when it is not a variable or a property path.

    A match on a type with a [TypeScript Extract Match] directive calls
    no match function. A match of one branch is the body of the branch.
    One of two branches that bind no [const] and whose bodies are
    expressions is the conditional [t ? a : b] of the test of the first,
    or that test itself or its negation when the bodies are the boolean
    literals. Any other is a chain of [if] statements, one per branch but
    the last, on the test of its constructor, with the last branch after
    the chain, untested, since the chain is total. A pattern variable
    whose selector expression is a path, such as [p[0]], reads it at each
    use, as a field read does, one the body never refers to is not bound,
    and any other is bound to a [const] at the top of its branch, so the
    expression is evaluated once. The scrutinee is bound to a [const]
    first unless it is a path, or unless the match is of two branches
    that bind no variable and the test of the first is [$0] itself, as a
    match on a [boolean] is, in which case it stands in the test unbound,
    evaluated once as in ML. *)

(** The type for translation scopes. A scope holds the registries, the type
    variables of the enclosing declaration, and, for each variable in
    scope, how to refer to it, its arity, and its type. *)
type scope

(** [scope env names tvars ~name ~defining] is the empty scope of the
    declaration [name] whose type variables are named by [tvars], over
    the globals of [env] named by [names]. [defining] is the globals of
    the declaration. A private constant that its translation declares
    before it, which {!lifted} gives, keeps the name of its local, as
    [id], with a numeric suffix when the file or the declaration already
    takes it, and {!Ts_names.lift} records it once it is lifted, so that
    no later local shadows it. *)
val scope
  :  Ts_env.t
  -> Ts_names.t
  -> Ts_names.tvars
  -> name:string
  -> defining:Extraction_plugin.Miniml.global list
  -> scope

(** [in_group scope members] is [scope] where a reference to the global
    [r] of a pair [(r, e)] of [members] is [e]. The members of a mutually
    recursive group reach each other through the object that declares them
    this way. *)
val in_group : scope -> (Extraction_plugin.Miniml.global * Ts_print.expr) list -> scope

(** [lifted scope] is the private constants that translations under
    [scope] declared, in an order where each refers only to those before
    it. They go before the declaration. *)
val lifted : scope -> Ts_print.value list

(** [ty scope t] is the TypeScript type of the reconstructed type [t], with
    the type variables of [scope], as {!Ts_names.ty} writes it. *)
val ty : scope -> Ts_infer.ty -> Ts_print.ty

(** [toplevel scope e] is the value of a top-level constant whose body is
    [e]. A module-level [const] has no block to hold statements, so a
    statement that would run before it is a private constant, which
    {!lifted} gives, as [evOd]. A match that must be a statement there,
    or whose scrutinee is not a variable or a property path, is the
    private arrow of its scrutinee, named after the constant with [Of],
    as [nightWeightOf] for [nightWeight], which the value calls with the
    scrutinee, so the call binds it.

    @raise CErrors.UserError
      if [e] holds a primitive array literal and an [Extract] directive
      maps [PrimArray.array], since the literal is the [PArray<A>] of the
      backend. *)
val toplevel : scope -> Ts_infer.expr -> Ts_print.expr

(** [func scope ~tparams ~self body] is the optional annotation and value of the top-level
    function [self] with the type parameters [tparams], over the variables
    of [scope]. The typed body [body] is [Lambda (_, bs, result, b)], and
    the arrow has one parameter per binder of [bs], the result type
    [result], and the statements of [b], ending in [return], as an
    expression when they are one [return], or the loop of its self calls
    in [b]. [fix] pairs each function of the mutually recursive group of
    [self], [self] included, with its typed body; it is [[]] when [self]
    is in no group, or when the group holds a member that the machine
    cannot take, one that is not a function or that the backend does not
    define, and the loop then takes the self calls of [self] alone.

    An eligible unary comparison is a helper factory applied to that
    original arrow, with its function type kept as the annotation.

    @raise CErrors.Anomaly if [body] is not a [Lambda]. *)
val func
  :  scope
  -> tparams:Ts_print.tparam list
  -> self:Extraction_plugin.Miniml.global
  -> fix:(Extraction_plugin.Miniml.global * Ts_infer.expr) list
  -> Ts_infer.expr
  -> Ts_print.ty option * Ts_print.expr

(** [constant scope ~tparams ~result e] is the arrow of no parameter, with
    the type parameters [tparams] and the result type [result], that
    returns [e]. It declares a constant whose type has type variables,
    which a [const] cannot bind, and a reference to such a constant calls
    it with its type arguments, as in [empty<Nat>()]. *)
val constant
  :  scope
  -> tparams:Ts_print.tparam list
  -> result:Ts_print.ty
  -> Ts_infer.expr
  -> Ts_print.expr

type unary_order

(** [unary_order env ~self e] is the certified recurrence of [e], the
    typed body of [self], when [e] is an exact monomorphic unary
    comparison, which takes two values of one unary type and matches on
    them, or [None] otherwise. *)
val unary_order
  :  Ts_env.t
  -> self:Extraction_plugin.Miniml.global
  -> Ts_infer.expr
  -> unary_order option

(** [unary_input env order] is the unary inductive type that the
    comparison [order] compares. *)
val unary_input : Ts_env.t -> unary_order -> Extraction_plugin.Miniml.global

(** [cancel_unary_successor env ~orders e] is the MiniML body that
    replaces [e], an exact two-parameter wrapper around a comparison of
    [orders], with the generated successor cancelled, or [None] if [e] is
    not such a wrapper. The replacement preserves the declaration's schema
    and arity and exposes new dependencies before names and imports are
    bound. *)
val cancel_unary_successor
  :  Ts_env.t
  -> orders:unary_order Extraction_plugin.Table.Refmap'.t
  -> Ts_infer.expr
  -> Extraction_plugin.Miniml.ml_ast option
