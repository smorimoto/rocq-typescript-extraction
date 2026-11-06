# Fiat Crypto benchmarks

This suite extracts the upstream `Crypto.Arithmetic.ModOps` theory for Curve25519 and Poly1305 with the BigInt preset's exact bigint arithmetic. It measures the high-level field operations, not Fiat Crypto's synthesis pipeline, generated C/Rust, or complete cryptographic protocols.

## Run

After the [development setup](../../CONTRIBUTING.md#development-setup), run from the repository root:

```sh
opam exec -- dune test
opam exec -- bun run bench fiat-crypto
```

See the [benchmark guide](../README.md) for the shared measurement conventions. The [historical runtime comparison](performance.md) records the effect of integer mapping inheritance and includes a standalone measurement command.

## Workloads and validation

| Arithmetic | Modulus    | Representation    |
| ---------- | ---------- | ----------------- |
| Curve25519 | 2^255 − 19 | Five 51-bit limbs |
| Poly1305   | 2^130 − 5  | Five 26-bit limbs |

[Programs.v](extracted/Programs.v) instantiates `carry_mulmod`, `carry_squaremod`, and `carrymod` for each modulus. Each uses two complete carry passes, followed by limbs 0 and 1 to propagate the wraparound carry. Results are lists of five bigint limbs; validation checks their residue modulo the field modulus, not whether they encode a canonical integer below it.

Each timed batch performs 32 operations on prepared lists and collects the results. Inputs cover zero, one, modulus and limb boundaries, a value beyond 2^53, and deterministic large values. Carry inputs have tripled limbs to exercise propagation. Input preparation and result checks run outside the timer; every output is checked before and after measurement.

[The correctness tests](../../test/fiat-crypto.test.ts) check all 1,024 multiplication pairs per modulus, squaring, carry propagation and idempotence, and rejection of malformed or incorrect results. The BigInt oracle validates correctness; it is not a performance baseline.

## Updating upstream sources

Git pins Fiat Crypto at `1e721c6f18c43b90922e7bc57fd64848e5cff2be` and its Rewriter submodule at `902bd7bfd807f4511fa07b0b1f07ca640f9da4a8`. Dune compiles the selected sources and their proofs unchanged.

After changing the Fiat Crypto revision, initialize its nested dependencies and regenerate the dependency manifest from the repository root:

```sh
git -C submodules/fiat-crypto submodule update --init --recursive --depth 1
opam exec -- bun bench/fiat-crypto/gen-dune.ts > submodules/fiat-crypto.dune
opam exec -- dune test
opam exec -- bun run bench fiat-crypto
```

The generator follows `Require` declarations from `Crypto.Arithmetic.ModOps` and fails on missing source files. Review the manifest and upstream licenses when updating. Builds do not download dependencies.

## Licensing

Fiat Crypto and Rewriter each offer a choice of MIT, Apache-2.0, or BSD-1-Clause licensing, as recorded in their [COPYRIGHT](https://github.com/mit-plv/fiat-crypto/blob/1e721c6f18c43b90922e7bc57fd64848e5cff2be/COPYRIGHT) and [Rewriter COPYRIGHT](https://github.com/mit-plv/rewriter/blob/902bd7bfd807f4511fa07b0b1f07ca640f9da4a8/COPYRIGHT) files. This benchmark uses the MIT option. Their original license texts, copyright notices, and author lists remain in the unmodified submodules; the repository's ISC license does not replace these terms.

Recursive checkout also fetches other third-party projects under their own licenses, including CoqPrime under LGPL-2.1. The selected Dune dependency closure builds only Crypto, Rewriter, and the separately installed Rocq Stdlib (LGPL-2.1-only); CoqPrime and the other nested projects are not built or linked into these benchmarks. The upstream theories and generated benchmark programs are not installed by the plugin package.

Generated benchmark TypeScript stays under `_build` and is not committed or published by these workflows. If distributing generated programs separately, include the applicable source licenses and copyright notices, including those for any extracted Stdlib code, and comply with their redistribution terms.
