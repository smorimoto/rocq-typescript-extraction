const s = (n: number): number => n + 1;

const leb: (_0: number, _1: number) => boolean = (
  n: number,
  m: number
): boolean => n <= m;

export type EqLtLe = Record<never, never>;

export interface MakeTacP<T> {
  readonly leTotal: (_0: T, _1: T) => boolean;
}

export interface MakeTacResult<T> {
  readonly cmp: (x: T, x0: T) => boolean;
}

export const MakeTac =
  <T>(_O: EqLtLe) =>
  (P: MakeTacP<T>): MakeTacResult<T> => {
    const cmp = (x: T, x0: T): boolean => P.leTotal(x, x0);

    return { cmp };
  };

const N = {} as const;
const NP$leTotal = (x: number, x0: number): boolean => leb(x, x0);

const NP = {
  leTotal: NP$leTotal,
} as const;

const T = MakeTac<number>(N)(NP);
export const go: boolean = T.cmp(s(0), s(s(0)));
