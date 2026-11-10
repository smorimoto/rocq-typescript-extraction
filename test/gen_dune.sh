#!/bin/sh
set -e

# Pathname expansion sorts by the locale's collation, which differs between
# macOS and Linux, so the stanzas would come out in another order on CI.
export LC_ALL=C

# A test Foo.v extracts to foo.ts, its name in kebab-case as Ts_names
# writes the file names of separate extraction.
set --
for v in *.v; do
	[ -e "$v" ] || continue
	name=${v%.v}
	file=$(printf '%s' "$name" | sed -E 's/_/-/g; s/([a-z0-9])([A-Z])/\1-\2/g; s/([A-Z])([A-Z][a-z])/\1-\2/g' | tr '[:upper:]' '[:lower:]')
	theories=TypeScriptExtraction
	if grep -q '^From Stdlib Require ' "$v"; then
		theories="$theories Stdlib"
	fi
	set -- "$@" "$file.ts"
	cat <<STANZA
(rocq.extraction
 (prelude $name)
 (extracted_files $file.ts)
 (theories $theories))

(rule
 (alias runtest)
 (action
  (diff $file.expected.ts $file.ts)))

(rule
 (alias runtest)
 (action
  (run sh %{dep:no_assertions.sh} %{dep:$file.ts})))

STANZA
done

# One invocation per tool checks every root fixture. The dependency list
# comes from the same inputs as the extraction and golden rules above.
[ "$#" -gt 0 ] || exit 0
cat <<'STANZA'
(rule
 (alias runtest)
 (action
  (progn
   (run
    bun
    oxlint
    --config
    %{dep:../oxlint.config.ts}
    --deny-warnings
STANZA
for file; do
	printf '    %%{dep:%s}\n' "$file"
done
cat <<'STANZA'
   )
   (run
    bun
    oxfmt
    --config
    %{dep:../oxfmt.config.ts}
    --check
STANZA
for file; do
	printf '    %%{dep:%s}\n' "$file"
done
printf '   ))))\n'
