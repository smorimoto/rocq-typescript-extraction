import * as $Boxes from "./boxes.ts";
import type * as $Points from "./points.ts";

const {
  crashed,
  fieldsId,
  hold,
  keyedId,
  labelled,
  named,
  pickedId,
  sample,
  sided,
} = $Boxes;

export const seen = (x: $Boxes.Outline): $Boxes.Outline => hold(x);
export const via = (x: number): readonly [number, $Points.Point] => sample(x);
export const text = (x: "Point"): "Point" => labelled(x);

export const ofOrigin = (x: typeof $Points.origin): typeof $Points.origin =>
  named(x);

export const unioned = (
  x: $Points.Point | $Points.Point
): $Points.Point | $Points.Point => sided(x);

export const collided = (x: $Boxes.Collide): $Boxes.Collide => crashed(x);
export const rekeyed = (x: $Boxes.Keyed): $Boxes.Keyed => keyedId(x);
export const refields = (x: $Boxes.Fields): $Boxes.Fields => fieldsId(x);

export const repicked = (
  x: number extends infer Point ? Point : never
): number extends infer Point ? Point : never => pickedId(x);
