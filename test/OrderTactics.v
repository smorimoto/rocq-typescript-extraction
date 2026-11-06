From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* The shape of Stdlib's OrdersTac: module types applied to a parameter,
   built with <+, a functor over them that includes another applied to
   its parameters, and a functor signature whose parameter is declared
   the same way, which an implementation may read whole. *)
Module Type Typ. Parameter t : Type. End Typ.
Module Type HasLe (Import T : Typ). Parameter le : t -> t -> bool. End HasLe.
Module Type HasEqb (Import T : Typ). Parameter eqb : t -> t -> bool. End HasEqb.
Module Type EqLe := Typ <+ HasLe.
Module Type IsTotal (O : EqLe). Parameter le_total : O.t -> O.t -> bool. End IsTotal.
Module Type IsBoth (O : EqLe) := IsTotal O <+ HasEqb O.

Module Facts (Import O : EqLe) (Import P : IsBoth O).
  Definition lt (x y : t) : bool := andb (le x y) (negb (eqb x y)).
End Facts.

Module MakeTac (Import O : EqLe) (Import P : IsBoth O).
  Include Facts O P.
  Definition cmp (x y : t) : bool := orb (lt x y) (le_total x y).
End MakeTac.

Module Type TAC (O : EqLe) (P : IsBoth O).
  Parameter cmp : O.t -> O.t -> bool.
End TAC.

Module Use (F : TAC).
  Module N.
    Definition t := nat.
    Definition le := Nat.leb.
    Definition le_total := Nat.leb.
    Definition eqb := Nat.eqb.
  End N.
  Module T := F N N.
  Definition go : bool := T.cmp 3 1.
End Use.

Module N.
  Definition t := nat.
  Definition le := Nat.leb.
  Definition le_total := Nat.leb.
  Definition eqb := Nat.eqb.
End N.

Module T := MakeTac N N.
Module U := Use MakeTac.

Definition go : bool * bool := (T.lt 1 2, T.cmp 2 2).
Definition used : bool := U.go.

TypeScript Extraction "order-tactics.ts" MakeTac Use go used.
