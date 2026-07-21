#!/bin/sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

fail() {
    echo "RouterOS control-flow validation failed: $1" >&2
    exit 1
}

if grep -En ':return[[:space:]]*([;}]|$)' "$ROOT_DIR"/*.rsc; then
    fail 'value-less :return found'
fi

if grep -En 'export file=.*where' "$ROOT_DIR"/update-*.rsc; then
    fail 'unsupported filtered export found'
fi

for updater in "$ROOT_DIR"/update-*.rsc; do
    grep -q 'verbose=yes dry-run' "$updater" || fail "missing import preflight in $updater"
    grep -q 'backupList' "$updater" || fail "missing staged backup in $updater"
    grep -q 'old list restored' "$updater" || fail "missing rollback in $updater"
done

printf 'RouterOS updater control flow is valid\n'
