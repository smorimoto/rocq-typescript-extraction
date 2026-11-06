(** The Number preset of TypeScript extraction, and the default.

    This file maps Rocq types to their TypeScript counterparts, so that
    TypeScript code can pass and compare their values directly:

    - [bool] and [sumbool] are [boolean], [unit] is [undefined],
      [prod A B] is [readonly [A, B]], and [comparison] is the union of
      the string literals ["Eq"], ["Lt"], and ["Gt"], from [ExtrTsBasic];
    - [nat] is [number], from [ExtrTsNatNumber];
    - [positive], [N], and [Z] are [number], from [ExtrTsBinNumsNumber];
    - the primitive [int], [float], [string], and [array A] are [bigint],
      [number], [string], and [PArray<A>] under every preset, and their
      operations are realised with the semantics of the kernel's own
      implementations by [ExtrTsInt63], [ExtrTsFloat], [ExtrTsPString],
      and [ExtrTsPArray], which also make [float_comparison] and
      [float_class] unions of string literals.

    The safe integer range of [number] is [-(2^53 - 1)] through [2^53 - 1].
    Require [BigInt] instead for exact [bigint] standard integers.
    Every other inductive keeps its generated encoding.
    Require individual [ExtrTs] theories directly for selective mappings.
    Mappings apply throughout the loaded environment, including through
    dependencies. Loading [BigInt] and [Number] in either order keeps bigint
    mappings. *)

From TypeScriptExtraction Require Export
  ExtrTsBasic ExtrTsNatNumber ExtrTsBinNumsNumber ExtrTsInt63 ExtrTsFloat
  ExtrTsPString ExtrTsPArray.
