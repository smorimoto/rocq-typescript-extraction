import * as $Datatypes from "./datatypes.ts";
import * as $Nat from "./nat.ts";

const __readCell = <T>(cells: readonly (readonly [T])[], index: number): T => {
  const cell = cells[index];

  if (cell === undefined) {
    throw new Error("Invalid continuation stack access");
  }

  return cell[0];
};

const __writeCell = <T>(cells: [T][], index: number, value: T): void => {
  const cell = cells[index];

  if (cell === undefined) {
    cells[index] = [value];
  } else {
    cell[0] = value;
  }
};

const { none, some } = $Datatypes;
const { eqb } = $Nat;

export interface AssocEmpty {
  readonly tag: "Empty";
}

export interface AssocNode<A> {
  readonly tag: "Node";
  readonly k: number;
  readonly v: A;
  readonly rest: AssocTree<A>;
}

export type AssocTree<A> = AssocEmpty | AssocNode<A>;

const Assoc$empty0: AssocEmpty = { tag: "Empty" };

const Assoc$node = <A>(k: number, v: A, rest: AssocTree<A>): AssocTree<A> => ({
  k,
  rest,
  tag: "Node",
  v,
});

const Assoc$treeRect = <A, B>(
  empty: B,
  node: (_: number) => (_: A) => (_: AssocTree<A>) => (_: B) => B,
  t: AssocTree<A>
): B => {
  const saved: [number][] = [];
  let top = 0;
  const saved0: [A][] = [];
  let top0 = 0;
  const saved1: [AssocTree<A>][] = [];
  let top1 = 0;
  let t0 = t;

  for (;;) {
    let returned: B;

    switch (t0.tag) {
      case "Empty": {
        returned = empty;
        break;
      }

      case "Node": {
        __writeCell(saved, top, t0.k);
        top += 1;
        __writeCell(saved0, top0, t0.v);
        top0 += 1;
        __writeCell(saved1, top1, t0.rest);
        top1 += 1;
        t0 = t0.rest;
        continue;
      }

      default: {
        returned = t0 satisfies never;
      }
    }

    for (;;) {
      if (top === 0) {
        return returned;
      }

      top1 -= 1;
      const rest: AssocTree<A> = __readCell(saved1, top1);
      top0 -= 1;
      const v: A = __readCell(saved0, top0);
      top -= 1;
      const k: number = __readCell(saved, top);
      returned = node(k)(v)(rest)(returned);
    }
  }
};

const Assoc$treeRec = <A, B>(
  empty: B,
  node: (_: number) => (_: A) => (_: AssocTree<A>) => (_: B) => B,
  t: AssocTree<A>
): B => {
  const saved: [number][] = [];
  let top = 0;
  const saved0: [A][] = [];
  let top0 = 0;
  const saved1: [AssocTree<A>][] = [];
  let top1 = 0;
  let t0 = t;

  for (;;) {
    let returned: B;

    switch (t0.tag) {
      case "Empty": {
        returned = empty;
        break;
      }

      case "Node": {
        __writeCell(saved, top, t0.k);
        top += 1;
        __writeCell(saved0, top0, t0.v);
        top0 += 1;
        __writeCell(saved1, top1, t0.rest);
        top1 += 1;
        t0 = t0.rest;
        continue;
      }

      default: {
        returned = t0 satisfies never;
      }
    }

    for (;;) {
      if (top === 0) {
        return returned;
      }

      top1 -= 1;
      const rest: AssocTree<A> = __readCell(saved1, top1);
      top0 -= 1;
      const v: A = __readCell(saved0, top0);
      top -= 1;
      const k: number = __readCell(saved, top);
      returned = node(k)(v)(rest)(returned);
    }
  }
};

export type AssocT<A> = AssocTree<A>;

const Assoc$empty = <A>(): AssocTree<A> => Assoc$empty0;

const Assoc$set0 = <A>(k: number, v: A): AssocTree<A> =>
  Assoc$node(k, v, Assoc$empty0);

const Assoc$set1 = <A>(k: number, v: A, m: AssocTree<A>): AssocTree<A> =>
  Assoc$node(k, v, m);

const Assoc$get0 = <A>(k: number, m: AssocTree<A>): $Datatypes.Option<A> => {
  let m0 = m;

  for (;;) {
    switch (m0.tag) {
      case "Empty": {
        return none;
      }

      case "Node": {
        if (eqb(k, m0.k)) {
          return some(m0.v);
        }

        m0 = m0.rest;
        continue;
      }

      default: {
        return m0 satisfies never;
      }
    }
  }
};

export const Assoc = {
  empty: Assoc$empty,
  empty0: Assoc$empty0,
  get0: Assoc$get0,
  node: Assoc$node,
  set0: Assoc$set0,
  set1: Assoc$set1,
  treeRec: Assoc$treeRec,
  treeRect: Assoc$treeRect,
} as const;
