# Workflows

- `ci.yml` builds and tests on `ubuntu-26.04` with `ocaml/setup-ocaml` and `jdx/mise-action`. A separate `lint` job runs shellcheck, shfmt, jactionlint, and `bun run lint` without an OCaml toolchain. `benchmarks.yml` runs `bun run bench` and records results in the job log.
- Actions are pinned to a commit SHA with the version in a trailing comment. Keep that form when updating.
- `jactionlint.yaml` selects the pedantic profile. Run `jactionlint` before pushing a workflow change.
- Tool versions come from `mise.toml`, so a bump there changes CI as well.
