(** The [TypeScript Extract Match] directive.

    [TypeScript Extract Match t => [ "test" "arg" ... ] ... [ "test" "arg" ... ].]
    gives the inductive type [t], which [Extract Inductive] maps to a
    TypeScript type, one selector per constructor, in declaration order,
    so that a match on [t] lowers inline, as {!Ts_expr} describes,
    instead of calling the match function of [Extract Inductive]. A
    selector is the test that picks the constructor, then the expression
    that reads each argument of the constructor that extraction keeps,
    with [$0] standing for the value matched. Each test holds exactly for
    the values of its constructor, whatever the other tests say, so a
    match may test the constructors in any order and leave the last one
    untested. The selector of the one constructor of a type is written
    [_] in place of its test, since no match tests it. The directive is
    persisted in the [.vo] file and shared across files, as
    [Extract Inductive] is, and a later directive for the same type
    replaces the earlier one. *)

open Extraction_plugin

(** The type for selectors. *)
type selector =
  { test : string option
    (** The code that picks the constructor, or [None] for the one
        constructor of its type, whose selector is written with [_]. *)
  ; args : string list (** The code of each argument. *)
  }

(** [extract_match q selectors] registers the directive for the inductive
    type [q].

    Raises [CErrors.UserError]
    if [q] is not an inductive type, if [selectors] has not one selector
    per constructor, if the selector of a lone constructor is not
    written with [_], or if one of several is. *)
val extract_match : Libnames.qualid -> selector list -> unit

(** [find r] is the selectors of the directive for the inductive type
    [r], in declaration order, if one is registered. *)
val find : Miniml.global -> selector array option
