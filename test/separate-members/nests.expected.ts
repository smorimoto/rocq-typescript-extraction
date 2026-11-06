import type * as $Datatypes from "./datatypes.ts";
import * as $Sorts from "./sorts.ts";

export interface OuterResult<T> {
  readonly S: $Sorts.SortingResult<T>;
  readonly I: $Sorts.SortingResult<T>["Inner"];
  readonly drop: (x: $Datatypes.List<T>) => $Datatypes.List<T>;
}

export const Outer = <T>(X: $Sorts.ORD): OuterResult<T> => {
  const S = $Sorts.Sorting<T>(X);
  const { filter } = S.Inner;
  const drop = (x: $Datatypes.List<T>): $Datatypes.List<T> => filter(x);

  return { I: S.Inner, S, drop };
};
