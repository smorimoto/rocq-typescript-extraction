export const s = (n: number): number => n + 1;

const mul: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n * m;

export interface Dot {
  readonly tag: "Dot";
}

export interface Line {
  readonly tag: "Line";
  readonly n: number;
}

export interface Box {
  readonly tag: "Box";
  readonly w: number;
  readonly h: number;
}

export type Figure = Dot | Line | Box;

export const dot: Dot = { tag: "Dot" };
export const line = (n: number): Figure => ({ n, tag: "Line" });
export const box = (w: number, h: number): Figure => ({ h, tag: "Box", w });

interface Circle {
  readonly tag: "Circle";
  readonly r: number;
}

interface Square {
  readonly tag: "Square";
  readonly s: number;
}

type Tile = Circle | Square;

const square = (s0: number): Tile => ({ s: s0, tag: "Square" });
const sq: Tile = square(s(s(0)));
export const area: number = sq.tag === "Circle" ? sq.r : mul(sq.s, sq.s);
