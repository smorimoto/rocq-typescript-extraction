(** Extraction of the primitive strings to TypeScript's [string].

    These are the operations of [Corelib.Strings.PrimString]. The type
    [string] is [string] whatever the preset, with one UTF-16 code unit
    per byte, as a primitive string literal is written, and this file
    realises every primitive on it with the semantics of the kernel's own
    implementation, [Pstring] in rocq-runtime: [make] keeps the low byte
    of its character and caps the length at [max_length], [16777211];
    [get] of an index out of range is [0]; [sub] of an offset out of range
    is the empty string and of a length past the end is the suffix from
    the offset; [cat] keeps the longest prefix of its second argument that
    fits in [max_length]; and [compare] orders by code unit, which is byte
    order. An index is a [bigint] and a length a [number], and [Number]
    converts between them, exact on every index below [max_length].

    [compare] returns the [comparison] of [ExtrTsBasic], which this file
    requires. Like [ExtrTsBasic], require this file only where you extract
    to TypeScript. *)

From TypeScriptExtraction Require Import ExtrTsBasic.
From Corelib Require Import PrimInt63 PrimString.

Extract Constant PrimString.max_length => "16_777_211n".
Extract Constant PrimString.make =>
  "((i: bigint, c: bigint): string => {
  const byte = String.fromCharCode(Number(c % 256n));

  return byte.repeat(Math.min(Number(i), 16_777_211));
})".
Extract Constant PrimString.length => "((s: string): bigint => BigInt(s.length))".
Extract Constant PrimString.get =>
  "((s: string, i: bigint): bigint => BigInt(s.charCodeAt(Number(i)) || 0))".
Extract Constant PrimString.sub =>
  "((s: string, off: bigint, len: bigint): string => s.slice(Number(off), Number(off) + Number(len)))".
Extract Constant PrimString.cat =>
  "((s1: string, s2: string): string => (s1 + s2).slice(0, 16_777_211))".
Extract Constant PrimString.compare =>
  "((s1: string, s2: string): ""Eq"" | ""Lt"" | ""Gt"" => {
  if (s1 < s2) {
    return ""Lt"";
  }

  if (s1 > s2) {
    return ""Gt"";
  }

  return ""Eq"";
})".
