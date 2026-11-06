From TypeScriptExtraction Require Import BigInt.
Set Warnings "+typescript-extraction-unchecked-casts".
From Bench Require Import Sorts Bst Fib Pow EvenOdd Integers Bitsets.

TypeScript Extraction "sorts.ts" merge_sort.
TypeScript Extraction "bst.ts" Bst.empty Bst.insert member.
TypeScript Extraction "fib.ts" fib_iter.
TypeScript Extraction "pow.ts" pow_bin.
TypeScript Extraction "even-odd.ts" even odd.
TypeScript Extraction "integers.ts" collatz_total gcd.
TypeScript Extraction "bitsets.ts" subset_sums.
