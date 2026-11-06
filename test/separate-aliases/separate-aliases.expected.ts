import * as $Datatypes from "./datatypes.ts";
import * as $Nat from "./nat.ts";
import * as $Plane from "./plane.ts";

const { s } = $Datatypes;
const { mul } = $Nat;

export type FigT = $Plane.FigureT;

export const Fig = $Plane.Figure;
export const unitArea: number = $Plane.Figure.area($Plane.Figure.square(s(0)));

export const scaled = (s0: $Plane.FigureT, k: number): number =>
  mul(k, $Plane.Figure.area(s0));
