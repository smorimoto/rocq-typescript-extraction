const andb: (_0: boolean, _1: boolean) => boolean = (
  a: boolean,
  b: boolean
): boolean => a && b;

const orb: (_0: boolean, _1: boolean) => boolean = (
  a: boolean,
  b: boolean
): boolean => a || b;

const negb: (_0: boolean) => boolean = (b: boolean): boolean => !b;
const s = (n: number): number => n + 1;
const pair = <A, B>(a: A, b: B): readonly [A, B] => [a, b];

const eqb: (_0: number, _1: number) => boolean = (
  n: number,
  m: number
): boolean => n === m;

const leb: (_0: number, _1: number) => boolean = (
  n: number,
  m: number
): boolean => n <= m;

export interface EqLe<T> {
  readonly le: (_0: T, _1: T) => boolean;
}

export interface MakeTacP<T> {
  readonly leTotal: (_0: T, _1: T) => boolean;
  readonly eqb: (_0: T, _1: T) => boolean;
}

export interface MakeTacResult<T> {
  readonly lt: (x: T, y: T) => boolean;
  readonly cmp: (x: T, y: T) => boolean;
}

export const MakeTac =
  <T>(O: EqLe<T>) =>
  (P: MakeTacP<T>): MakeTacResult<T> => {
    const lt = (x: T, y: T): boolean => andb(O.le(x, y), negb(P.eqb(x, y)));
    const cmp = (x: T, y: T): boolean => orb(lt(x, y), P.leTotal(x, y));

    return { cmp, lt };
  };

export interface TACP<T> {
  readonly leTotal: (_0: T, _1: T) => boolean;
  readonly eqb: (_0: T, _1: T) => boolean;
}

export interface TACResult<T> {
  readonly cmp: (_0: T, _1: T) => boolean;
}

export type TAC = <T>(O: EqLe<T>) => (P: TACP<T>) => TACResult<T>;

export type UseNT = number;

const Use$N$le = (x: number, x0: number): boolean => leb(x, x0);
const Use$N$leTotal = (x: number, x0: number): boolean => leb(x, x0);
const Use$N$eqb = (x: number, x0: number): boolean => eqb(x, x0);

export interface UseN {
  readonly le: (x: number, x0: number) => boolean;
  readonly leTotal: (x: number, x0: number) => boolean;
  readonly eqb: (x: number, x0: number) => boolean;
}

export interface UseResult {
  readonly N: UseN;
  readonly T: TACResult<number>;
  readonly go: boolean;
}

export const Use = (F: TAC): UseResult => {
  const N0 = {
    eqb: Use$N$eqb,
    le: Use$N$le,
    leTotal: Use$N$leTotal,
  } as const;

  const T0 = F<number>(N0)(N0);
  const go0: boolean = T0.cmp(s(s(s(0))), s(0));

  return { N: N0, T: T0, go: go0 };
};

const N$le = (x: number, x0: number): boolean => leb(x, x0);
const N$leTotal = (x: number, x0: number): boolean => leb(x, x0);
const N$eqb = (x: number, x0: number): boolean => eqb(x, x0);

const N = {
  eqb: N$eqb,
  le: N$le,
  leTotal: N$leTotal,
} as const;

const T = MakeTac<number>(N)(N);
const U = Use(MakeTac);

export const go: readonly [boolean, boolean] = pair(
  T.lt(s(0), s(s(0))),
  T.cmp(s(s(0)), s(s(0)))
);

export const used: boolean = U.go;
