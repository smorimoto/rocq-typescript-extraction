const __fail = (message: string): never => {
  throw new Error(message);
};

const add = (_unused: bigint, _unused0: bigint): bigint =>
  __fail("AXIOM TO BE REALIZED (Corelib.Numbers.Cyclic.Int63.PrimInt63.add)");

export interface PArray<A> {
  readonly default: A;
  readonly items: readonly A[];
}

const get0 = <A>(_unused: PArray<A>, _unused0: bigint): A =>
  __fail("AXIOM TO BE REALIZED (Corelib.Array.PrimArray.get)");

export const answer = 42n;
export const half = 0.5;
export const hello = "hello";
export const digits: PArray<bigint> = { default: 0n, items: [1n, 2n, 3n] };
export const wrap = <A>(x: A): PArray<A> => ({ default: x, items: [] });

export const nested: PArray<PArray<bigint>> = {
  default: wrap(0n),
  items: [digits],
};

export const plusSeven = (x: bigint): bigint => {
  const y = 7n;

  return add(x, y);
};

export const first = (a: PArray<bigint>): bigint => get0(a, 0n);

export interface Cell {
  readonly count: bigint;
  readonly label: string;
}

export const three: Cell = { count: 3n, label: "three" };
