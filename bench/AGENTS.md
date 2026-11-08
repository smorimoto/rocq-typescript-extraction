# Benchmark Guide

Mitata benchmarks of extracted TypeScript under Bun. `README.md` documents the workloads, comparisons, and measurement boundaries; this file covers the harness.

## Layout

- `theories/` is the `Bench` theory: one `.v` per workload that specialises a Stdlib development. Upstream proofs stay in Stdlib; `Fib.v` carries its own loop-to-specification proof.
- `number/Programs.v` and `bigint/Programs.v` extract the same definitions under each preset, and `runtime/Programs.v` extracts primitives. Each `dune` runs `no_assertions.sh`, `oxlint`, and `oxfmt` on the output without a golden, since the benchmark measures the code rather than its text.
- `foo.bench.ts` registers Mitata groups. `foo.baseline.ts` and `foo.bigint-baseline.ts` are the handwritten references, `foo.support.ts` holds shared inputs or checkers, and `data.ts` converts between arrays and the extracted `List`.
- `run.ts` is the registry: a suite exists once it is in the `suites` table, and command-line arguments filter by substring. `bun run bench` builds `@bench` and runs `_build/default/bench/run.ts`, so imports resolve against the build copy.
- Correctness of the extracted workloads is tested under `test/` (`benchmark-baselines.test.ts`, `bitsets.test.ts`, `fiat-crypto.test.ts`, `runtime-bench.t`), not here.

## Writing a benchmark

- `benchmarkComparison` is for a workload exact in a `number`: the Number preset is the baseline, and BigInt and the handwritten version compare against it. `benchmarkBigInt` is for values beyond 2^53, with BigInt as the baseline.
- Every timed callback goes through `checkedBench`: the result is checked before timing and again after `run` by `verifyBenchmarks`. `expected` is an independently computed value, never one read off the extracted code.
- Prepare inputs and convert results outside the timed callback; a coercion inside a realiser stays inside it. `observe` turns a result into something `deepStrictEqual` can compare.
- A handwritten baseline keeps the extracted algorithm's traversal order, data structures, allocation, and sharing, as `bst.baseline.ts` keeps persistent path copying, so the comparison measures the representation and not a different algorithm.
- Prefer an existing verified implementation from Stdlib for a new workload, and add its Bun correctness test under `test/` with it.
