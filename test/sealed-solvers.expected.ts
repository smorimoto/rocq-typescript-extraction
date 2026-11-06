const s = (n: number): number => n + 1;

const add: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n + m;

export interface LAT<T> {
  readonly bot: T;
  readonly lub: (_0: T, _1: T) => T;
}

export interface SOLVER<LT> {
  readonly L: LAT<LT>;
  readonly run: (_0: number) => LT;
}

const Inner = <T>(X: LAT<T>): SOLVER<T> => {
  const run = (n: number): T => (n === 0 ? X.bot : X.lub(X.bot, X.bot));

  return { L: X, run };
};

export type OuterDSLT<T> = T;

export const Outer = <T>(Y: LAT<T>): SOLVER<T> => {
  const DS = Inner<T>(Y);
  const run = (n: number): T => Y.lub(DS.run(n), Y.bot);

  return { L: Y, run };
};

export type NestedOLT<T> = T;

export interface NestedResult<T> {
  readonly O: SOLVER<T>;
  readonly twice: (n: number) => T;
}

export const Nested = <T>(Z: LAT<T>): NestedResult<T> => {
  const O = Outer<T>(Z);
  const twice0 = (n: number): T => Z.lub(O.run(n), O.run(n));

  return { O, twice: twice0 };
};

const NatLat$bot: number = s(s(s(s(s(s(s(0)))))));
const NatLat$lub = (x: number, x0: number): number => add(x, x0);

const NatLat = {
  bot: NatLat$bot,
  lub: NatLat$lub,
} as const;

const S = Outer<number>(NatLat);
const N = Nested<number>(NatLat);
export const go: number = S.run(s(s(s(0))));
export const twice: number = N.twice(0);
export const through: number = N.O.run(s(0));
