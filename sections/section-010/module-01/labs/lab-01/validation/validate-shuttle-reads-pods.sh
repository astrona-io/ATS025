#!/usr/bin/env bash
# Check: shuttle can get, list and watch pods in starfleet, proved by can-i
# answers and by a real request.
set -uo pipefail

SA="system:serviceaccount:starfleet:shuttle"
fail=0

for verb in get list watch; do
  answer="$(kubectl auth can-i "$verb" pods -n starfleet --as="$SA" 2>/dev/null || true)"
  if [ "$answer" != "yes" ]; then
    echo "FAIL: shuttle cannot $verb pods in starfleet"
    fail=1
  fi
done

if ! kubectl get pods -n starfleet --as="$SA" >/dev/null 2>&1; then
  echo "FAIL: a real request to list pods in starfleet as shuttle was refused"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: shuttle reads pods in starfleet"
fi
exit "$fail"
