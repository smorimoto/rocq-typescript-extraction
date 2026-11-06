export interface Point {
  readonly px: number;
  readonly py: number;
}

export const segment = (a: Point, b: Point): readonly [Point, Point] => [a, b];

export const matchSegment = <R>(
  f: (a: Point, b: Point) => R,
  line: readonly [Point, Point]
): R => f(line[0], line[1]);
