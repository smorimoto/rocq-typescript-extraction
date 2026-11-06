import * as $Datatypes from "./datatypes.ts";
import * as $Nat from "./nat.ts";
import * as $Pairs from "./pairs.ts";

const { s } = $Datatypes;
const { map, reduce } = $Pairs.Pair;
const { add } = $Nat;

export const succBoth = (
  p: readonly [number, number]
): readonly [number, number] => map((x: number): number => s(x), p);

export const ordered = (
  x: readonly [number, number]
): readonly [number, number] => $Pairs.Pair.sort(x);

export const total = (p: readonly [number, number]): number =>
  reduce(
    (x: number) =>
      (x0: number): number =>
        add(x, x0),
    p
  );
