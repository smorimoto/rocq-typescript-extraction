const s = (n: number): number => n + 1;

export interface LAT<T> {
  readonly bot: T;
}

interface MakeResult<T> {
  readonly get0: (_unused: number) => T;
}

const Make = <T>(A: LAT<T>): MakeResult<T> => {
  const get0 = (_unused: number): T => A.bot;

  return { get0 };
};

export interface UseI<T> {
  readonly get0: (_0: number) => T;
}

export interface UseResult<T> {
  readonly run: (x: number) => T;
}

export const Use =
  <T>(_A: LAT<T>) =>
  (I: UseI<T>): UseResult<T> => {
    const run = (x: number): T => I.get0(x);

    return { run };
  };

const NatLat$bot: number = s(s(s(s(s(s(s(s(s(0)))))))));

const NatLat = {
  bot: NatLat$bot,
} as const;

const M = Make<number>(NatLat);
const U = Use<number>(NatLat)(M);
export const go: number = U.run(s(s(s(0))));
