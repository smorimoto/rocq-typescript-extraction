From CompCertTests Require Import Programs.
From compcert.common Require Import Errors.
From Stdlib Require Import Extraction ExtrOcamlBasic ExtrOcamlNatInt.

Extraction Inline Errors.bind Errors.bind2.
Extraction "reference.ml" reference_results.
