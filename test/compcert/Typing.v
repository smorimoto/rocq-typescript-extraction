From compcert.common Require Import Errors.
From compcert.cfrontend Require Import Ctypes.
From CompCertTests Require Import Programs.
From TypeScriptExtraction Require Import BigInt.

Set Warnings "+typescript-extraction-unchecked-casts".

(* Match CompCert's extraction setup so recursive calls under bind are exposed. *)
Extraction Inline Errors.bind Errors.bind2.

TypeScript Extraction "typing.ts"
  check_program integer Ctypes.build_composite_env Ctypes.layout_struct.

TypeScript Extraction "reference.ts" reference_results.
