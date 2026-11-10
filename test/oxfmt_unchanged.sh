#!/bin/sh
# Fails when oxfmt, under the configuration $1, would change the file $2.
set -eu

formatted=$(bun oxfmt --config "$1" --stdin-filepath=program.ts <"$2")
printf '%s\n' "$formatted" | diff -u "$2" -
