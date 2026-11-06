import * as $Datatypes from "./datatypes.ts";
import * as $Nat from "./nat.ts";
import * as $Paths from "./paths.ts";
import * as $Points from "./points.ts";

const { matchSegment, segment } = $Points;
const { s } = $Datatypes;
const { sub } = $Nat;
const { corners, trace } = $Paths;
const origin: $Points.Point = { px: 0, py: 0 };

export const diagonal: readonly [$Points.Point, $Points.Point] = segment(
  origin,
  { px: s(0), py: s(0) }
);

export const width = (s0: readonly [$Points.Point, $Points.Point]): number =>
  matchSegment(
    (a: $Points.Point, b: $Points.Point): number => sub(b.px, a.px),
    s0
  );

export const ends = (
  x: readonly [$Points.Point, $Points.Point]
): readonly $Points.Point[] => corners(x);

export const traced = (
  x: readonly [$Points.Point, $Points.Point]
): $Paths.Polyline => trace(x);
