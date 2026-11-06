export interface True {
  readonly tag: "True";
}

export interface False {
  readonly tag: "False";
}

export type Bool = True | False;

export const true0: True = { tag: "True" };
export const false0: False = { tag: "False" };

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

export interface Leaf {
  readonly tag: "Leaf";
}

export interface Node<A> {
  readonly tag: "Node";
  readonly l: Tree<A>;
  readonly x: A;
  readonly r: Tree<A>;
}

export type Tree<A> = Leaf | Node<A>;

export const leaf: Leaf = { tag: "Leaf" };

export const node = <A>(l: Tree<A>, x: A, r: Tree<A>): Tree<A> => ({
  l,
  r,
  tag: "Node",
  x,
});

export const e: Tree<Nat> = leaf;
export const isLeaf: Bool = true0;
export const grown: Tree<Nat> = node<Nat>(leaf, o, leaf);

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
const origin: Figure = dot;
export const alias: Figure = origin;
export const area: Nat = o;
export const pick = (_unused: Bool): Nat => o;
