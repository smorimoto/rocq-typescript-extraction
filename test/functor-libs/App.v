From TypeScriptExtraction Require Import Number.
From FunctorLibs Require Import Sig Fun.

Module B := F A.

Definition four : nat := B.twice (B.twice 0).
