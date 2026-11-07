#!/bin/sh
set -eu

if ! grep -q '^Raised at ' "$1"; then
	echo 'Loading the plugin disabled requested backtraces.' >&2
	exit 1
fi

if grep -q '^Raised at ' "$2"; then
	echo 'Loading the plugin enabled backtraces that were off.' >&2
	exit 1
fi

if ! grep -q ',-backtrace,' "$3"; then
	echo 'Loading the plugin turned on the backtrace debug flag.' >&2
	exit 1
fi
