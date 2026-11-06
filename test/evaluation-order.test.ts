import { expect, test } from "bun:test";

import {
  blue,
  false0,
  force0,
  fromTok,
  green,
  inBranch,
  inLambda,
  lazyLet,
  later,
  partialBoom,
  partialOk,
  red,
  strictBranch,
  true0,
  two,
} from "./evaluation-order.ts";
import { ofNumber, toNumber } from "./support.ts";

const boom = "AXIOM TO BE REALIZED";

test("a strict match runs only the case it takes", () => {
  expect(toNumber(strictBranch(ofNumber(2), red))).toBe(3);
  expect(toNumber(strictBranch(ofNumber(1), green))).toBe(3);
  expect(() => strictBranch(ofNumber(0), blue)).toThrow(boom);
});

test("a match in a returned function runs when the function is called", () => {
  const zero = inLambda(ofNumber(0));
  expect(() => zero(ofNumber(0))).toThrow(boom);
  expect(toNumber(inLambda(ofNumber(1))(ofNumber(1)))).toBe(2);
});

test("the untaken branch of a conditional does not run", () => {
  expect(toNumber(inBranch(false0, blue))).toBe(0);
  expect(toNumber(inBranch(true0, red))).toBe(1);
  expect(() => inBranch(true0, blue)).toThrow(boom);
});

test("a partial argument runs when the closure is built", () => {
  expect(() => partialBoom(ofNumber(0))).toThrow(boom);
  expect(toNumber(partialBoom(ofNumber(2))(ofNumber(1)))).toBe(2);
  const addOne = partialOk(ofNumber(0));
  expect(toNumber(addOne(ofNumber(1)))).toBe(2);
  expect(toNumber(addOne(ofNumber(2)))).toBe(3);
});

test("both matches of one call run once", () => {
  expect(toNumber(two(red, red))).toBe(5);
  expect(toNumber(two(blue, red))).toBe(7);
  expect(() => two(red, blue)).toThrow(boom);
});

test("a match in a lazy cell runs when the cell is forced", () => {
  const pending = later(ofNumber(0));
  expect(() => force0(pending)).toThrow(boom);
  expect(toNumber(force0(later(ofNumber(2))))).toBe(1);
});

test("a let in a lazy cell runs when the cell is forced", () => {
  const pending = lazyLet(ofNumber(0));
  expect(() => force0(pending)).toThrow(boom);
  expect(toNumber(force0(lazyLet(ofNumber(1))))).toBe(2);
});

test("only the branch that the match function calls runs", () => {
  expect(toNumber(fromTok(ofNumber(1), true, red))).toBe(2);
  expect(toNumber(fromTok(ofNumber(1), true, blue))).toBe(4);
  expect(() => fromTok(ofNumber(1), false, red)).toThrow(boom);
});
