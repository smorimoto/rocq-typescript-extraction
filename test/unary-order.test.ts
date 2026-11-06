import { expect, test } from "bun:test";

import type { Counter, Tick } from "./unary-order.ts";
import {
  Abstract,
  beyond,
  copyPlain,
  customWithin,
  customSuccessor,
  leb,
  ltb,
  o,
  s,
  empty,
  equalCounter,
  false0,
  Factory,
  Instance,
  more,
  origin,
  strictlyCustom,
  strictlyWithin,
  successorEqual,
  swappedWithin,
  tick,
  true0,
  twiceWithin,
  within,
  within0,
  withinAlias,
} from "./unary-order.ts";

interface MutableTick {
  previous: Counter;
  tag: "Tick";
}

const counter = (depth: number): Counter => {
  let result: Counter = origin;

  for (let index = 0; index < depth; index += 1) {
    result = tick(result);
  }

  return result;
};

const foreignCounter = (depth: number): Counter => {
  let result: Counter = Object.freeze({ tag: "Origin" });

  for (let index = 0; index < depth; index += 1) {
    result = Object.freeze({ previous: result, tag: "Tick" });
  }

  return result;
};

test("renamed unary comparison keeps its terminal objects and aliases", () => {
  for (let left = 0; left < 20; left += 1) {
    for (let right = 0; right < 20; right += 1) {
      const l = counter(left);
      const r = foreignCounter(right);
      const expected = left <= right ? within0 : beyond;
      const strict = left < right ? within0 : beyond;
      expect(strictlyWithin(l, r)).toBe(strict);
      expect(within(l, r)).toBe(expected);
      expect(within(l, r)).toBe(expected);
      expect(withinAlias(l, r)).toBe(expected);
      expect(equalCounter(l, r)).toBe(left === right ? true0 : false0);
      expect(strictlyWithin(l, r)).toBe(strict);
      expect(strictlyWithin(r, l)).toBe(right < left ? within0 : beyond);
    }
  }
});

test("only compared unary types freeze their generated wrappers", () => {
  const child: Tick = { previous: origin, tag: "Tick" };
  expect(Object.isFrozen(origin)).toBe(true);
  expect(Object.isFrozen(tick(child))).toBe(true);
  expect(Object.isFrozen(child)).toBe(false);
  expect(Object.isFrozen(empty)).toBe(false);
  expect(Object.isFrozen(more(empty))).toBe(false);
  expect(copyPlain(more(empty))).toStrictEqual(more(empty));
});

test("mutable roots and descendants retain comparison behaviour", () => {
  const mutable: MutableTick = {
    previous: origin,
    tag: "Tick",
  };

  const frozen = tick(tick(mutable));
  const limit = counter(3);
  expect(within(mutable, counter(1))).toBe(within0);
  expect(within(frozen, limit)).toBe(within0);
  mutable.previous = counter(4);
  expect(within(mutable, counter(1))).toBe(beyond);
  expect(within(frozen, limit)).toBe(beyond);
  mutable.previous = origin;
  expect(within(frozen, limit)).toBe(within0);
});

test("completed zero and nonzero depths reuse their certified entries", () => {
  let descriptors = 0;

  const handler: ProxyHandler<Counter> = {
    getOwnPropertyDescriptor(target, property) {
      descriptors += 1;

      return Reflect.getOwnPropertyDescriptor(target, property);
    },
  };

  const zero = new Proxy<Counter>(Object.freeze({ tag: "Origin" }), handler);
  const one = new Proxy(tick(zero), handler);
  expect(within(zero, zero)).toBe(within0);
  expect(within(one, one)).toBe(within0);
  descriptors = 0;

  for (let iteration = 0; iteration < 3; iteration += 1) {
    expect(within(zero, zero)).toBe(within0);
    expect(within(zero, one)).toBe(within0);
    expect(within(one, zero)).toBe(beyond);
    expect(within(one, one)).toBe(within0);
  }

  expect(descriptors).toBe(0);
});

test("complete and partial entries observe frontier mutation in both orders", () => {
  const frontier: MutableTick = { previous: origin, tag: "Tick" };
  const partial = tick(frontier);
  const complete = foreignCounter(3);
  expect(within(complete, complete)).toBe(within0);

  for (let iteration = 0; iteration < 3; iteration += 1) {
    expect(within(partial, complete)).toBe(within0);
    expect(within(complete, partial)).toBe(beyond);
    frontier.previous = counter(4);
    expect(within(partial, complete)).toBe(beyond);
    expect(within(complete, partial)).toBe(within0);
    frontier.previous = origin;
  }
});

test("the first child of a one-step partial prefix remains uncertified", () => {
  const frontier: MutableTick = { previous: origin, tag: "Tick" };
  const root = tick(frontier);
  expect(within(root, origin)).toBe(beyond);
  expect(within(frontier, origin)).toBe(beyond);
  expect(within(origin, frontier)).toBe(within0);
  expect(within(frontier, counter(1))).toBe(within0);
  frontier.previous = counter(2);
  expect(within(frontier, counter(1))).toBe(beyond);
  expect(within(counter(1), frontier)).toBe(within0);
});

