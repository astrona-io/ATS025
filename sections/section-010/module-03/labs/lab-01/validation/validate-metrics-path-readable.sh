#!/usr/bin/env bash
# Check: scout may GET /metrics, proved by can-i and by a real request, and
# the allowance is not a wildcard over every path.
set -uo pipefail

SA="system:serviceaccount:starfleet:scout"
fail=0

answer="$(kubectl auth can-i get /metrics --as="$SA" 2>/dev/null || true)"
if [ "$answer" != "yes" ]; then
  echo "FAIL: scout cannot get /metrics"
  fail=1
fi

if ! kubectl get --raw /metrics --as="$SA" >/dev/null 2>&1; then
  echo "FAIL: a real request for /metrics as scout was refused"
  fail=1
fi

for path in /logs /debug/pprof; do
  answer="$(kubectl auth can-i get "$path" --as="$SA" 2>/dev/null || true)"
  if [ "$answer" != "no" ]; then
    echo "FAIL: scout should not be allowed to get $path"
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "PASS: scout may read /metrics only"
fi
exit "$fail"
