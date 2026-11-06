import { expect, test } from "bun:test";

import type { Forest, List, Rose, Tree } from "./stack.ts";
import {
  app,
  blue,
  composeN,
  cons,
  countFrom,
  dropClosure,
  dropClosureChain,
  dropEffectClosure,
  dropLetClosure,
  dropLocalClosure,
  dropMutualClosure,
  dropMutualClosureOdd,
  ev,
  fCons,
  fNil,
  forestSize,
  forestSum,
  foldTree,
  green,
  leaf,
  localParity,
  mapNat,
  merge,
  mirror,
  mod30,
  mod31,
  mod32,
  nil,
  node,
  od,
  order,
  observedEven,
  observedOdd,
  observedTail,
  savedValues,
  shuttle,
  shuttleList,
  rNode,
  red,
  roseSize,
  roseSum,
  size,
  twiceAfter,
  upEven,
  upOdd,
  walk,
  weigh,
} from "./stack.ts";

const million = 1_000_000;

const deep = 100_000;

const degenerate = (n: number): Tree => {
  let t: Tree = leaf;

  for (let i = 0; i < n; i += 1) {
    t = node(t, i, leaf);
  }

  return t;
};

const range = (n: number): List<number> => {
  let l: List<number> = nil;

  for (let i = n - 1; i >= 0; i -= 1) {
    l = cons(i, l);
  }

  return l;
};

const length = <A>(l: List<A>): number => {
  let n = 0;
  let rest = l;

  while (rest.tag === "Cons") {
    n += 1;
    rest = rest.arg1;
  }

  return n;
};

test("size of a degenerate tree of a million nodes", () => {
  expect(size(degenerate(million))).toBe(million);
});

test("mirror builds a node of two calls a million deep", () => {
  const t = mirror(degenerate(million));

  expect(size(t)).toBe(million);
  expect(t.tag).toBe("Node");

  if (t.tag === "Node") {
    expect(t.l.tag).toBe("Leaf");
  }
});

test("app of a million cells", () => {
  expect(length(app(range(million), range(3)))).toBe(million + 3);
});

test("a call under a match in a call argument", () => {
  expect(weigh(red, million)).toBe(million);
  expect(weigh(blue, million)).toBe(million);
  expect(weigh(green, 5)).toBe(3);
});

test("a local fixpoint a million deep", () => {
  expect(countFrom(7, million)).toBe(million + 15);
});

test("tail and non-tail calls of one function", () => {
  expect(walk(million, 0, true)).toBe(million);
  expect(walk(million, 0, false)).toBe(million);
  expect(walk(5, 2, true)).toBe(7);
});

test("a closure over a parameter that a tail call changes", () => {
  expect(composeN(million, (x) => x)).toBeInstanceOf(Function);
  expect(composeN(1000, (x) => x)(0)).toBe(1000);
  expect(composeN(3, (x) => x * 10)(1)).toBe(40);
});

test("a group of tail calls a million deep", () => {
  expect(ev(million)).toBe(true);
  expect(od(million)).toBe(false);
  expect(od(million + 1)).toBe(true);
});

test("a group of non-tail calls a million deep", () => {
  expect(upEven(million)).toBe(million);
  expect(upOdd(million)).toBe(million + 1);
  expect(upEven(3)).toBe(4);
});

test("a group of three a million deep", () => {
  expect(mod30(million)).toBe(million % 3);
  expect(mod31(million)).toBe((million + 1) % 3);
  expect(mod32(million)).toBe((million + 2) % 3);
});

test("a local group a million deep", () => {
  expect(localParity(million)).toBe(true);
  expect(localParity(million + 1)).toBe(false);
});

const sum = (l: List<number>): number => {
  let n = 0;
  let rest = l;

  while (rest.tag === "Cons") {
    n += rest.arg0;
    rest = rest.arg1;
  }

  return n;
};

const balanced = (depth: number, k: number): Tree =>
  depth === 0 ? leaf : node(balanced(depth - 1, k), k, balanced(depth - 1, k));

const triangle = (x: number): number => ((x % 7) * ((x % 7) + 1)) / 2;

