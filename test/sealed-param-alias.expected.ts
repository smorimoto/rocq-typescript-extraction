const s = (n: number): number => n + 1;

export interface LAT<T> {
  readonly bot: T;
}

export interface SOLVER<LT> {
  readonly L: LAT<LT>;
  readonly run: (_0: number) => LT;
}

export const Solver = <T>(X: LAT<T>): SOLVER<T> => {
  const run = (_unused: number): T => X.bot;

  return { L: X, run };
};

const NatLat$bot: number = s(s(s(s(0))));

const NatLat = {
  bot: NatLat$bot,
} as const;

const S = Solver<number>(NatLat);
export const go: number = S.run(s(s(s(0))));
