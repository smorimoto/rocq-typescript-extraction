From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
From TypeScriptExtraction Require Import ExtrTsFloat.
Set Warnings "+typescript-extraction-unchecked-casts".
From Corelib Require Import PrimFloat.

(* A float literal as the lone argument of a call, bare once the constant
   that holds it is unfolded, where the argument alone overflows the
   line. *)
Definition is_nan_applied_where_the_argument_alone_overflows : bool :=
  Eval cbv delta [nan] in is_nan nan.

TypeScript Extraction "floats.ts"
  classify abs sqrt opp eqb ltb leb compare Leibniz.eqb mul add sub div of_uint63
  normfr_mantissa frshiftexp ldshiftexp next_up next_down infinity neg_infinity nan one
  zero neg_zero two is_nan is_zero is_infinity is_finite get_sign
  is_nan_applied_where_the_argument_alone_overflows.
