#!/usr/bin/env bash
# Tests for check_merge_gate.py. Run from the repo root.
set -euo pipefail
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
run() { uv run --no-build --project tools python scripts/check_merge_gate.py "$1" ci-ok >/dev/null 2>&1; }

printf 'jobs:\n  a: {}\n  b: {}\n  ci-ok:\n    needs: [a, b]\n' > "$tmp/ok.yml"
printf 'jobs:\n  a: {}\n  b: {}\n  ci-ok:\n    needs: [a]\n' > "$tmp/missing.yml"
printf 'jobs:\n  a: {}\n  ci-ok:\n    needs: a\n' > "$tmp/string.yml"
printf 'jobs:\n  a: {}\n' > "$tmp/nogate.yml"

run "$tmp/ok.yml" || { echo "FAIL: complete needs rejected"; exit 1; }
run "$tmp/string.yml" || { echo "FAIL: string needs rejected"; exit 1; }
if run "$tmp/missing.yml"; then echo "FAIL: missing job accepted"; exit 1; fi
if run "$tmp/nogate.yml"; then echo "FAIL: missing gate accepted"; exit 1; fi
echo "check_merge_gate: 4 cases passed"
