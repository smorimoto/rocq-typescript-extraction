# Negative Tests

Every `.v` here ends in a `Fail` command, so compiling it succeeds only when the extraction command fails.

- A file in the theory's default module set is compiled as part of `TypeScriptExtractionErrors` and checks only that the command fails.
- A file excluded from the theory in `dune` and given a `rocq.extraction` stanza with `-test-mode` also pins the message: `Redirect "Name" Fail TypeScript Extraction ...` writes `Name.out`, diffed against `Name.expected.out`. Prefer this form; a message is part of the interface.
- Each `.v` says in a comment why the input is unsupported and, when one exists, the supported alternative the message should point to.
- A message names the declaration, says what the backend cannot do, and says what to do instead. Changing a message in `src/` changes these goldens; promote them in the same change.
- `.expected.out` files here are exempt from `no_unknown.sh`, since a message may mention `unknown`.
