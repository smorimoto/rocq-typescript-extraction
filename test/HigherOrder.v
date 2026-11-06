From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

Module Type S.
  Parameter t : Type.
  Parameter z : t.
  Parameter next : t -> t.
End S.

(* A functor signature is an alias of a generic arrow type, from the
   interface of its parameter to the interface of its result, which lists
   the members of the result and declares its types. *)
Module Type FT (X : S).
  Inductive w := Wrap (x : X.t) | Nothing.
  Parameter twice : X.t -> X.t.
  Parameter map : (X.t -> X.t) -> w -> w.
End FT.

(* A parameter declared with a functor signature is typed by the alias,
   and an application inside the body is a local object, a member of the
   result, whose method-named members are bound after it. *)
Module H (X : S) (F : FT).
  Module FX := F X.
  Definition four : X.t := FX.twice (FX.twice X.z).
  Definition wrapped : FX.w := FX.map (fun x => x) (FX.Wrap X.z).
End H.

Module Double (X : S).
  Inductive w := Wrap (x : X.t) | Nothing.
  Definition twice (x : X.t) : X.t := X.next (X.next x).
  Definition map (f : X.t -> X.t) (v : w) : w :=
    match v with Wrap x => Wrap (f x) | Nothing => Nothing end.
End Double.

Module A.
  Definition t := nat.
  Definition z : t := 0.
  Definition next (n : t) : t := n + 1.
End A.

Module B := H A Double.

Definition v : nat := B.four + B.FX.twice 1.

(* A functor signature whose result is a module type under a constraint,
   and a functor sealed by it. *)
Module Type MAKE (X : S) := S with Definition t := X.t.

Module Id (X : S) : MAKE X.
  Definition t := X.t.
  Definition z := X.next X.z.
  Definition next := X.next.
End Id.

Module K (X : S) (M : MAKE).
  Module MX := M X.
  Definition z : X.t := MX.next MX.z.
End K.

Module C := K A Id.

TypeScript Extraction "higher-order.ts" H Double B v K Id C.
