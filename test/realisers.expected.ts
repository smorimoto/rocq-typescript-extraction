export const s = (n: number): number => n + 1;

export const matchNat = <R>(fO: () => R, fS: (p: number) => R, n: number): R =>
  n === 0 ? fO() : fS(n - 1);

const Box$full = (n: number): number => n;

const Box$matchBox = <R>(
  empty: () => R,
  full: (n: number) => R,
  b: number
): R => (b < 0 ? empty() : full(b));

export const Box = {
  full: Box$full,
  matchBox: Box$matchBox,
} as const;

const Point$point = (x: number, y: number): readonly [number, number] => [x, y];

const Point$matchPoint = <R>(
  f: (x: number, y: number) => R,
  p: readonly [number, number]
): R => f(p[0], p[1]);

export const Point = {
  matchPoint: Point$matchPoint,
  point: Point$point,
} as const;

export interface Bounds {
  readonly lo: number;
  readonly hi: number;
}

export const range = (b: Bounds): Bounds => b;
export const matchRange = <R>(f: (b: Bounds) => R, r: Bounds): R => f(r);
