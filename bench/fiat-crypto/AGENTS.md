# Fiat Crypto Suite

BigInt-only benchmarks of `Crypto.Arithmetic.ModOps` for Curve25519 and Poly1305 from the pinned `submodules/fiat-crypto`. `README.md` documents the workloads, validation, and licensing.

- `extracted/Programs.v` instantiates the field operations, and `extracted/dune` extracts `fields.ts` against the `Crypto`, `Rewriter`, and `Stdlib` theories that `submodules/fiat-crypto.dune` selects.
- `../fiat-crypto.support.ts` defines the fields, workloads, and `checkResults`; `../fiat-crypto.bench.ts` registers them; `measure.ts` is a standalone timer over the same workloads, used for the record in `performance.md`.
- `gen-dune.ts` generates `submodules/fiat-crypto.dune` by following `Require` from `ModOps` and fails on a missing source. After bumping the submodule, run `git -C submodules/fiat-crypto submodule update --init --recursive --depth 1`, regenerate the manifest with `opam exec -- bun bench/fiat-crypto/gen-dune.ts > submodules/fiat-crypto.dune`, review the upstream licences, then run `dune test` and `bun run bench fiat-crypto`.
- Results are validated by residue modulo the field, not by canonical form. `test/fiat-crypto.test.ts` is the correctness oracle over all 1,024 pairs per modulus; the benchmark is not.
- `performance.md` is a dated record of one measurement. Add a new dated section rather than editing its numbers.
