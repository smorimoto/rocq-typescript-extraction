const s = (n: number): number => n + 1;

const sub: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => (n > m ? n - m : 0);

export interface Point {
  readonly px: number;
  readonly py: number;
}

const segment = (a: Point, b: Point): readonly [Point, Point] => [a, b];

const matchSegment = <R>(
  f: (a: Point, b: Point) => R,
  line: readonly [Point, Point]
): R => f(line[0], line[1]);

const corners: (_0: readonly [Point, Point]) => readonly Point[] = (
  line: readonly [Point, Point]
): readonly Point[] => [...line];

const origin: Point = { px: 0, py: 0 };

export const diagonal: readonly [Point, Point] = segment(origin, {
  px: s(0),
  py: s(0),
});

export const width = (s0: readonly [Point, Point]): number =>
  matchSegment((a: Point, b: Point): number => sub(b.px, a.px), s0);

export const ends = (x: readonly [Point, Point]): readonly Point[] =>
  corners(x);
