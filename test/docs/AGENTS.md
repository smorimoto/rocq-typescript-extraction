# Documentation Samples

Builds the examples in `docs/` and embeds them in the published Markdown with cppo.

- `../../docs/getting-started.cpp.md` includes `Tree.v`; `../../docs/encoding.cpp.md` includes the freshly extracted `point.ts`, not its golden. Dune runs `cppo -n` to generate both pages here and diffs them against the committed pages in `docs/`.
- Edit prose in the `.cpp.md` templates and code in the included files. Update the corresponding `.cases.ts` and `.t` or `.test.ts` when behaviour changes. Run `opam exec -- dune build @test/docs/runtest`, review the Markdown and golden diffs, then promote the intended files with `opam exec -- dune promote`. A normal test run never updates them.
- A new sample needs a `rocq.extraction` stanza, a golden diff rule, and its file added to the `no_assertions.sh`, `oxlint`, and `oxfmt` rules in `dune`. Add its `#include` to the template and declare the included file in the cppo rule's `deps` so Dune rebuilds the page when it changes and makes it available in the sandbox.
