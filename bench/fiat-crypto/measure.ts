import path from "node:path";
import { pathToFileURL } from "node:url";

import type * as FiatCrypto from "../fiat-crypto.support.ts";

const source = path.resolve(
  process.argv[2] ?? "_build/default/bench/fiat-crypto.support.ts"
);

const { checkResults, workloads }: typeof FiatCrypto = await import(
  pathToFileURL(source).href
);

const measurements = [];

for (const { field, name, run, expected } of workloads) {
  checkResults(field, run(), expected);
  const warmupUntil = performance.now() + 100;
  let results: ReturnType<typeof run> = [];

  do {
    results = run();
  } while (performance.now() < warmupUntil);

  checkResults(field, results, expected);
  let elapsed = 0;
  let iterations = 0;

  while (iterations < 8 || elapsed < 1000) {
    const start = performance.now();
    results = run();
    elapsed += performance.now() - start;
    iterations += 1;
  }

  checkResults(field, results, expected);
  measurements.push({
    field: field.name,
    iterations,
    millisecondsPerBatch: elapsed / iterations,
    name,
    operationsPerBatch: expected.length,
  });
}

console.log(JSON.stringify({ measurements, node: process.version, source }));
