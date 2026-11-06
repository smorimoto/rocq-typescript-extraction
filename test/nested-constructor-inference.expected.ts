const s = (n: bigint): bigint => n + 1n;
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

export interface Red {
  readonly tag: "Red";
}

export interface Blue {
  readonly tag: "Blue";
}

export type Color = Red | Blue;

export const red: Red = { tag: "Red" };
export const blue: Blue = { tag: "Blue" };

export const palette: List<readonly [bigint, Color]> = cons<
  readonly [bigint, Color]
>(pair(s(0n), red), cons<readonly [bigint, Color]>(pair(s(s(0n)), blue), nil));

export interface Swatch {
  readonly number: bigint;
  readonly shade: Color;
}

export const swatches: List<Swatch> = cons<Swatch>(
  { number: s(0n), shade: red },
  cons<Swatch>({ number: s(s(0n)), shade: blue }, nil)
);
