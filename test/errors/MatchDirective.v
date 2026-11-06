From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".

(* A directive gives one selector per constructor of an inductive type,
   with a test for each of several constructors and _ for a lone one. *)
Extract Inductive nat => "number" [ "0" "((n: number): number => n + 1)" ].
TypeScript Extract Match nat => [ "$0 === 0" ] [ "$0 > 0" "$0 - 1" ].
TypeScript Extract Match unit => [ _ ].

Redirect "MatchDirective1" Fail TypeScript Extract Match nat => [ "$0 === 0" ].
Redirect "MatchDirective2" Fail TypeScript Extract Match nat => [ "$0 === 0" ] [ _ "$0 - 1" ].
Redirect "MatchDirective3" Fail TypeScript Extract Match unit => [ "true" ].
Redirect "MatchDirective4" Fail TypeScript Extract Match Nat.add => [ "$0 === 0" ] [ "$0 > 0" "$0 - 1" ].

(* At extraction, a selector gives one expression per argument that
   extraction keeps, the code balances its brackets and quotes, and the
   type has an Extract Inductive, which maps the type the tests read. *)
Definition pred (n : nat) : nat := match n with O => O | S p => p end.
TypeScript Extract Match nat => [ "$0 === 0" ] [ "$0 > 0" "$0 - 1" "$0" ].
Redirect "MatchDirective5" Fail TypeScript Recursive Extraction pred.
TypeScript Extract Match nat => [ "$0 === 0" ] [ "$0 > 0" "($0 - 1" ].
Redirect "MatchDirective6" Fail TypeScript Recursive Extraction pred.
TypeScript Extract Match nat => [ "$0 === 0" ] [ "$0 > 0" "$0 - 1" ].
TypeScript Recursive Extraction pred.

Definition get (o : option nat) : nat := match o with Some n => n | None => 0 end.
TypeScript Extract Match option => [ "$0 !== undefined" "$0" ] [ "$0 === undefined" ].
Redirect "MatchDirective7" Fail TypeScript Recursive Extraction get.
