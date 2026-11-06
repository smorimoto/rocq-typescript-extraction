(** Extraction of the primitive persistent arrays to TypeScript objects.

    These are the operations of [Corelib.Array.PrimArray]. The type
    [array A] is the interface [PArray<A>] whatever the preset,
    [{ readonly default: A; readonly items: readonly A[] }], which the
    backend declares where the type is, and this file realises every
    primitive on it with the semantics of the kernel's own implementation,
    [Parray] in rocq-runtime: [make] caps the length at [max_length],
    [4194303]; [get] of an index out of range is the default; [set] of an
    index in range is a new array, with [Array.prototype.with], and of an
    index out of range the array itself; and [copy] is the array itself,
    since no operation changes an array once built. An index is a
    [bigint] and a length a [number], and [Number] converts between them,
    exact on every index below [max_length].

    Like [ExtrTsBasic], require this file only where you extract to
    TypeScript. *)

From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
From Corelib Require Import PrimInt63 PrimArray.

Extract Constant PrimArray.max_length => "4_194_303n".
Extract Constant PrimArray.make =>
  "(<A>(n: bigint, d: A): PArray<A> => ({
  default: d,
  items: new Array<A>(Math.min(Number(n), 4_194_303)).fill(d),
}))".
Extract Constant PrimArray.get =>
  "(<A>(a: PArray<A>, i: bigint): A => {
  if (i >= BigInt(a.items.length)) {
    return a.default;
  }

  const index = Number(i);
  const value = a.items[index];

  if (value !== undefined) {
    return value;
  }

  const present = a.items
    .slice(index, index + 1)
    .values()
    .next();

  return present.done ? a.default : present.value;
})".
Extract Constant PrimArray.default => "(<A>(a: PArray<A>): A => a.default)".
Extract Constant PrimArray.set =>
  "(<A>(a: PArray<A>, i: bigint, v: A): PArray<A> => {
  if (i < BigInt(a.items.length)) {
    return { default: a.default, items: a.items.with(Number(i), v) };
  }

  return a;
})".
Extract Constant PrimArray.length => "(<A>(a: PArray<A>): bigint => BigInt(a.items.length))".
Extract Constant PrimArray.copy => "(<A>(a: PArray<A>): PArray<A> => a)".
