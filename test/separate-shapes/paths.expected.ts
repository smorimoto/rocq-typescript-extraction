import type * as $Points from "./points.ts";

export const corners: (
  _0: readonly [$Points.Point, $Points.Point]
) => readonly $Points.Point[] = <A>(line: readonly [A, A]): readonly A[] =>
  line;

export type Polyline = readonly $Points.Point[];

export const trace: (
  _0: readonly [$Points.Point, $Points.Point]
) => Polyline = <A>(line: readonly [A, A]): readonly A[] => line;