const throwing = (x: number): number => {
  if (x === 500) {
    throw new Error("callback");
  }

  return x;
};

test("a callback that calls the function again while it runs", () => {
  const inner = (x: number): number => sum(mapNat((y) => y + 1, range(x % 7)));
  const out = mapNat(inner, range(deep));
  let total = 0;

  for (let x = 0; x < deep; x += 1) {
    total += triangle(x);
  }

  expect(length(out)).toBe(deep);
  expect(sum(out)).toBe(total);

  const t = balanced(10, 3);
  const nested = (k: number): number => foldTree((j) => j + 1, balanced(2, k));

  expect(foldTree(nested, t)).toBe(12_276);
  expect(foldTree(nested, degenerate(deep))).toBe((3 * deep * (deep + 1)) / 2);
});

test("a callback that throws leaves the next call whole", () => {
  expect(() => mapNat(throwing, range(1000))).toThrow("callback");
  expect(sum(mapNat((x) => x, range(1000)))).toBe(499_500);
  expect(() => foldTree(throwing, degenerate(1000))).toThrow("callback");
  expect(foldTree((x) => x, degenerate(1000))).toBe(499_500);
});

test("a caught nested callback failure preserves the outer call's frames", () => {
  const seen: number[] = [];
  const nestedErrors: unknown[] = [];
  let nestedSum = 0;

  const out = mapNat((x) => {
    seen.push(x);

    if (x === 3) {
      try {
        mapNat(throwing, range(1000));
      } catch (error) {
        nestedErrors.push(error);
      }

      nestedSum = sum(mapNat((y) => y + 1, range(4)));
    }

    return x + 1;
  }, range(6));

  const values: number[] = [];
  let rest = out;

  while (rest.tag === "Cons") {
    values.push(rest.arg0);
    rest = rest.arg1;
  }

  expect(nestedErrors).toStrictEqual([new Error("callback")]);
  expect(nestedSum).toBe(10);
  expect(seen).toMatchInlineSnapshot(`
    [
      5,
      4,
      3,
      2,
      1,
      0,
    ]
  `);
  expect(values).toMatchInlineSnapshot(`
    [
      1,
      2,
      3,
      4,
      5,
      6,
    ]
  `);
  expect(sum(mapNat((x) => x, range(6)))).toBe(15);
});

test("reentrant tree folds keep both branches after a caught failure", () => {
  const t = node(node(leaf, 1, leaf), 2, node(leaf, 3, leaf));
  const seen: number[] = [];

  const out = foldTree((x) => {
    seen.push(x);
    expect(() => foldTree(throwing, degenerate(1000))).toThrow("callback");

    return foldTree((y) => x + y, t);
  }, t);

  expect(out).toBe(36);
  expect(seen.toSorted((a, b) => a - b)).toStrictEqual([1, 2, 3]);
  expect(foldTree((x) => x, leaf)).toBe(0);
  expect(foldTree((x) => x, t)).toBe(6);
});

const deepRose = (n: number): Rose => {
  let r: Rose = rNode(1, fNil);

  for (let i = 0; i < n; i += 1) {
    r = rNode(1, fCons(r, fNil));
  }

  return r;
};

const wideForest = (n: number): Forest => {
  let f: Forest = fNil;

  for (let i = 0; i < n; i += 1) {
    f = fCons(rNode(i, fNil), f);
  }

  return f;
};

test("a group whose members take different types, past the native stack", () => {
  expect(roseSize(deepRose(deep))).toBe(deep + 1);
  expect(forestSize(wideForest(deep))).toBe(deep);
  expect(roseSum(deepRose(deep), 0)).toBe(deep + 1);
  expect(forestSum(wideForest(deep), 0)).toBe((deep * (deep - 1)) / 2);
  expect(roseSize(rNode(0, fCons(rNode(0, fNil), fNil)))).toBe(2);
});

test("a rest that calls a local function the body declares", () => {
  expect(twiceAfter(million)).toBe(million * (million + 1));
  expect(twiceAfter(2)).toBe(6);
});

const evens = (n: number): List<number> => {
  let l: List<number> = nil;

  for (let i = n - 1; i >= 0; i -= 1) {
    l = cons(2 * i, l);
  }

  return l;
};

