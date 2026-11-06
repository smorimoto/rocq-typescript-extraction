import * as $Points from "./points.ts";

const { origin } = $Points;
const wrap = <A>(a: A, p: $Points.Point): readonly [A, $Points.Point] => [a, p];

export type Outline =
  /* Point */
  readonly $Points.Point[];

export type Collide = <Point>(x: Point) => Point;

export type Keyed = { [Point in "px" | "py"]: Point };

export type Fields = { [K in "px" | "py"]: $Points.Point };

export const sample = (n: number): readonly [number, $Points.Point] =>
  wrap(n, origin);

export const hold = (o: Outline): Outline => o;
export const labelled = (s0: "Point"): "Point" => s0;
export const named = (k: typeof $Points.origin): typeof $Points.origin => k;

export const sided = (
  e: $Points.Point | $Points.Point
): $Points.Point | $Points.Point => e;

export const crashed = (c: Collide): Collide => c;
export const keyedId = (k: Keyed): Keyed => k;
export const fieldsId = (k: Fields): Fields => k;

export const pickedId = (
  p: number extends infer Point ? Point : never
): number extends infer Point ? Point : never => p;
