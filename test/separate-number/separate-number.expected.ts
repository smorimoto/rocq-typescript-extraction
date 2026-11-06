import * as $Datatypes from "./datatypes.ts";
import * as $Nat from "./nat.ts";

const { fst, matchNat, pair, s, snd } = $Datatypes;
const { add } = $Nat;

export const predOr = (d: number, n: number): number => {
  if (n === 0) {
    return d;
  }

  const p: number = n - 1;

  return p;
};

export const pairUp = (n: number): readonly [number, number] => pair(n, s(n));

export const total = (p: readonly [number, number]): number =>
  add(fst(p), snd(p));

export const describe: (_0: number) => string = (n: number): string =>
  matchNat(() => "zero", String, n);

const Box$full = (n: number): number => n;

const Box$matchBox = <R>(
  empty: () => R,
  full: (n: number) => R,
  b: number
): R => (b < 0 ? empty() : full(b));

const Box$label = (n: number): number => n;
const Box$matchLabel = <R>(f: (n: number) => R, l: number): R => f(l);

const Box$open = (b: number, d: number): number =>
  Box$matchBox(
    (): number => d,
    (n: number): number => n,
    b
  );

export const Box = {
  full: Box$full,
  label: Box$label,
  matchBox: Box$matchBox,
  matchLabel: Box$matchLabel,
  open: Box$open,
} as const;

export const filled = (n: number): number => Box$full(n);
