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

export interface Dot {
  readonly tag: "Dot";
}

export interface Line {
  readonly tag: "Line";
  readonly n: Nat;
}

export interface Box {
  readonly tag: "Box";
  readonly w: Nat;
  readonly h: Nat;
}

export type Figure = Dot | Line | Box;

export const dot: Dot = { tag: "Dot" };
export const line = (n: Nat): Figure => ({ n, tag: "Line" });
export const box = (w: Nat, h: Nat): Figure => ({ h, tag: "Box", w });