test("accessors fall back without speculative getter reads", () => {
  const reads: string[] = [];

  const left: Tick = {
    get previous(): Counter {
      reads.push("left.previous");

      return origin;
    },
    get tag(): "Tick" {
      reads.push("left.tag");

      return "Tick";
    },
  };

  const right: Tick = {
    get previous(): Counter {
      reads.push("right.previous");

      return origin;
    },
    get tag(): "Tick" {
      reads.push("right.tag");

      return "Tick";
    },
  };

  Object.freeze(left);
  Object.freeze(right);
  expect(within(left, right)).toBe(within0);
  expect(reads).toMatchInlineSnapshot(`
    [
      "left.tag",
      "right.tag",
      "left.previous",
      "right.previous",
    ]
  `);
});

test("zero and unbalanced inputs bound descriptor inspection", () => {
  let descriptors = 0;

  const handler: ProxyHandler<Counter> = {
    getOwnPropertyDescriptor(target, property) {
      descriptors += 1;

      return Reflect.getOwnPropertyDescriptor(target, property);
    },
  };

  let deep: Counter = origin;

  for (let index = 0; index < 10_000; index += 1) {
    deep = new Proxy(tick(deep), handler);
  }

  expect(within(origin, deep)).toBe(within0);
  expect(descriptors).toBe(0);
  expect(within(counter(1), deep)).toBe(within0);
  expect(descriptors).toBeLessThanOrEqual(2);
  descriptors = 0;

  for (let index = 0; index < 100; index += 1) {
    expect(within(counter(1), deep)).toBe(within0);
  }

  expect(descriptors).toBe(0);
  descriptors = 0;
  expect(within(deep, origin)).toBe(beyond);
  expect(descriptors).toBeLessThanOrEqual(2);
});

test("public comparison signatures retain their constructors and custom definitions", () => {
  expect(leb(s(o), s(s(o)))).toBe(true0);
  expect(ltb(s(o), s(s(o)))).toBe(true0);
  expect(ltb(s(o), s(o))).toBe(false0);
  expect(customWithin(origin, origin)).toStrictEqual(beyond);
  expect(strictlyCustom(origin, tick(origin))).toStrictEqual(beyond);
  expect(customSuccessor(origin, tick(origin))).toBe(within0);
  expect(successorEqual(origin, tick(origin))).toBe(true0);
  expect(twiceWithin(origin, tick(origin))).toBe(beyond);
  expect(swappedWithin(tick(origin), origin)).toBe(within0);
  const one = tick(origin);
  expect(tick(origin)).toBe(one);
});

test("a partial prefix follows a mutable frontier until that frontier is frozen", () => {
  let descriptors = 0;

  const frontier = new Proxy<MutableTick>(
    { previous: origin, tag: "Tick" },
    {
      getOwnPropertyDescriptor(target, property) {
        descriptors += 1;

        return Reflect.getOwnPropertyDescriptor(target, property);
      },
    }
  );

  let left: Counter = frontier;

  for (let index = 0; index < 50; index += 1) {
    left = tick(left);
  }

  expect(within(left, counter(1))).toBe(beyond);
  expect(within(left, counter(51))).toBe(within0);
  frontier.previous = counter(3);
  expect(within(left, counter(51))).toBe(beyond);
  frontier.previous = origin;
  Object.freeze(frontier);
  expect(within(left, counter(51))).toBe(within0);
  expect(within(counter(51), left)).toBe(within0);
  descriptors = 0;
  expect(within(left, counter(51))).toBe(within0);
  expect(within(counter(51), left)).toBe(within0);
  expect(descriptors).toBe(0);
});

test("a frozen predecessor accessor is not read before the right zero branch", () => {
  let reads = 0;

  const left: Tick = {
    get previous(): Counter {
      reads += 1;

      return origin;
    },
    tag: "Tick",
  };

  Object.freeze(left);
  expect(within(left, origin)).toBe(beyond);
  expect(reads).toBe(0);
});

test("functor result members retain comparison and constructor signatures", () => {
  const first = Factory({ value: o });
  const second = Factory({ value: s(o) });
  expect(
    first.before(first.next0(first.reset), second.next0(second.reset))
  ).toBe(true0);
  expect(Instance.before(Instance.next0(Instance.reset), Instance.reset)).toBe(
    false0
  );
  expect(Object.isFrozen(first.next0(first.reset))).toBe(true);
  expect(first.strictlyBefore(first.reset, second.next0(second.reset))).toBe(
    true0
  );
  expect(Instance.strictlyBefore(Instance.reset, Instance.reset)).toBe(false0);
  expect(Abstract({ compare: within }).strict(origin, tick(origin))).toBe(
    within0
  );
});

