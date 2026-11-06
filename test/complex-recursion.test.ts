import { expect, test } from "bun:test";

import {
  branchCount,
  op0,
  op1,
  op2,
  op3,
  op4,
  op5,
  op6,
  op7,
  op8,
  op9,
  op10,
  op11,
  op12,
  op13,
  op14,
  op15,
  op16,
  op17,
  op18,
  op19,
  op20,
  op21,
  op22,
  op23,
} from "./complex-recursion.ts";

const opcodes = [
  op0,
  op1,
  op2,
  op3,
  op4,
  op5,
  op6,
  op7,
  op8,
  op9,
  op10,
  op11,
  op12,
  op13,
  op14,
  op15,
  op16,
  op17,
  op18,
  op19,
  op20,
  op21,
  op22,
  op23,
];

test("all branches of a large non-tail recursive function preserve their results", () => {
  for (const [i, opcode] of opcodes.entries()) {
    expect(branchCount(0, opcode)).toBe(0);
    expect(branchCount(3, opcode)).toBe(3 * (i + 1));
  }
});

test("large non-tail recursive functions run beyond the JavaScript stack limit", () => {
  expect(branchCount(100_000, op0)).toBe(100_000);
  expect(branchCount(100_000, op23)).toBe(2_400_000);
});
