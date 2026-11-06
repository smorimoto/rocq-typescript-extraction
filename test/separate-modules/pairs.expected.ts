import * as $Datatypes from "./datatypes.ts";
import * as $Nat from "./nat.ts";

const { fst, pair, snd } = $Datatypes;
const { leb } = $Nat;

const Pair$map = <A, B>(f: (_: A) => B, p: readonly [A, A]): readonly [B, B] =>
  pair(f(fst(p)), f(snd(p)));

const Pair$reduce = <A, B>(f: (_: A) => (_: A) => B, p: readonly [A, A]): B =>
  f(fst(p))(snd(p));

const Pair$sort = (p: readonly [number, number]): readonly [number, number] =>
  leb(fst(p), snd(p)) ? p : pair(snd(p), fst(p));

export const Pair = {
  map: Pair$map,
  reduce: Pair$reduce,
  sort: Pair$sort,
} as const;
