import * as $Fun from "./fun.ts";
import * as $Sig from "./sig.ts";

export type BBox = $Fun.FBox<number>;

export const B = $Fun.F<number>($Sig.A);
export const four: number = B.twice(B.twice(0));
