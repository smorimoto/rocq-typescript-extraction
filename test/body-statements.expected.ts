const s = (n: number): number => n + 1;

const add: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n + m;

export interface S {
  readonly n: number;
  readonly b: boolean;
}

const twiceOf = (s0: number): number => {
  if (s0 === 0) {
    return 0;
  }

  const k: number = s0 - 1;

  return add(k, k);
};

const id = <A>(x: A): A => x;

export interface FResult {
  readonly twice: number;
  readonly pick: number;
  readonly ids: number;
}

export const F = (X: S): FResult => {
  const twice: number = twiceOf(X.n);

  const pickOf = (s0: boolean): number => {
    if (s0) {
      if (X.n === 0) {
        return s(0);
      }

      const k: number = X.n - 1;

      return add(k, k);
    }

    return s(s(0));
  };

  const pick: number = pickOf(X.b);
  const ids: number = add(id(X.n), id(X.b) ? s(0) : 0);

  return { ids, pick, twice };
};

const D$n: number = s(s(s(0)));
const D$b = true;

const D = {
  b: D$b,
  n: D$n,
} as const;

export const G = F(D);
