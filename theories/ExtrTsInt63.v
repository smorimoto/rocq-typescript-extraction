(** Extraction of the primitive 63-bit integers to TypeScript's [bigint].

    These are the operations of [Corelib.Numbers.Cyclic.Int63.PrimInt63].
    The type [int] is [bigint] whatever the preset, a value between [0]
    and [2^63 - 1], and this file realises every primitive on it with
    the semantics of the kernel's own implementation, [Uint63] in
    rocq-runtime: an unsigned result wraps with [BigInt.asUintN(63, ...)],
    a signed operation reads its arguments with [BigInt.asIntN(63, ...)]
    and wraps its result back, a division by zero gives [0] for the
    quotient and the dividend for the remainder, a shift by [63] or more
    gives [0], and [head0] and [tail0] of [0] give [63]. Bitwise operations
    and shifts use native bigint operators; unsigned results that can grow
    beyond 63 bits are wrapped with [BigInt.asUintN].

    [addc], [addcarryc], [subc], and [subcarryc] build their [carry] as an
    object with the tag of its constructor, [C0] or [C1], and the field
    [arg0], as the generated union of [CarryType.carry] declares them, and
    [mulc], [diveucl], and [diveucl_21] return the tuple of [ExtrTsBasic],
    which this file requires with its [comparison] for [compare] and
    [compares]. Like [ExtrTsBasic], require this file only where you
    extract to TypeScript. *)

From TypeScriptExtraction Require Import ExtrTsBasic.
From Corelib Require Import PrimInt63.

Extract Constant PrimInt63.lsl =>
  "((x: bigint, y: bigint): bigint => (y < 63n ? BigInt.asUintN(63, x << y) : 0n))".
Extract Constant PrimInt63.lsr =>
  "((x: bigint, y: bigint): bigint => (y < 63n ? x >> y : 0n))".
Extract Constant PrimInt63.asr =>
  "((x: bigint, y: bigint): bigint => {
  const sx = BigInt.asIntN(63, x);
  const sy = BigInt.asIntN(63, y);

  if (sy < 0n) {
    return 0n;
  }

  return BigInt.asUintN(63, sx >> sy);
})".
Extract Constant PrimInt63.land => "((x: bigint, y: bigint): bigint => x & y)".
Extract Constant PrimInt63.lor => "((x: bigint, y: bigint): bigint => x | y)".
Extract Constant PrimInt63.lxor => "((x: bigint, y: bigint): bigint => x ^ y)".

Extract Constant PrimInt63.add => "((x: bigint, y: bigint): bigint => BigInt.asUintN(63, x + y))".
Extract Constant PrimInt63.sub => "((x: bigint, y: bigint): bigint => BigInt.asUintN(63, x - y))".
Extract Constant PrimInt63.mul => "((x: bigint, y: bigint): bigint => BigInt.asUintN(63, x * y))".
Extract Constant PrimInt63.mulc =>
  "((x: bigint, y: bigint): readonly [bigint, bigint] => {
  const p = x * y;

  return [p >> 63n, BigInt.asUintN(63, p)];
})".
Extract Constant PrimInt63.div => "((x: bigint, y: bigint): bigint => (y === 0n ? 0n : x / y))".
Extract Constant PrimInt63.mod => "((x: bigint, y: bigint): bigint => (y === 0n ? x : x % y))".
Extract Constant PrimInt63.divs =>
  "((x: bigint, y: bigint): bigint => {
  const sy = BigInt.asIntN(63, y);

  return sy === 0n ? 0n : BigInt.asUintN(63, BigInt.asIntN(63, x) / sy);
})".
Extract Constant PrimInt63.mods =>
  "((x: bigint, y: bigint): bigint => {
  const sy = BigInt.asIntN(63, y);

  return sy === 0n ? x : BigInt.asUintN(63, BigInt.asIntN(63, x) % sy);
})".

Extract Constant PrimInt63.eqb => "((x: bigint, y: bigint): boolean => x === y)".
Extract Constant PrimInt63.ltb => "((x: bigint, y: bigint): boolean => x < y)".
Extract Constant PrimInt63.leb => "((x: bigint, y: bigint): boolean => x <= y)".
Extract Constant PrimInt63.ltsb =>
  "((x: bigint, y: bigint): boolean => BigInt.asIntN(63, x) < BigInt.asIntN(63, y))".
Extract Constant PrimInt63.lesb =>
  "((x: bigint, y: bigint): boolean => BigInt.asIntN(63, x) <= BigInt.asIntN(63, y))".

Extract Constant PrimInt63.addc =>
  "((x: bigint, y: bigint) => {
  const r = BigInt.asUintN(63, x + y);

  return r < x ? { arg0: r, tag: ""C1"" } : { arg0: r, tag: ""C0"" };
})".
Extract Constant PrimInt63.addcarryc =>
  "((x: bigint, y: bigint) => {
  const r = BigInt.asUintN(63, x + y + 1n);

  return r <= x ? { arg0: r, tag: ""C1"" } : { arg0: r, tag: ""C0"" };
})".
Extract Constant PrimInt63.subc =>
  "((x: bigint, y: bigint) => {
  const r = BigInt.asUintN(63, x - y);

  return y <= x ? { arg0: r, tag: ""C0"" } : { arg0: r, tag: ""C1"" };
})".
Extract Constant PrimInt63.subcarryc =>
  "((x: bigint, y: bigint) => {
  const r = BigInt.asUintN(63, x - y - 1n);

  return y < x ? { arg0: r, tag: ""C0"" } : { arg0: r, tag: ""C1"" };
})".

Extract Constant PrimInt63.diveucl =>
  "((x: bigint, y: bigint): readonly [bigint, bigint] => (y === 0n ? [0n, x] : [x / y, x % y]))".
Extract Constant PrimInt63.diveucl_21 =>
  "((xh: bigint, xl: bigint, y: bigint): readonly [bigint, bigint] => {
  if (y <= xh) {
    return [0n, 0n];
  }

  const n = (xh << 63n) + xl;

  return [n / y, n % y];
})".
Extract Constant PrimInt63.addmuldiv =>
  "((p: bigint, x: bigint, y: bigint): bigint => (p > 63n ? 0n : BigInt.asUintN(63, x << p) + (y >> (63n - p))))".

Extract Constant PrimInt63.compare =>
  "((x: bigint, y: bigint): ""Eq"" | ""Lt"" | ""Gt"" => {
  if (x < y) {
    return ""Lt"";
  }

  if (x > y) {
    return ""Gt"";
  }

  return ""Eq"";
})".
Extract Constant PrimInt63.compares =>
  "((x: bigint, y: bigint): ""Eq"" | ""Lt"" | ""Gt"" => {
  const sx = BigInt.asIntN(63, x);
  const sy = BigInt.asIntN(63, y);

  if (sx < sy) {
    return ""Lt"";
  }

  if (sx > sy) {
    return ""Gt"";
  }

  return ""Eq"";
})".

Extract Constant PrimInt63.head0 =>
  "((x: bigint): bigint => (x === 0n ? 63n : 63n - BigInt(x.toString(2).length)))".
Extract Constant PrimInt63.tail0 =>
  "((x: bigint): bigint => {
  if (x === 0n) {
    return 63n;
  }

  const digits = x.toString(2);

  return BigInt(digits.length - 1 - digits.lastIndexOf(""1""));
})".
