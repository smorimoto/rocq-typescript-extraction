import { run } from "mitata";

import { verifyBenchmarks } from "./support.ts";

const suites = {
  bitsets: () => import("./bitsets.bench.ts"),
  bst: () => import("./bst.bench.ts"),
  "even-odd": () => import("./even-odd.bench.ts"),
  "fiat-crypto": () => import("./fiat-crypto.bench.ts"),
  fib: () => import("./fib.bench.ts"),
  integers: () => import("./integers.bench.ts"),
  pow: () => import("./pow.bench.ts"),
  runtime: () => import("./runtime.bench.ts"),
  sorts: () => import("./sorts.bench.ts"),
};

const filters = Bun.argv.slice(2);

const selected = Object.entries(suites).filter(
  ([name]) =>
    filters.length === 0 || filters.some((filter) => name.includes(filter))
);

if (selected.length === 0) {
  throw new Error(`No benchmark suites match: ${filters.join(", ")}`);
}

for (const [, load] of selected) {
  // oxlint-disable-next-line no-await-in-loop
  await load();
}

await run({ throw: true });

verifyBenchmarks();
