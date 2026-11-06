export interface PArray<A> {
  readonly default: A;
  readonly items: readonly A[];
}

export const make: <A>(_0: bigint, _1: A) => PArray<A> = <A>(
  n: bigint,
  d: A
): PArray<A> => ({
  default: d,
  items: new Array<A>(Math.min(Number(n), 4_194_303)).fill(d),
});

export const get0: <A>(_0: PArray<A>, _1: bigint) => A = <A>(
  a: PArray<A>,
  i: bigint
): A => {
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
};
