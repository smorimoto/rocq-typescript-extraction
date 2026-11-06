import * as $Pair from "./pair.ts";

const { swap } = $Pair;

export const swapTwice = (
  p: readonly [number, number]
): readonly [number, number] => swap(swap(p));
