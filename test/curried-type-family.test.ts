import { expect, test } from "bun:test";

import {
  Applied,
  callbackResult,
  cons,
  functionSeed,
  grammarEmpty,
  grammarFlag,
  grammarNumber,
  keepAction,
  keepCallbacks,
  keepFunction,
  keepPair,
  keepTwo,
  nil,
  pairedResult,
  Sample,
  twoActions,
  Use,
} from "./curried-type-family.ts";
import type {
  Arrows,
  Callbacks,
  Grammar,
  PairedArrows,
} from "./curried-type-family.ts";

const count =
  (enabled: boolean) =>
  (n: number): number =>
    enabled ? n : 0;

const consume =
  (flag: (_: number) => boolean) =>
  (value: (_: number) => number): number =>
    flag(0) ? value(2) : 0;

const pair =
  (enabled: boolean) =>
  (n: number): readonly [number, boolean] => [n, enabled];

const increment = (n: number): number => n + 1;

const isSix = (n: number): boolean => n === 6;

test("the regular alias accepts heterogeneous inputs and constrains the result", () => {
  const action: Arrows<number> = count;
  const inputs = cons(undefined, cons(undefined, nil));

  expect(keepAction<number>(inputs, action)).toBe(count);
  expect(keepAction<number>(nil, 11)).toBe(11);
  expect(keepAction<boolean>(nil, false)).toBe(false);
});

test("callback return types remain negative inside an action input", () => {
  const action: Callbacks<number> = consume;

  const inputs = cons(undefined, cons(undefined, nil));

  expect(keepCallbacks<number>(inputs, action)).toBe(consume);
  expect([callbackResult(true, 5), callbackResult(false, 5)])
    .toMatchInlineSnapshot(`
    [
      7,
      0,
    ]
  `);
});

test("later arguments constrain a function result before its producer", () => {
  expect(keepFunction<number, boolean>(nil, isSix, 0)).toBe(isSix);
  expect([functionSeed(3), functionSeed(2)]).toMatchInlineSnapshot(`
    [
      true,
      false,
    ]
  `);

  // @ts-expect-error the seed has the domain type of the final function
  keepFunction<number, boolean>(nil, isSix, true);
});

test("a shared unconstrained result retains each producer", () => {
  type Producer = typeof increment | typeof count;

  const inputs = cons(undefined, nil);
  const moreInputs = cons(undefined, inputs);
  const action: Arrows<Producer> = increment;
  const other: Arrows<Producer> = count;

  expect(keepTwo<Producer>(inputs, moreInputs, action, other)).toBe(increment);
  expect([twoActions(4), twoActions(0)]).toMatchInlineSnapshot(`
    [
      7,
      3,
    ]
  `);
});

test("a recursive alias keeps both captured result type parameters", () => {
  const action: PairedArrows<number, boolean> = pair;

  const inputs = cons(undefined, cons(undefined, nil));

  expect(keepPair<number, boolean>(inputs, action)).toBe(pair);
  expect([pairedResult(true, 8), pairedResult(false, 2)])
    .toMatchInlineSnapshot(`
    [
      [
        9,
        true,
      ],
      [
        3,
        false,
      ],
    ]
  `);
});

test("an extracted grammar instantiates a generic functor without specialization", () => {
  expect([
    grammarNumber(true, 8),
    grammarNumber(false, 8),
    grammarFlag(4, true),
    grammarFlag(3, true),
    grammarEmpty,
    Applied.get0(Sample.emptyRule),
  ]).toMatchInlineSnapshot(`
    [
      11,
      0,
      true,
      false,
      undefined,
      undefined,
    ]
  `);

  const grammar: Grammar<number, boolean> = {
    action: (enabled: boolean): Arrows<number> => (enabled ? increment : 5),
  };

  const applied = Use(grammar);

  expect(applied.get0(false)).toBe(5);
  expect(applied.get0(true)).toBe(increment);
});
