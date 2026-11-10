# Workflows

- `ci.yml` builds and tests on `ubuntu-26.04` with `ocaml/setup-ocaml` and `jdx/mise-action`. A separate `lint` job runs shellcheck, shfmt, jactionlint, and `bun run lint` without an OCaml toolchain. `benchmarks.yml` runs `bun run bench` and records results in the job log.
- `release.yml` runs on every push to `main`. While `.changeset/` holds changesets, `changesets/action` opens or updates the `chore(release): version packages` pull request. After that pull request merges, the action tags `vX.Y.Z` and creates the GitHub release, and the `opam` job runs `opam-publish` to open a pull request on `ocaml/opam-repository`.
- The `changesets` job of `release.yml` uses the default `GITHUB_TOKEN`, so CI on the version pull request waits until a maintainer approves the runs. Only the `opam` job reads a secret, `OPAM_PUBLISH_GH_TOKEN`, because `GITHUB_TOKEN` cannot write to another repository.
- Actions are pinned to a commit SHA with the version in a trailing comment. Keep that form when updating.
- `jactionlint.yaml` selects the pedantic profile. Run `jactionlint` before pushing a workflow change.
- Tool versions come from `mise.toml`, so a bump there changes CI as well.
