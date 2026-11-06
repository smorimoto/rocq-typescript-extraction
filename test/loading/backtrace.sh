#!/bin/sh
set -eu

if ! grep -q '^Raised at ' "$1"; then
	echo 'Loading the plugin disabled requested backtraces.' >&2
	exit 1
fi

if grep -q '^Raised at ' "$2"; then
	echo 'Reloading the plugin enabled disabled backtraces.' >&2
	exit 1
fi
