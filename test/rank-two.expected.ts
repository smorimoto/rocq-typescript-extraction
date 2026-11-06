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

const add: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n + m;

export const applyPoly = (
  h: <A>(_: A) => A,
  n: number,
  b: boolean
): readonly [number, boolean] => pair(h(n), h(b));

const id = <A>(x: A): A => x;

export const passed = (n: number, b: boolean): readonly [number, boolean] =>
  applyPoly(<A>(x: A): A => id(x), n, b);

const globalId = <A>(x: A): A => x;

export const passedGlobal = (
  n: number,
  b: boolean
): readonly [number, boolean] => applyPoly(<A>(x: A): A => globalId(x), n, b);

export const passedLam = (n: number, b: boolean): readonly [number, boolean] =>
  applyPoly(<A>(x: A): A => x, n, b);

export const forward = (
  h: <A>(_: A) => A,
  n: number
): readonly [number, boolean] => applyPoly(h, n, true);

const f = (m: number): readonly [number, boolean] =>
  applyPoly(<A>(x: A): A => x, m, true);

export const twicePoly = (
  k: number
): readonly [readonly [number, boolean], readonly [number, boolean]] =>
  pair(f(k), f(s(0)));

const two = (
  h: <A, B>(_: A) => (_: B) => A,
  n: number,
  b: boolean
): readonly [number, boolean] => pair(h(n)(b), h(b)(n));

export const first = (n: number, b: boolean): readonly [number, boolean] =>
  two(
    <A, B>(x: A) =>
      (_unused: B): A =>
        x,
    n,
    b
  );

export const lists = (
  h: <A>(_: List<A>) => number,
  ns: List<number>,
  bs: List<boolean>
): number => add(h(ns), h(bs));

export interface Boxed {
  readonly run: <A>(_: A) => A;
  readonly size: number;
}

const run = <A>(b: Boxed, x: A): A => b.run(x);
export const useBoxed = (x: Boxed, x0: number): number => run(x, x0);
export const mkBoxed: Boxed = { run: <A>(x: A): A => x, size: 0 };
