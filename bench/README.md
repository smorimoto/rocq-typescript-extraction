# Benchmarks

The benchmarks measure execution of extracted TypeScript under Bun with Mitata. Complete the [development setup](../CONTRIBUTING.md#development-setup), then run from the repository root:

```sh
opam exec -- bun run bench
```

Pass suite names to select workloads:

```sh
opam exec -- bun run bench fib pow
opam exec -- bun run bench fiat-crypto
```

## Workloads

| Suite | Workload and source |
| --- | --- |
| `sorts` | Merge sort from `Stdlib.Sorting.Mergesort.Sort`, instantiated with `Nat.leb` |
| `bst` | Persistent red-black set from `Stdlib.MSets.MSetRBT.Make`, instantiated with `N_as_OT` |
| `pow` | Binary exponentiation from `Stdlib.setoid_ring.Ring_theory.pow_N`, specialized to `nat` multiplication |
| `even-odd` | `Stdlib.Arith.PeanoNat.Nat.even` and `Nat.odd` |
| `integers` | Euclidean GCD from `Stdlib.ZArith.Zgcd_alt.Zgcd_alt`, including its proven iteration bound; bounded Collatz |
| `bitsets` | Subset-sum dynamic programming with bigint shifts and unions over 128 nonnegative weights |
| `runtime` | Primitive array allocation, byte-string creation and checksums, and Number bitwise checksums above 32 bits |
| `fib` | Synthetic Fibonacci accumulator loop, with a loop-to-specification proof |
| `fiat-crypto` | Upstream field arithmetic for Curve25519 and Poly1305; see the [suite guide](fiat-crypto/README.md) |

`bench/theories/` specializes upstream implementations for each preset. Upstream algorithm proofs belong to Stdlib; this project checks the extracted results. Bounded Collatz uses fuel and makes no claim of termination without that bound. Prefer existing verified implementations when adding workloads.

## Comparisons

For workloads representable exactly as JavaScript numbers, each group compares Number, BigInt, and a handwritten number implementation. Number is the summary reference. Number and handwritten versions use matching algorithms, traversal order, data structures, and iteration bounds. BigInt uses the same extracted workload with bigint arithmetic, so its comparison includes the cost of that representation and its preset mappings.

Large Fibonacci, exponentiation, and bitset cases exceed the exact number range and compare BigInt with handwritten bigint implementations instead. BigInt is their summary reference. The bitset result is checked against an independent boolean-array DP. Fiat Crypto is a separate BigInt-only suite. The runtime suite measures individual primitives and batched checksums without a handwritten baseline.

## Measurement boundaries

Inputs and expected results are prepared before timing. Each timed callback captures its results; validation runs before and after measurement. Input conversion between numbers and bigints, and conversion of list results to arrays, happen outside the timer. Coercions performed by a realiser during execution remain inside the timer.

Timing includes the work required by each algorithm: merge-stack construction and list allocation for sorting, 1,000 persistent inserts and 1,000 lookups for the tree workload, and the iteration-bound calculation for GCD. The handwritten baselines preserve the extracted algorithms' allocation and sharing behavior, including persistent path copying for duplicate tree keys.

The runtime suite allocates dense arrays of 1,024 and 65,536 references to a shared default object, reads all 4,096 bytes of a byte string, creates a 1,024-byte string, and computes a checksum over 4,096 signed integers with bits above position 32. Its result checks inspect every array entry, including presence and reference identity.

Correctness tests run with `opam exec -- dune test`. They cover independent expected results, immutable inputs, tree balance, structural equality and sharing, fuel exhaustion, signed integers, duplicate keys, and deep recursion.

Mitata reports wall time, including JIT and garbage collection effects. Compare runs on the same idle machine and runtime version. The Benchmarks workflow runs the same command on pushes to `main` and pull requests and records results in the job log; shared-runner timings can be noisy.

## Dependencies

Generated benchmark programs are not installed with the plugin. See the [third-party dependency notes](../CONTRIBUTING.md#third-party-dependencies) before distributing them separately.
