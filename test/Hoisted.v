From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

Module Type COUNTED.
  Parameter t : Type.
  Parameter z : t.
  Parameter count : t -> nat.
End COUNTED.

Module Type TOTAL. Parameter total : nat. End TOTAL.

(* A body function that reads nothing of the body is hoisted to the top
   level under the functor's name, and a member of the body that calls it
   refers to it by that name. *)
Module F (X : COUNTED).
  Definition bump (n : nat) : nat := n + 1.
  Definition total : nat := bump (X.count X.z).
End F.

(* The same through a module type that seals the body, which lists the
   caller and not the hoisted function. *)
Module H (X : COUNTED) : TOTAL.
  Definition bump (n : nat) : nat := n + 1.
  Definition total : nat := bump (X.count X.z).
End H.

(* A mutually recursive group is hoisted whole, and a member of the body
   calls one of its members by its top-level name. *)
Module G (X : COUNTED).
  Fixpoint even (n : nat) : bool := match n with 0 => true | S k => odd k end
  with odd (n : nat) : bool := match n with 0 => false | S k => even k end.
  Definition balanced : bool := even (X.count X.z).
End G.

(* A function of a module nested in the body that reads nothing of the
   body is hoisted too, under the path of its module, whose object holds
   it by that name. *)
Module N (X : COUNTED).
  Module Inner.
    Definition twice (n : nat) : nat := n + n.
    Module Deep. Definition thrice (n : nat) : nat := n + n + n. End Deep.
  End Inner.
  Definition total : nat := Inner.twice (Inner.Deep.thrice (X.count X.z)).
End N.

(* A body whose every member is hoisted returns the object of them as the
   expression of the arrow. *)
Module Only (X : COUNTED).
  Definition double (n : nat) : nat := n + n.
End Only.

TypeScript Extraction "hoisted.ts" F H G N Only.
