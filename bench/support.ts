import { deepStrictEqual } from "node:assert";

import { bench, summary } from "mitata";

export { ofArray, toArray } from "./data.ts";

export const identity = <A>(value: A): A => value;

export const lcg = ({
  count,
  modulus,
}: {
  readonly count: number;
  readonly modulus: number;
}): number[] => {
  const out: number[] = [];
  let x = 1;

  for (let i = 0; i < count; i += 1) {
    x = (x * 48_271) % 2_147_483_647;
    out.push(x % modulus);
  }

  return out;
};

const checks: (() => void)[] = [];

export const checkedBench = <A>(
  name: string,
  run: () => A,
  check: (result: A) => void
): ReturnType<typeof bench> => {
  let result = run();
  check(result);

  const trial = bench(name, () => {
    result = run();
  });

  checks.push(() => check(result));

  return trial;
};

export const verifyBenchmarks = (): void => {
  for (const check of checks) {
    check();
  }
};

export const benchmarkComparison = <A, B, C, D>({
  name,
  number,
  bigint,
  handWritten,
  observe,
  observeBigInt,
  expected,
  expectedBigInt,
}: {
  readonly name: string;
  readonly number: () => A;
  readonly bigint: () => B;
  readonly handWritten: () => A;
  readonly observe: (result: A) => C;
  readonly observeBigInt: (result: B) => D;
  readonly expected: C;
  readonly expectedBigInt: D;
}): void => {
  const numberName = `${name} Number`;
  const bigintName = `${name} BigInt`;
  const handwrittenName = `${name} hand-written`;

  summary(() => {
    checkedBench(numberName, number, (result) => {
      deepStrictEqual(observe(result), expected, numberName);
    }).baseline();
    checkedBench(bigintName, bigint, (result) => {
      deepStrictEqual(observeBigInt(result), expectedBigInt, bigintName);
    });
    checkedBench(handwrittenName, handWritten, (result) => {
      deepStrictEqual(observe(result), expected, handwrittenName);
    });
  });
};

export const benchmarkBigInt = <A, B>({
  name,
  handWritten,
  bigint,
  observe,
  expected,
}: {
  readonly name: string;
  readonly handWritten: () => A;
  readonly bigint: () => A;
  readonly observe: (result: A) => B;
  readonly expected: B;
}): void => {
  const bigintName = `${name} BigInt`;
  const handwrittenName = `${name} hand-written bigint`;

  summary(() => {
    checkedBench(bigintName, bigint, (result) => {
      deepStrictEqual(observe(result), expected, bigintName);
    }).baseline();
    checkedBench(handwrittenName, handWritten, (result) => {
      deepStrictEqual(observe(result), expected, handwrittenName);
    });
  });
};
