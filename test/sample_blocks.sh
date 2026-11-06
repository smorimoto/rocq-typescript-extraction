#!/bin/sh
# Fails when the fenced code block that follows the marker
# "<!-- sample: $2 -->" in the Markdown file $1 differs from the file $3.
set -eu

block=$(awk -v name="$2" '
	$0 == "<!-- sample: " name " -->" { armed = 1; next }
	armed && !open && /^```/ { open = 1; next }
	open && /^```/ { exit }
	open { print }
' "$1")
printf '%s\n' "$block" | diff -u "$3" -
