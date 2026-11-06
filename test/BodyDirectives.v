From TypeScriptExtraction Require Import Number.

Module Type S. Parameter t : Type. Parameter z : t. End S.

(* An Extract Constant in a functor body replaces the body's definition,
   whether or not the functor is applied, and its code reads nothing of
   the body, so it is declared at the top level. *)
Module F (X : S).
  Definition double (n : nat) : nat := n + n.
  Extract Constant double => "(n) => 2 * n".
  Definition same (n : nat) : nat := n.
  Extract Inlined Constant same => "Math.abs".
  Definition four : nat := same (double 2).
  Definition keep : X.t := X.z.
End F.

Module A. Definition t := nat. Definition z : t := 0. End A.
Module B := F A.

Definition ten : nat := B.double 5.

(* A directive whose type mentions an abstract type of a parameter is
   generic over it at the top level, and one in a module nested in the
   body is hoisted under the module's path. *)
Module G (X : S).
  Definition pick (x : X.t) (y : X.t) : X.t := x.
  Extract Constant pick => "(x, _y) => x".
  Module Inner.
    Definition half (n : nat) : nat := Nat.div2 n.
    Extract Constant half => "(n) => Math.floor(n / 2)".
  End Inner.
  Definition chosen : X.t := pick X.z X.z.
  Definition four : nat := Inner.half 9.
End G.

(* A functor defined as an application of another applies it, whose
   body has the directive; an Include in a body brings the directives of
   the included functor or module. *)
Module FA (Y : S) := F Y.
Module C := FA A.

Module Base.
  Definition triple (n : nat) : nat := n + n + n.
  Extract Constant triple => "(n) => 3 * n".
End Base.

Module I (X : S).
  Include F X.
  Include Base.
  Definition nine : nat := triple 3.
End I.

Module IA := I A.

Definition sum : nat := C.four + IA.nine + IA.double 1.

TypeScript Extraction "body-directives.ts" F B ten G FA C BodyDirectives.I IA sum.
