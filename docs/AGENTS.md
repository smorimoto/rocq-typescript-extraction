# Documentation Guide

`extraction.md` is the command, preset, and directive reference. `encoding.md` is the generated-API reference and the limitations list. `README.md` links both and `CONTRIBUTING.md`.

- A fenced block preceded by `<!-- sample: name -->` is verified by `test/docs` against a source `.v` or a generated `.ts`. Change the block together with its fixture; see `test/docs/AGENTS.md`.
- Document behaviour, not implementation. Tables map a Rocq construct to its TypeScript form, and a limitation says what fails and what to do instead. Backend module names do not appear here.
- When a backend or theory change alters what a user sees, update the matching table or limitation in the same change. A changed directive updates the preset and theory tables in `extraction.md`.
- Markdown is formatted by `oxfmt` through `bun run format`.
