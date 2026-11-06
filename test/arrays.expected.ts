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

export const default0: <A>(_0: PArray<A>) => A = <A>(a: PArray<A>): A =>
  a.default;

export const set0: <A>(_0: PArray<A>, _1: bigint, _2: A) => PArray<A> = <A>(
  a: PArray<A>,
  i: bigint,
  v: A
): PArray<A> => {
  if (i < BigInt(a.items.length)) {
    return { default: a.default, items: a.items.with(Number(i), v) };
  }

  return a;
};

export const length: <A>(_0: PArray<A>) => bigint = <A>(a: PArray<A>): bigint =>
  BigInt(a.items.length);

export const copy: <A>(_0: PArray<A>) => PArray<A> = <A>(
  a: PArray<A>
): PArray<A> => a;

export const maxLength = 4_194_303n;
export const digits: PArray<bigint> = { default: 0n, items: [1n, 2n, 3n] };
export const bumped: PArray<bigint> = set0(digits, 1n, 9n);
export const third: bigint = get0(digits, 2n);
export const beyond: bigint = get0(digits, 5n);
