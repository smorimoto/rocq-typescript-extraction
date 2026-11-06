export interface O {
  readonly tag: "O";
}

export interface S {
  readonly tag: "S";
  readonly arg0: Nat;
}

export type Nat = O | S;

export const o: O = { tag: "O" };
export const s = (arg0: Nat): Nat => ({ arg0, tag: "S" });
const Counter$start: Nat = o;
const Counter$step = (n: Nat): Nat => s(n);

export const Counter = {
  start: Counter$start,
  step: Counter$step,
} as const;

export const Same = Counter;
