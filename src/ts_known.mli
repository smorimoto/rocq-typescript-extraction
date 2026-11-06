(** Reduction of matches on known constructors.

    TypeScript narrows a [const] declared with a union type to the type of
    its initialiser at every reference in its file. It narrows a variable
    or property path to the constructor of the [case] that tests it.
    Reduction removes branches for constructors excluded by that
    narrowing, so the remaining cases and field accesses typecheck.

    Constant constructors have known values. This knowledge propagates
    through [let]-bound locals, globals of the same file, and matches
    whose branches all have known values. A constructor pattern narrows
    its scrutinee to that constructor. A wildcard narrows it to the
    constructors that no earlier branch names.

    A constructor with arguments is not known from its value, since its
    function returns the union. Inside a function a pattern variable is
    not known from an enclosing branch. The output reads it as a property
    of the scrutinee, and TypeScript does not keep the narrowing of a
    property inside a function. *)

open Extraction_plugin

(** [reduce struc ~separate] is [struc] with unreachable match branches
    removed. A sole reachable branch replaces the match when it binds no
    variables. Otherwise, the match retains that branch. An
    [Extract Inductive] match function is left whole unless its sole
    reachable branch binds no variables.

    When several branches remain and others are removed, the last branch
    for a constant constructor becomes a wildcard if no wildcard is
    present. Matches that reach every branch or no branch are unchanged.

    Globals are known within each file of [struc] when [separate] is
    [true], and across all of [struc] otherwise. Globals realised by
    [Extract Constant] are not known. *)
val reduce : Miniml.ml_structure -> separate:bool -> Miniml.ml_structure
