(** Extraction of basic Rocq types to native TypeScript ones.

    [bool] and [sumbool] are [boolean], [unit] is [undefined],
    [prod A B] is the tuple [readonly [A, B]], whose elements [fst] and
    [snd] read, and [comparison] is the union of the string literals
    ["Eq"], ["Lt"], and ["Gt"], so a match on it is a [switch] over the
    strings.

    A match on each of these types is written inline, as [b ? x : y] on
    a [boolean] or as the reads [p[0]] and [p[1]] of a tuple, through the
    [TypeScript Extract Match] directives below. A match function is
    still declared for custom code that calls one: it takes one function
    per constructor, then the value matched, and a constructor without
    arguments gets a function of no arguments.

    Both [TypeScriptExtraction.Number] and [TypeScriptExtraction.BigInt] require this
    file. These directives are shared with OCaml extraction, so require
    this file only where you extract to TypeScript. *)

From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".

Extract Inductive bool => "boolean" [ "true" "false" ]
  "(<R>(t: () => R, f: () => R, b: boolean): R => (b ? t() : f()))".
TypeScript Extract Match bool => [ "$0" ] [ "!$0" ].

Extract Inductive sumbool => "boolean" [ "true" "false" ]
  "(<R>(l: () => R, r: () => R, b: boolean): R => (b ? l() : r()))".
TypeScript Extract Match sumbool => [ "$0" ] [ "!$0" ].

Extract Inductive unit => "undefined" [ "undefined" ].
TypeScript Extract Match unit => [ _ ].

Extract Inductive comparison => """Eq"" | ""Lt"" | ""Gt""" [ """Eq""" """Lt""" """Gt""" ].

Extract Constant andb => "((a: boolean, b: boolean): boolean => a && b)".
Extract Constant orb => "((a: boolean, b: boolean): boolean => a || b)".
Extract Constant negb => "((b: boolean): boolean => !b)".

Extract Inductive prod => "readonly [$1, $2]" [ "(<A, B>(a: A, b: B): readonly [A, B] => [a, b])" ]
  "(<A, B, R>(f: (a: A, b: B) => R, p: readonly [A, B]): R => f(p[0], p[1]))".
TypeScript Extract Match prod => [ _ "$0[0]" "$0[1]" ].

Extract Constant fst => "(<A, B>(p: readonly [A, B]): A => p[0])".
Extract Constant snd => "(<A, B>(p: readonly [A, B]): B => p[1])".
