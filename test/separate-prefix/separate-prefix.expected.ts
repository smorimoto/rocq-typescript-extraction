import * as $PairExt from "./pair-ext.ts";
import * as $Pair from "./pair.ts";

const { swap } = $Pair;
const { swapTwice } = $PairExt;

export const flipped = (
  x: readonly [number, number]
): readonly [number, number] => swap(x);

export const same = (x: readonly [number, number]): readonly [number, number] =>
  swapTwice(x);
