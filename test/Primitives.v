From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts,+extraction-axiom-to-realize".
From Corelib Require Import PrimInt63 PrimString PrimFloat.

Open Scope uint63_scope.

Definition answer : int := 42.
Definition max_int : int := 9223372036854775807.
Definition sum (x y : int) : int := PrimInt63.add x y.
Definition square (x : int) : int := PrimInt63.mul x x.
Definition is_answer (x : int) : bool := PrimInt63.eqb x answer.
Definition describe (x : int) : string :=
  if is_answer x then "the answer"%pstring else "a number"%pstring.

Definition greeting : string := "héllo, "%pstring.
Definition greet (name : string) : string := PrimString.cat greeting name.
Definition greet_length (name : string) : int := PrimString.length (greet name).

Definition half : float := 0.5%float.
Definition third : float := (1 / 3)%float.
Definition minus_zero : float := (-0)%float.

Inductive axis := X | Y.
Definition is_x (a : axis) : bool := match a with X => true | Y => false end.
Definition horizontal : bool := is_x X.

TypeScript Extraction "primitives.ts"
  answer max_int sum square is_answer describe greeting greet greet_length
  half third minus_zero horizontal.
