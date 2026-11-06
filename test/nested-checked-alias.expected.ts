const s = (n: number): number => n + 1;

export interface LAT<T> {
  readonly bot: T;
}

export interface InnerResult<T> {
  readonly L: LAT<T>;
  readonly get0: (_unused: number) => T;
}

const Inner = <T>(X: LAT<T>): InnerResult<T> => {
  const get0 = (_unused: number): T => X.bot;

  return { L: X, get0 };
};

export type SolverDSLT<T> = T;

export interface SolverResult<T> {
  readonly DS: InnerResult<T>;
  readonly run: (x: number) => T;
}

export const Solver = <T>(X: LAT<T>): SolverResult<T> => {
  const DS = Inner<T>(X);
  const run = (x: number): T => DS.get0(x);

  return { DS, run };
};

const NatLat$bot: number = s(s(s(s(s(s(0))))));

const NatLat = {
  bot: NatLat$bot,
} as const;

const S = Solver<number>(NatLat);
export const go: number = S.run(s(s(s(0))));
export const through: number = S.DS.L.bot;
