From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

Module Type S.
  Parameter t : Type.
  Parameter z : t.
  Parameter next : t -> t.
End S.

(* A module nested in the body is the object of its members, typed by an
   interface of its own, and a module type declared in the body is an
   interface at the top level, both over the type parameters they
   mention. *)
Module F (X : S).
  Module Inner.
    Inductive cell := Full (x : X.t) | Empty.
    Definition fill (x : X.t) : cell := Full x.
    Definition first : cell := fill X.z.
  End Inner.
  Module Type PAIRED.
    Parameter both : X.t * X.t.
  End PAIRED.
  Definition unwrap (c : Inner.cell) : X.t := match c with Inner.Full x => x | Inner.Empty => X.z end.
  Definition twice : X.t := X.next (unwrap Inner.first).
End F.

Module A.
  Definition t := nat.
  Definition z : t := 0.
  Definition next (n : t) : t := S n.
End A.

Module B := F A.

Definition v : nat := B.unwrap (B.Inner.fill 4) + B.twice.

(* A type of the body mapped by Extract Inductive keeps the realisers it
   needs as locals of the body. *)
Module Type FLAGGED.
  Parameter t : Type.
  Parameter z : t.
End FLAGGED.

Module Flags (X : FLAGGED).
  Inductive flag := On | Off.
  Extract Inductive flag => "boolean" [ "true" "false" ]
    "(<R>(on: () => R, off: () => R, b: boolean): R => (b ? on() : off()))".
  Definition toggle (f : flag) : flag := match f with On => Off | Off => On end.
  Definition pick (f : flag) : X.t := match f with On => X.z | Off => X.z end.
End Flags.

Module FA := Flags A.

Definition on : bool := match FA.toggle FA.Off with FA.On => true | FA.Off => false end.

TypeScript Extraction "bodies.ts" F B v Flags FA on.
