From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

Inductive opcode := Op0 | Op1 | Op2 | Op3 | Op4 | Op5 | Op6 | Op7
  | Op8 | Op9 | Op10 | Op11 | Op12 | Op13 | Op14 | Op15
  | Op16 | Op17 | Op18 | Op19 | Op20 | Op21 | Op22 | Op23.

Fixpoint branch_count (n : nat) (op : opcode) : nat :=
  match n with
  | O => 0
  | S m =>
    match op with
    | Op0 => branch_count m op + 1
    | Op1 => branch_count m op + 2
    | Op2 => branch_count m op + 3
    | Op3 => branch_count m op + 4
    | Op4 => branch_count m op + 5
    | Op5 => branch_count m op + 6
    | Op6 => branch_count m op + 7
    | Op7 => branch_count m op + 8
    | Op8 => branch_count m op + 9
    | Op9 => branch_count m op + 10
    | Op10 => branch_count m op + 11
    | Op11 => branch_count m op + 12
    | Op12 => branch_count m op + 13
    | Op13 => branch_count m op + 14
    | Op14 => branch_count m op + 15
    | Op15 => branch_count m op + 16
    | Op16 => branch_count m op + 17
    | Op17 => branch_count m op + 18
    | Op18 => branch_count m op + 19
    | Op19 => branch_count m op + 20
    | Op20 => branch_count m op + 21
    | Op21 => branch_count m op + 22
    | Op22 => branch_count m op + 23
    | Op23 => branch_count m op + 24
    end
  end.

TypeScript Extraction "complex-recursion.ts" opcode branch_count.
