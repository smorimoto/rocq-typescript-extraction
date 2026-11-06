const s = (n: number): number => n + 1;

export interface LAT<T> {
  readonly bot: T;
}

export interface MakeResult<T> {
  readonly get0: (_unused: number) => T;
}

const Make = <T>(A: LAT<T>): MakeResult<T> => {
  const get0 = (_unused: number): T => A.bot;

  return { get0 };
};

export interface CorrectI<T> {
  readonly get0: (_0: number) => T;
}

export interface CorrectResult<T> {
  readonly checked: (x: number) => T;
}

export const Correct =
  <T>(_A: LAT<T>) =>
  (I: CorrectI<T>): CorrectResult<T> => {
    const checked = (x: number): T => I.get0(x);

    return { checked };
  };

export interface MainResult<T> {
  readonly I: MakeResult<T>;
  readonly C: CorrectResult<T>;
  readonly run: (x: number) => T;
}

export const Main = <T>(A: LAT<T>): MainResult<T> => {
  const I = Make<T>(A);
  const C = Correct<T>(A)(I);
  const run = (x: number): T => C.checked(x);

  return { C, I, run };
};

const NatLat$bot: number = s(s(s(s(s(s(s(s(0))))))));

const NatLat = {
  bot: NatLat$bot,
} as const;

const M = Main<number>(NatLat);
export const go: number = M.run(s(s(s(0))));
