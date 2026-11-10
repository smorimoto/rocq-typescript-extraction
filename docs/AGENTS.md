# Documentation Guide

`getting-started.md` covers installation and a first extraction. `extraction.md` is the command, preset, and directive reference. `encoding.md` is the generated-API reference and the limitations list. `README.md` links all three and `CONTRIBUTING.md`.

`docs.json` configures the Docs7 site, which is built from this folder alone, so relative links from these pages stay inside `docs/`. `.docs7ignore` keeps this file and the cppo templates off the site; a new page goes in the `docs.json` navigation.

- Edit `getting-started.cpp.md` and `encoding.cpp.md`, not their generated `.md` pages. Their `#include` directives embed the source `.v` or generated `.ts` from `test/docs`. Run `opam exec -- dune build @test/docs/runtest`, review the diff, then use `opam exec -- dune promote docs/getting-started.md docs/encoding.md`; see `test/docs/AGENTS.md`.
- Document behaviour, not implementation. Tables map a Rocq construct to its TypeScript form, and a limitation says what fails and what to do instead. Backend module names do not appear here.
- When a backend or theory change alters what a user sees, update the matching table or limitation in the same change. A changed directive updates the preset and theory tables in `extraction.md`.
- Markdown is formatted by `oxfmt` through `bun run format`.
