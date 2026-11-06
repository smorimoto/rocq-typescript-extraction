From TypeScriptExtraction Require Import Number.
From Stdlib Require Import List.
Import ListNotations.
Set Universe Polymorphism.
Set Extraction Output Directory ".".

(* A selected Type in a result cannot be approximated by never. *)
Definition first_type (types : list Type) : Type :=
  match types with [] => nat | first :: _ => first end.

Definition keep_first (types : list Type) (value : first_type types) := value.

Redirect "PositiveCurriedType" Fail TypeScript Extraction "positive.ts" keep_first.

(* Two function inputs reverse variance twice: the unknown type is positive. *)
Definition nested (result : Type) (inputs : list Type) : Type :=
  fold_right (fun input rest => (input -> nat) -> rest) result inputs.

Definition keep_nested (inputs : list Type) (action : nested nat inputs) := action.

Redirect "NestedCurriedType" Fail TypeScript Extraction "nested.ts" keep_nested.

(* A recursive call that changes a type parameter is not the same alias at
   the captured parameters of its enclosing definition. *)
Definition changing (result : Type) (steps : nat) : Type :=
  (fix loop (current : Type) (remaining : nat) : Type :=
     match remaining with
     | O => current
     | S next => loop (list current) next
     end) result steps.

Definition keep_changing {result : Type} (steps : nat)
  (value : changing result steps) := value.

Redirect "ChangingCurriedType" Fail TypeScript Extraction "changing.ts" keep_changing.

(* Keeping a Type parameter fixed is insufficient when another recursive
   parameter changes which result the empty case selects. *)
Definition alternating (inputs : list Type) : Type :=
  (fix loop (flag : bool) (remaining : list Type) : Type :=
     match remaining with
     | [] => if flag then nat else bool
     | input :: rest => input -> loop (negb flag) rest
     end) false inputs.

Definition keep_alternating (inputs : list Type) (action : alternating inputs) := action.

Redirect "AlternatingCurriedType" Fail
  TypeScript Extraction "alternating.ts" keep_alternating.

(* A stuck conditional in an input needs a lower approximation, including
   when a named type family hides the conditional. *)
Definition select_type (flag : bool) : Type := if flag then nat else bool.

Definition indirect_negative (result : Type) (flags : list bool) : Type :=
  fold_right (fun flag rest => select_type flag -> rest) result flags.

Definition keep_indirect (result : Type) (flags : list bool)
  (action : indirect_negative result flags) := action.

Redirect "IndirectNegativeCurriedType" Fail
  TypeScript Extraction "indirect-negative.ts" keep_indirect.

Definition inline_negative (result : Type) (flags : list bool) : Type :=
  fold_right (fun (flag : bool) rest => (if flag then nat else bool) -> rest) result flags.

Definition keep_inline (result : Type) (flags : list bool)
  (action : inline_negative result flags) := action.

Redirect "InlineNegativeCurriedType" Fail
  TypeScript Extraction "inline-negative.ts" keep_inline.

(* A selector over a non-enumeration has no lifted argument to check, but
   its union is still only an upper approximation. *)
Definition select_natural (n : nat) : Type :=
  match n with O => nat | S _ => bool end.

Definition natural_negative (result : Type) (indices : list nat) : Type :=
  fold_right (fun n rest => select_natural n -> rest) result indices.

Definition keep_natural (result : Type) (indices : list nat)
  (action : natural_negative result indices) := action.

Redirect "NaturalNegativeCurriedType" Fail
  TypeScript Extraction "natural-negative.ts" keep_natural.
