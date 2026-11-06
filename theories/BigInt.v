(** The BigInt preset of TypeScript extraction: exact standard integers.

    [nat], [positive], [N], and [Z] are [bigint], using the existing
    [ExtrTsNatBigInt] and [ExtrTsBinNumsBigInt] realisers. Callers must pass
    nonnegative values for [nat] and [N], strictly positive values for
    [positive], and any integer for [Z]. These domains are not checked.

    Basic types use booleans, undefined, readonly tuples, and comparison
    literals. Primitive operations have the same mappings as [Number];
    floats remain binary64 and primitive integers remain bounded.
    Other inductives and unrelated arithmetic keep their generated code.
    The handwritten realisers are trusted, not proved correct.

    Mappings apply throughout the loaded environment. Loading [Number]
    before or after [BigInt] keeps the bigint mappings. Require individual
    [ExtrTs] theories directly for selective mappings. *)

From TypeScriptExtraction Require Export
  ExtrTsBasic ExtrTsNatBigInt ExtrTsBinNumsBigInt ExtrTsInt63 ExtrTsFloat
  ExtrTsPString ExtrTsPArray.
