From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".
From Corelib Require Import Lists.ListDef.

(* A module type with abstract and concrete types, values, an inductive
   with its recursors, and nested modules, named by the functors that take
   it, so it enters the structure. *)
Module Type S.
  Parameter t : Type.
  Parameter u : Type.
  Definition pair := (t * u)%type.
  Inductive w := W (x : t) | Nothing.
  Parameter z : t.
  Parameter f : t -> u.
  Parameter g : u -> t.
  Parameter pick : bool -> w -> t.
  Module Deep. Parameter d : t. End Deep.
End S.

Module Type COUNTED. Parameter count : nat. End COUNTED.

Module Type NOTHING. End NOTHING.

(* A body whose values mention both abstract types, and one mentioning
   only t. *)
Module F (X : S).
  Definition twice (x : X.t) : X.t := X.g (X.f x).
  Definition w : X.u := X.f X.z.
  Definition both : X.pair := (X.z, w).
  Definition deep : X.t := X.pick true (X.W X.Deep.d).
End F.

(* A body inductive mentioning X.t, with a constructor function, a
   constant constructor, and a match. *)
Module Boxes (X : S).
  Inductive box := Full (x : X.t) | Empty.
  Definition some : box := Full X.z.
  Definition get (b : box) : X.t := match b with Full x => x | Empty => X.z end.
  Fixpoint even (n : nat) : bool := match n with 0 => true | S k => odd k end
  with odd (n : nat) : bool := match n with 0 => false | S k => even k end.
End Boxes.

(* Parameter members named like the methods a preset reads specially are
   bound at the top of the body, suffixed under a top-level map. *)
Module Type LISTS.
  Parameter t : Type.
  Parameter z : t.
  Parameter xs : list t.
  Parameter map : (t -> t) -> list t -> list t.
  Parameter sort : list t -> t -> list t.
End LISTS.

Definition map (n : nat) : nat := n.

Module Sorted (L : LISTS).
  Definition ys : list L.t := L.sort (L.map (fun x => x) L.xs) L.z.
End Sorted.

(* A parameter that no member reads is marked unused, and a memberless
   module type is an empty record. *)
Module Counter (N : NOTHING) (C : COUNTED).
  Definition next : nat := C.count + 1.
End Counter.

(* A functor in a module is a member of its object. *)
Module Holder.
  Module Id (X : S). Definition same : X.t := X.z. End Id.
End Holder.

TypeScript Extraction "functors.ts" F Boxes Sorted Counter Holder map.
