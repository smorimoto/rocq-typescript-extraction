From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".

(* A match function is one callback per constructor. Narrowing the
   scrutinee does not drop a callback, because the call would no longer
   be that function. A branch that binds nothing is still its body. *)
Inductive colour := Red | Mix (n : nat).

Extract Inductive colour =>
  "{ readonly tag: ""red"" } | { readonly tag: ""mix""; readonly n: Nat }"
  [ "{ tag: ""red"" }"
    "(n: Nat): { readonly tag: ""mix""; readonly n: Nat } => ({ tag: ""mix"", n })" ]
  "(<R>(onRed: () => R, onMix: (n: Nat) => R, c: { readonly tag: ""red"" } | { readonly tag: ""mix""; readonly n: Nat }): R => (c.tag === ""red"" ? onRed() : onMix(c.n)))".

Definition nested (c : colour) : nat :=
  match c with
  | Red => 0
  | Mix n => match c with Red => 2 | Mix k => k end
  end.

Definition of_red (c : colour) : nat :=
  match c with
  | Mix _ => 2
  | Red => match c with Red => 0 | Mix _ => 4 end
  end.

Inductive box := Box (n : nat) | Empty.

Extract Inductive box =>
  "{ readonly tag: ""box""; readonly n: Nat } | { readonly tag: ""empty"" }"
  [ "(n: Nat): { readonly tag: ""box""; readonly n: Nat } => ({ tag: ""box"", n })"
    "{ tag: ""empty"" }" ]
  "(<R>(onBox: (n: Nat) => R, onEmpty: () => R, b: { readonly tag: ""box""; readonly n: Nat } | { readonly tag: ""empty"" }): R => (b.tag === ""box"" ? onBox(b.n) : onEmpty()))".

Definition only_box (b : box) : nat :=
  match b with
  | Empty => 0
  | Box n => match b with Box k => k | Empty => 1 end
  end.

TypeScript Extraction "known-custom.ts" nested of_red only_box.
