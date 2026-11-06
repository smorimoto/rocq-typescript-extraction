const s = (n: number): number => n + 1;

const add: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n + m;

export interface COUNTED<T> {
  readonly z: T;
  readonly count: (_0: T) => number;
}

export interface TOTAL {
  readonly total: number;
}

const F$bump = (n: number): number => add(n, s(0));

export interface FResult {
  readonly bump: (n: number) => number;
  readonly total: number;
}

export const F = <T>(X: COUNTED<T>): FResult => {
  const total: number = F$bump(X.count(X.z));

  return { bump: F$bump, total };
};

const H$bump = (n: number): number => add(n, s(0));

export const H = <T>(X: COUNTED<T>): TOTAL => {
  const total: number = H$bump(X.count(X.z));

  return { total };
};

const G$evenOdd = {
  even: (n: number): boolean => {
    let n0 = n;

    for (;;) {
      if (n0 === 0) {
        return true;
      }

      const k: number = n0 - 1;

      if (k === 0) {
        return false;
      }

      const k0: number = k - 1;
      n0 = k0;
    }
  },
  odd: (n: number): boolean => {
    let n0 = n;

    for (;;) {
      if (n0 === 0) {
        return false;
      }

      const k: number = n0 - 1;

      if (k === 0) {
        return true;
      }

      const k0: number = k - 1;
      n0 = k0;
    }
  },
};

const { even: G$even, odd: G$odd } = G$evenOdd;

export interface GResult {
  readonly even: (n: number) => boolean;
  readonly odd: (n: number) => boolean;
  readonly balanced: boolean;
}

export const G = <T>(X: COUNTED<T>): GResult => {
  const balanced: boolean = G$even(X.count(X.z));

  return { balanced, even: G$even, odd: G$odd };
};

const N$Inner$twice = (n: number): number => add(n, n);
const N$Inner$Deep$thrice = (n: number): number => add(add(n, n), n);

export interface NInnerDeep {
  readonly thrice: (n: number) => number;
}

export interface NInner {
  readonly twice: (n: number) => number;
  readonly Deep: NInnerDeep;
}

export interface NResult {
  readonly Inner: NInner;
  readonly total: number;
}

export const N = <T>(X: COUNTED<T>): NResult => {
  const Inner$Deep = {
    thrice: N$Inner$Deep$thrice,
  } as const;

  const Inner = {
    Deep: Inner$Deep,
    twice: N$Inner$twice,
  } as const;

  const total: number = N$Inner$twice(N$Inner$Deep$thrice(X.count(X.z)));

  return { Inner, total };
};

const Only$double0 = (n: number): number => add(n, n);

export interface OnlyResult {
  readonly double0: (n: number) => number;
}

export const Only = <T>(_X: COUNTED<T>): OnlyResult => ({
  double0: Only$double0,
});
