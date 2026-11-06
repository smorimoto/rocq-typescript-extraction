#!/bin/sh
# Fails when a generated TypeScript file contains a type assertion: the
# word as (other than in "import * as", in "import type * as", and in the
# const assertion "as const", which fixes literal types without overriding
# the checker), an angle-bracket cast <T>x, or a non-null assertion x!
# before "." or ")". The checks are line patterns, so the word as inside a
# string literal or a header comment is reported too. The backend writes no
# other such text itself; only code from Extract directives could. A cast
# written <T>(x) looks like a generic arrow and is not reported; the
# backend's printer has no way to write either form.
#
# It also fails when the file declares a namespace, an enum, or anything
# with declare, which the output never does: on the word enum anywhere,
# since a reserved word names nothing, and on declare or namespace followed
# by what it declares, so a value named declare is not reported.
set -eu

as_word="(^|[^A-Za-z0-9_\$.])as([^A-Za-z0-9_\$]|\$)"
as_const="(^|[^A-Za-z0-9_\$.])as const([^A-Za-z0-9_\$]|\$)"
# Rocq apostrophes become the identifier character ʹ, including before <A>[].
angle_cast="(^|[^]A-Za-z0-9_\$)ʹ])<[A-Z][]A-Za-z0-9_\$ʹ,<>.|[ ]*>[A-Za-z0-9_\$\"'[{]"
non_null="[]A-Za-z0-9_\$)]![.)]"
legacy="(^|[^A-Za-z0-9_\$.])((declare|namespace)[[:space:]]+[A-Za-z_\$\"'{]|enum([^A-Za-z0-9_\$]|\$))"

status=0
for f in "$@"; do
	if sed -E "s/$as_const/\1\2/g" "$f" | grep -nE "$as_word" | grep -vE '^[0-9]+:import (type )?\* as '; then
		echo "$f: a type assertion with as" >&2
		status=1
	fi
	if grep -nE "$angle_cast" "$f"; then
		echo "$f: an angle-bracket type assertion" >&2
		status=1
	fi
	if grep -nE "$non_null" "$f"; then
		echo "$f: a non-null assertion" >&2
		status=1
	fi
	if grep -nE "$legacy" "$f"; then
		echo "$f: a namespace, an enum, or a declare" >&2
		status=1
	fi
done
exit $status
