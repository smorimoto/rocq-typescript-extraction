#!/bin/sh
set -eu

dune build @test/runtime

# Dune's copies are read-only. Replace them with writable, independent files.
find test -name '*.test.ts' -exec sh -eu -c '
  for source do
    built="_build/default/$source"
    cp "$source" "$built.update"
    mv "$built.update" "$built"
  done
' sh {} +

(
	cd _build/default
	if [ "$#" -eq 0 ]; then
		set -- ./test
	fi
	bun test --timeout 60000 --update-snapshots "$@"
)

# Promote only runtime test sources after every selected test passes.
find test -name '*.test.ts' -exec sh -eu -c '
  for source do
    built="_build/default/$source"
    if ! cmp -s "$source" "$built"; then
      cp "$built" "$source"
    fi
  done
' sh {} +