test("a local fixpoint that calls the function it is in, a million deep", () => {
  expect(length(merge(range(million), cons(million, nil)))).toBe(million + 1);
  expect(length(merge(cons(million, nil), range(million)))).toBe(million + 1);
  expect(sum(merge(evens(million / 2), range(million / 2)))).toBe(
    (million / 2) * (million / 2 - 1) + ((million / 2) * (million / 2 - 1)) / 2
  );
  expect(length(merge(range(3), range(2)))).toBe(5);
});

test("an operand left of a recursive call is evaluated before the call", () => {
  expect(() => order(5)).toThrow("boom");
  expect(() => order(1)).toThrow("bottom");
});

test("shallow inputs", () => {
  expect(size(node(node(leaf, 1, leaf), 2, leaf))).toBe(2);
  expect(length(app(range(2), range(2)))).toBe(4);
  expect(countFrom(0, 3)).toBe(4);
  expect(size(mirror(leaf))).toBe(0);
});

test("saved generic values distinguish undefined from an absent cell", () => {
  const seen: (string | undefined)[] = [];

  const combine = (left: string | undefined) => (right: string | undefined) => {
    seen.push(left, right);

    return left;
  };

  expect(savedValues(combine, 3, undefined, "present")).toBeUndefined();
  expect(seen).toEqual([
    undefined,
    undefined,
    "present",
    undefined,
    undefined,
    "present",
  ]);
  expect(
    savedValues<undefined>((left) => () => left, deep, undefined, undefined)
  ).toBeUndefined();
  expect(shuttle<string | undefined>(deep, undefined, "present")).toBe(
    "present"
  );
  expect(shuttle<undefined>(deep, undefined, undefined)).toBeUndefined();
  expect(
    app<string | undefined>(
      cons(undefined, cons("present", cons(undefined, nil))),
      cons("tail", nil)
    )
  ).toEqual(
    cons(undefined, cons("present", cons(undefined, cons("tail", nil))))
  );
  expect(shuttleList<string | undefined>(3, [undefined, "present"])).toEqual(
    cons(undefined, cons(undefined, nil))
  );
});

test("unused machine arguments preserve callback effects and order", () => {
  const seen: number[] = [];

  const visit =
    (marker: number) =>
    (xs: List<number>): List<number> => {
      seen.push(marker);

      return xs;
    };

  expect(observedOdd(visit, range(6), nil)).toBe(false);
  expect(seen).toEqual([1, 2, 1, 2, 1, 2]);
  seen.length = 0;
  expect(observedEven(visit, range(6))).toBe(true);
  expect(seen).toEqual([1, 2, 1, 2, 1, 2]);
});

test("unused tail-loop arguments still evaluate once per call", () => {
  const seen: number[] = [];

  const visit = (n: number): number => {
    seen.push(n);

    return n;
  };

  expect(observedTail(visit, 4, 0)).toBe(0);
  expect(seen).toEqual([4, 3, 2, 1]);
  expect(() =>
    observedTail(
      () => {
        throw new Error("visited");
      },
      1,
      0
    )
  ).toThrow("visited");
  expect(observedTail(visit, 0, 0)).toBe(0);
});

const discardedClosure = () => {
  throw new Error("discarded closure was evaluated");
};

test("discarded closures release their captured registers and copies", () => {
  expect(dropClosure(million, 42, discardedClosure)).toBe(0);
  expect(dropLetClosure(million, 42, discardedClosure)).toBe(0);
  expect(dropClosureChain(million, 42, 43, discardedClosure)).toBe(0);
  expect(dropMutualClosure(million, 42, 43, discardedClosure)).toBe(0);
  expect(dropMutualClosureOdd(million, 42, 43, discardedClosure)).toBe(0);
  expect(dropLocalClosure(million, 42)).toBe(0);
});

test("discarded closure captures preserve effects in dead register updates", () => {
  const seen: number[] = [];

  const visit = (n: number) => {
    seen.push(n);

    return n;
  };

  expect(dropEffectClosure(visit, 3, 42, () => 99)).toBe(0);
  expect(seen).toEqual([3, 2, 1]);
});
