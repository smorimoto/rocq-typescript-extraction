# Documentation Samples

Checks that the examples in `docs/` are real. Each `.v` here is the source of a marked sample, and its output is diffed against the Markdown block.

- `../sample_blocks.sh` takes a Markdown file, a marker name, and a file, and diffs the fenced block after `<!-- sample: name -->` against that file. `Tree.v` must equal the block in `docs/getting-started.md` verbatim, and `point.ts` must equal the block in `docs/encoding.md`.
- Editing a documented example means editing the `.v` here, the Markdown block, the `.expected.ts` golden, and the `.cases.ts` and `.t` or `.test.ts` beside it, in one change. Run `opam exec -- dune build @test/docs/runtest`.
- A new sample needs a `rocq.extraction` stanza, a golden diff rule, a `sample_blocks.sh` rule, and its file added to the `no_assertions.sh`, `oxlint`, and `oxfmt` rules in `dune`.
