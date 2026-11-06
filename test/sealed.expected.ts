const s = (n: number): number => n + 1;

const add: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n + m;

export interface S<T> {
  readonly z: T;
  readonly f: (_0: T) => T;
}

export type FT<T> = T;

export const F = <T>(X: S<T>): S<T> => {
  const helper = (x: T): T => X.f(X.f(x));
  const z: T = helper(X.z);
  const f = (x: T): T => helper(x);

  return { f, z };
};

const A$z = 0;
const A$f = (x: number): number => add(x, s(0));

const A = {
  f: A$f,
  z: A$z,
} as const;

export type BT = FT<number>;

export const B = F<number>(A);
export const w: BT = B.f(B.z);

export type GT<T> = T;

export interface GResult<T> {
  readonly z: T;
  readonly f: (x: T) => T;
  readonly extra: T;
}

export const G = <T>(X: S<T>): GResult<T> => {
  const z: T = X.z;
  const f = (x: T): T => X.f(x);
  const extra: T = X.z;

  return { extra, f, z };
};

export type CT = GT<number>;

export const C = G<number>(A);
export const u: CT = C.f(C.z);

export interface BOX<T, Box> {
  readonly wrap: (_0: T) => Box;
  readonly unwrap: (_0: Box) => T;
}

export type BoxesT<T> = T;

export interface BoxesFull<T> {
  readonly tag: "Full";
  readonly x: BoxesT<T>;
}

export interface BoxesEmpty {
  readonly tag: "Empty";
}

export type BoxesCell<T> = BoxesFull<T> | BoxesEmpty;

export type BoxesBox<T> = BoxesCell<T>;

export const Boxes = <T>(X: S<T>): BOX<T, BoxesCell<T>> => {
  const full = (x: BoxesT<T>): BoxesCell<T> => ({ tag: "Full", x });
  const wrap = (x: T): BoxesCell<T> => full(x);

  const unwrap = (b: BoxesCell<T>): T => {
    switch (b.tag) {
      case "Full": {
        return b.x;
      }

      case "Empty": {
        return X.z;
      }

      default: {
        return b satisfies never;
      }
    }
  };

  return { unwrap, wrap };
};

export type BAT = BoxesT<number>;

export type BABox = BoxesBox<number>;

export const BA = Boxes<number>(A);
export const v: number = BA.unwrap(BA.wrap(s(s(s(0)))));
