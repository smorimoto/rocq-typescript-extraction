import * as $Datatypes from "./datatypes.ts";

const { fst, pair, snd } = $Datatypes;

export const swap = (p: readonly [number, number]): readonly [number, number] =>
  pair(snd(p), fst(p));
