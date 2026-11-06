const s = (n: number): number => n + 1;

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

export interface S<T> {
  readonly set1: (_0: number, _1: T) => T;
}

export type MT = List<number>;

const M$set0 = (n: number): List<number> => cons(n, nil);

const M$set1 = (n: number, l: List<number>): List<number> =>
  cons(n, cons(n, l));

export const M = {
  set0: M$set0,
  set1: M$set1,
} as const;

export interface FResult<T> {
  readonly go: (l: T) => T;
}

export const F = <T>(X: S<T>): FResult<T> => {
  const go0 = (l: T): T => X.set1(s(0), l);

  return { go: go0 };
};

const G = F<List<number>>(M);
export const go: List<number> = G.go(cons(s(s(s(s(s(0))))), nil));
