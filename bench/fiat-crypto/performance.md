# Historical Fiat Crypto runtime comparison

These measurements use Node and the benchmark harness available at the time. For the current Bun/Mitata suite, see the [benchmark guide](README.md#run).

Measured on 2026-11-05 with Node v26.13.0 on an Apple M4 (arm64, 10 cores), using the pinned sources and deterministic inputs described in [README.md](README.md). These are local wall-clock measurements, not CodSpeed simulation results. Both versions use the runtime generator from `main` at `ed72c8d`; the before version omits the constant-realiser inheritance change, and the after version includes it. The benchmark sources and harness are identical.

The TypeScript backend now inherits a constant realiser from its kernel-canonical original when the alias has no explicit realiser. This lets Stdlib’s included integer operations use the existing BigInt realisers. The upstream algorithms, wrappers, inputs, carry schedule, and numeric representation are unchanged.

## Results

Each entry is milliseconds per batch of 32 complete extracted field operations, including output collection. Median and range are across five fresh processes per version, run in alternating before/after order. Each process warms up every workload for at least 100 ms and measures at least eight batches and one second; result checks run outside the timer. [measure.ts](measure.ts) uses the same workloads and checks as the benchmarks.

| Field | Operation | Before median (range), ms | After median (range), ms | Speedup |
| --- | --- | --: | --: | --: |
| Curve25519 | `carry_mulmod` | 425.816 (421.461–438.513) | 2.218 (2.196–2.243) | 192.0× |
| Curve25519 | `carry_squaremod` | 391.793 (389.757–397.354) | 2.115 (2.079–2.147) | 185.2× |
| Curve25519 | `carrymod` | 322.115 (320.556–327.952) | 1.794 (1.791–1.814) | 179.6× |
| Poly1305 | `carry_mulmod` | 206.812 (205.715–208.077) | 2.148 (2.132–2.163) | 96.3× |
| Poly1305 | `carry_squaremod` | 191.662 (191.470–195.255) | 2.069 (2.058–2.119) | 92.6× |
| Poly1305 | `carrymod` | 163.373 (160.123–165.010) | 1.788 (1.777–1.868) | 91.4× |

Multiplication is now about 69 µs per Curve25519 field operation and 67 µs per Poly1305 field operation. These are batch averages for the high-level arithmetic theory, not timings for a complete X25519 exchange, Poly1305 authentication, or Fiat Crypto’s generated C/Rust implementations.

Background services were active when measurement started (load average 2.17 on 10 cores). Alternating the versions limits drift; the observed separation is much larger than the run-to-run variation.

## Cause and validation

Separate Node CPU profiles showed the original runtime dominated by the recursive `Z.pos_div_eucl`, `Z.pos_sub`, and `Z.pow_pos` implementations and their repeated integer operations. The new extraction replaces these paths with the existing BigInt realisers. The remaining CPU time is spread across native BigInt exponentiation/division and conversions between positional limbs and associational lists. Profiling was excluded from the measurements above.

`dune test` passes, including all 1,024 multiplication pairs per field, carry and square checks, Stdlib negative and zero-divisor arithmetic, and inheritance/override regressions. TypeScript checking and lint pass. At measurement time, all six Node 26 Vitest benchmarks and the local CodSpeed simulation-mode dry run passed.

## Individual runs

Columns are multiplication, squaring, and carry propagation for each field. All values are milliseconds per batch of 32.

| Run | Version | Curve mul | Curve square | Curve carry | Poly mul | Poly square | Poly carry |
| --- | --- | --: | --: | --: | --: | --: | --: |
| 1 | before | 421.461 | 389.757 | 320.556 | 207.592 | 195.255 | 160.123 |
| 1 | after | 2.243 | 2.147 | 1.814 | 2.160 | 2.094 | 1.814 |
| 2 | before | 424.581 | 390.153 | 321.783 | 205.715 | 191.470 | 162.246 |
| 2 | after | 2.228 | 2.117 | 1.811 | 2.163 | 2.119 | 1.868 |
| 3 | before | 438.513 | 393.822 | 327.952 | 206.812 | 194.131 | 165.010 |
| 3 | after | 2.196 | 2.079 | 1.794 | 2.145 | 2.063 | 1.777 |
| 4 | before | 425.816 | 391.793 | 322.115 | 205.866 | 191.659 | 163.373 |
| 4 | after | 2.218 | 2.112 | 1.791 | 2.132 | 2.058 | 1.788 |
| 5 | before | 430.390 | 397.354 | 326.396 | 208.077 | 191.662 | 163.532 |
| 5 | after | 2.208 | 2.115 | 1.794 | 2.148 | 2.069 | 1.777 |

## Reproduce

Build the benchmark, then run the standalone measurement under the desired Node version:

```sh
opam exec -- dune build @bench
node bench/fiat-crypto/measure.ts
```

For an alternating comparison, save each version’s `fiat-crypto.support.ts` with its generated `fiat-crypto/extracted/fields.ts` at the same relative path in separate directories. Pass the saved support file to the measurement script:

```sh
for run in 1 2 3 4 5; do
  node bench/fiat-crypto/measure.ts /tmp/fiat-before/fiat-crypto.support.ts
  node bench/fiat-crypto/measure.ts /tmp/fiat-after/fiat-crypto.support.ts
done
```

The script exits on an incorrect result and prints JSON containing the Node version, input module, batch size, iteration count, and mean batch time. Profile separately from timing. The generated `fields.ts` SHA-256 values for the runs above are:

- Before: `a88f3e47845fea0152de6dfd2076be005004666f3117da7531d5e34c3963c6a7`.
- After: `9845eff14592290a3bc51c1670f7ab5dc74ac790897905a5399d5454548e4a66`.
