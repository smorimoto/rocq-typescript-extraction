#!/bin/sh
# Prints, for each golden under the current directory that contains the
# word unknown, its path and how many times the word occurs, and fails
# when a count is above the one that the pin file given as the only
# argument lists for that path, or when a golden the pin file does not
# list contains the word at all. The anti-slop rules see unknown only at
# the top of a parameter, a return type, or a type alias, not in an
# interface field, a tuple, or the type arguments of a call, so this
# counts the word itself. A golden is a .expected.ts or .expected.out
# file; the .lint.expected.out files hold Oxlint's diagnostics, whose
# rule names contain the word, and those of errors/ hold messages.
set -eu

pin=$1
find . \( -name '*.expected.ts' -o -name '*.expected.out' \) ! -name '*.lint.expected.out' ! -path './errors/*' |
	sed 's|^\./||' | LC_ALL=C sort | {
	status=0
	while IFS= read -r f; do
		n=$(grep -ow unknown "$f" | wc -l | tr -d ' ')
		[ "$n" -eq 0 ] && continue
		echo "$f $n"
		pinned=$(awk -v f="$f" '$1 == f { print $2 }' "$pin")
		if [ "$n" -gt "${pinned:-0}" ]; then
			echo "$f: $n occurrences of unknown, more than the ${pinned:-0} that $pin allows" >&2
			status=1
		fi
	done
	exit $status
}
