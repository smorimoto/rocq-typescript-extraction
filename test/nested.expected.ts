const s = (n: number): number => n + 1;
const pair = <A, B>(a: A, b: B): readonly [A, B] => [a, b];

export interface S<T0> {
  readonly z: T0;
  readonly next0: (_0: T0) => T0;
}

export interface T<T0> {
  readonly y: T0;
}

export interface FGResult<T0, T1> {
  readonly pair: readonly [T0, T1];
}

export type FCT = boolean;

export interface FC {
  readonly y: boolean;
}

export interface FResult<T0> {
  readonly G: <T1>(Y: T<T1>) => FGResult<T0, T1>;
  readonly C: FC;
  readonly GC: FGResult<T0, boolean>;
  readonly both: readonly [T0, boolean];
}

export const F = <T0>(X: S<T0>): FResult<T0> => {
  const G = <T1>(Y: T<T1>): FGResult<T0, T1> => {
    const pair0: readonly [T0, T1] = pair(X.next0(X.z), Y.y);

    return { pair: pair0 };
  };

  const C$y = true;

  const C = {
    y: C$y,
  } as const;

  const GC = G<boolean>(C);
  const both: readonly [T0, boolean] = GC.pair;

  return { C, G, GC, both };
};

const A$z = 0;
const A$next0 = (n: number): number => s(n);

const A = {
  next0: A$next0,
  z: A$z,
} as const;

export type BCT = FCT;

export const B = F<number>(A);
export const v: readonly [number, boolean] = B.both;

export interface HResult<T0, T1> {
  readonly step: T0;
  readonly other: T1;
}

const H =
  <T0, T1>(X: S<T0>) =>
  (Y: T<T1>): HResult<T0, T1> => {
    const step: T0 = X.next0(X.z);
    const other: T1 = Y.y;

    return { other, step };
  };

export const HA = <T0>(Y: T<T0>): HResult<number, T0> => H<number, T0>(A)(Y);
const D$y = false;

const D = {
  y: D$y,
} as const;

export const HD = HA<boolean>(D);
export const w: boolean = HD.other;

export type KU<T0> = T0;

export interface KGBox0<T0, T1> {
  readonly tag: "Box";
  readonly x: KU<T0>;
  readonly y: T1;
}

export type KGBox<T0, T1> = KGBox0<T0, T1>;

export interface KGResult<T0, T1> {
  readonly box: (x: KU<T0>, y: T1) => KGBox0<T0, T1>;
  readonly boxRect: <A>(box0: (_: T0) => (_: T1) => A, b: KGBox<T0, T1>) => A;
  readonly boxRec: <A>(box0: (_: T0) => (_: T1) => A, b: KGBox<T0, T1>) => A;
  readonly both: KGBox<T0, T1>;
}

export interface KResult<T0> {
  readonly G: <T1>(Y: T<T1>) => KGResult<T0, T1>;
}

export const K = <T0>(X: S<T0>): KResult<T0> => {
  const G = <T1>(Y: T<T1>): KGResult<T0, T1> => {
    const box = (x: KU<T0>, y: T1): KGBox0<T0, T1> => ({ tag: "Box", x, y });

    const boxRect = <A>(box0: (_: T0) => (_: T1) => A, b: KGBox<T0, T1>): A =>
      box0(b.x)(b.y);

    const boxRec = <A>(box0: (_: T0) => (_: T1) => A, b: KGBox<T0, T1>): A =>
      box0(b.x)(b.y);

    const both: KGBox<T0, T1> = box(X.z, Y.y);

    return { both, box, boxRec, boxRect };
  };

  return { G };
};

export const KB = K<number>(A);

export type KBDBox = KGBox<number, boolean>;

export const KBD = KB.G<boolean>(D);
export const boxed: KBDBox = KBD.both;
