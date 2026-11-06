export interface TypeLambda {
  readonly Target: unknown;
  readonly type: unknown;
}

export type Kind<F, A> = F extends TypeLambda
  ? (F & { readonly Target: A })["type"]
  : never;

const s = (n: number): number => n + 1;
const pair = <A, B>(a: A, b: B): readonly [A, B] => [a, b];

export interface Nil {
  readonly tag: "Nil";
}

export interface Cons<A> {
  readonly tag: "Cons";
  readonly arg0: A;
  readonly arg1: List<A>;
}

export type List<A> = Nil | Cons<A>;

export const nil: Nil = { tag: "Nil" };

export const cons = <A>(arg0: A, arg1: List<A>): List<A> => ({
  arg0,
  arg1,
  tag: "Cons",
});

export interface TREE<T> {
  readonly empty: <A>() => Kind<T, A>;
}

export interface PropsResult<T> {
  readonly fresh: <A>() => Kind<T, A>;
}

export const Props = <T>(T0: TREE<T>): PropsResult<T> => {
  const fresh = <A>(): Kind<T, A> => T0.empty<A>();

  return { fresh };
};

type TreeT<A> = List<A>;

const Tree$empty = <A>(): List<A> => nil;

const Tree = {
  empty: Tree$empty,
} as const;

interface TreeTLambda extends TypeLambda {
  readonly type: TreeT<this["Target"]>;
}

const P = Props<TreeTLambda>(Tree);

export interface ALG<T> {
  readonly x: T;
}

export interface FTResult<T> {
  readonly y: (_0: number) => T;
}

export type FT = <T>(T0: ALG<T>) => FTResult<T>;

export interface FResult<T, T0> {
  readonly y: (_unused: number) => readonly [T, T0];
}

export const F =
  <T, T0>(A: ALG<T>) =>
  (T1: ALG<T0>): FResult<T, T0> => {
    const y = (_unused: number): readonly [T, T0] => pair(A.x, T1.x);

    return { y };
  };

const N$x: number = s(s(s(0)));

const N = {
  x: N$x,
} as const;

export const Q = <T>(T0: ALG<T>): FResult<number, T> => F<number, T>(N)(T0);
const QN = Q<number>(N);

export interface UseResult {
  readonly R: FTResult<number>;
  readonly go: number;
}

export const Use = (G: FT): UseResult => {
  const R = G<number>(N);
  const go0: number = R.y(0);

  return { R, go: go0 };
};

interface G1Result<T> {
  readonly y: (_unused: number) => T;
}

const G1 = <T>(T0: ALG<T>): G1Result<T> => {
  const y = (_unused: number): T => T0.x;

  return { y };
};

const U = Use(G1);
export const go: List<number> = P.fresh<number>();
export const both: readonly [number, number] = QN.y(0);
export const used: number = U.go;
