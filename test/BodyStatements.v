From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* The private constants of a member of a functor body: the arrow of the
   match of twice and the generic id read nothing of the body, so they
   go to the top level, and the arrow of the match of pick reads X.n, so
   it stays in the body. *)
Module Type S.
  Parameter n : nat.
  Parameter b : bool.
End S.

Module F (X : S).
  Definition twice : nat := match X.n with O => 0 | S k => k + k end.

  Definition pick : nat :=
    match X.b with
    | true => match X.n with O => 1 | S k => k + k end
    | false => 2
    end.

  Definition ids : nat :=
    let id := fun (A : Type) (x : A) => x in
    id nat X.n + (if id bool X.b then 1 else 0).
End F.

Module D.
  Definition n := 3.
  Definition b := true.
End D.

Module G := F D.

TypeScript Extraction "body-statements.ts" F G.
