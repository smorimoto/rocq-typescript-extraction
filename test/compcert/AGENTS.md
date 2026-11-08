# CompCert Suite

Integration tests that extract the LGPL subset of CompCert pinned in `submodules/compcert` under the BigInt preset. `README.md` documents coverage, licensing, and the update procedure; this file covers working in the directory.

- `Typing.v`, `MemoryModel.v`, and `Reference.v` are the extraction preludes. `../compcert-theories/Programs.v` holds the thin wrappers and the 18 observation cases that both backends run; it is a separate theory because a theory and an extraction cannot share a directory.
- `reference.t` compares this backend with standard OCaml extraction: `oracle.ml` links the extracted `reference.ml` and prints rows, `reference-observations.ts` prints the same rows from `typing.ts` and `memory.ts`, and the transcript diffs them. Neither backend's output is committed.
- `typing.test.ts` and `memory.test.ts` assert independently specified ASTs, errors, layouts, and memory results. Do not derive an expectation from the extracted code.
- The generated files are linted with `generated.oxlint.ts`, which extends the root config and allows the redundant branches and self-assignments that continuation loops produce. Add a rule there only for a pattern the backend cannot avoid in this code.
- `gen-dune.ts` writes `submodules/compcert.dune` from `Require` dependencies within the allowed LGPL subset; the test diffs the committed manifest against a fresh run. After bumping the submodule, regenerate with `opam exec -- bun test/compcert/gen-dune.ts > submodules/compcert.dune` and review upstream licences.
- Run the suite alone with `opam exec -- dune build @test/runtime @test/compcert/runtest`, then `bun test _build/default/test/compcert`.