test("strict comparison observes mutable roots and frozen prefixes on both sides", () => {
  const left: MutableTick = { previous: origin, tag: "Tick" };
  const right: MutableTick = { previous: counter(1), tag: "Tick" };
  const frozenLeft = tick(tick(left));
  const frozenRight = tick(tick(right));

  for (let iteration = 0; iteration < 3; iteration += 1) {
    expect(strictlyWithin(left, right)).toBe(within0);
    expect(strictlyWithin(frozenLeft, frozenRight)).toBe(within0);
    left.previous = counter(2);
    expect(strictlyWithin(left, right)).toBe(beyond);
    expect(strictlyWithin(frozenLeft, frozenRight)).toBe(beyond);
    right.previous = counter(4);
    expect(strictlyWithin(left, right)).toBe(within0);
    expect(strictlyWithin(frozenLeft, frozenRight)).toBe(within0);
    left.previous = origin;
    right.previous = counter(1);
  }
});

test("strict right zero reads its tag once without touching the left operand", () => {
  let reads = 0;

  const left: Tick = {
    get previous(): Counter {
      throw new Error("left predecessor was inspected");
    },
    get tag(): "Tick" {
      throw new Error("left tag was inspected");
    },
  };

  const right: Counter = Object.freeze({
    get previous(): Counter {
      throw new Error("right predecessor was inspected");
    },
    get tag(): "Origin" {
      reads += 1;

      return "Origin";
    },
  });

  Object.freeze(left);
  expect(within(tick(left), right)).toBe(beyond);
  expect(reads).toBe(1);
  reads = 0;
  expect(strictlyWithin(left, right)).toBe(beyond);
  expect(reads).toBe(1);
});

test("strict comparison preserves own and inherited frozen getter order", () => {
  const reads: string[] = [];

  const left: Tick = {
    get previous(): Counter {
      reads.push("left.previous");

      return origin;
    },
    get tag(): "Tick" {
      reads.push("left.tag");

      return "Tick";
    },
  };

  const right: Tick = {
    get previous(): Counter {
      reads.push("right.previous");

      return tick(origin);
    },
    get tag(): "Tick" {
      reads.push("right.tag");

      return "Tick";
    },
  };

  const inheritedLeft: Tick = Object.create(left);
  const inheritedRight: Tick = Object.create(right);

  for (const [l, r] of [
    [left, right],
    [inheritedLeft, inheritedRight],
  ] as const) {
    Object.freeze(l);
    Object.freeze(r);
    expect(within(tick(l), r)).toBe(within0);
    const expected = [...reads];
    reads.length = 0;
    expect(strictlyWithin(l, r)).toBe(within0);
    expect(reads).toStrictEqual(expected);
    expect(reads).toMatchInlineSnapshot(`
      [
        "right.tag",
        "right.previous",
        "left.tag",
        "left.previous",
      ]
    `);
    reads.length = 0;
  }
});

test("strict comparison reads a right predecessor that mutates the left first", () => {
  const left: MutableTick = { previous: origin, tag: "Tick" };
  let reads = 0;

  const right: Tick = Object.freeze({
    get previous(): Counter {
      reads += 1;
      left.previous = counter(2);

      return counter(2);
    },
    tag: "Tick",
  });

  expect(within(tick(left), right)).toBe(beyond);
  expect(reads).toBe(1);
  reads = 0;
  left.previous = origin;
  expect(strictlyWithin(left, right)).toBe(beyond);
  expect(reads).toBe(1);
});

test("strict and ordinary comparisons reuse bounded prefixes in both directions", () => {
  let descriptors = 0;

  const handler: ProxyHandler<Counter> = {
    getOwnPropertyDescriptor(target, property) {
      descriptors += 1;

      return Reflect.getOwnPropertyDescriptor(target, property);
    },
  };

  let first: Counter = origin;
  let second: Counter = origin;

  for (let index = 0; index < 10_000; index += 1) {
    first = new Proxy(tick(first), handler);
    second = new Proxy(tick(second), handler);
  }

  descriptors = 0;
  expect(strictlyWithin(origin, first)).toBe(within0);
  expect(descriptors).toBe(0);
  expect(strictlyWithin(counter(2), first)).toBe(within0);
  expect(descriptors).toBeLessThanOrEqual(4);
  expect(within(counter(40), first)).toBe(within0);
  descriptors = 0;
  expect(strictlyWithin(counter(39), first)).toBe(within0);
  expect(descriptors).toBe(0);
  expect(strictlyWithin(counter(39), second)).toBe(within0);
  descriptors = 0;
  expect(within(counter(39), second)).toBe(within0);
  expect(descriptors).toBeLessThanOrEqual(2);
  descriptors = 0;
  expect(strictlyWithin(first, origin)).toBe(beyond);
  expect(descriptors).toBe(0);
});
