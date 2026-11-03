#!/usr/bin/env bash
# Check: the scout ServiceAccount reads nodes and PersistentVolumes, proved by
# can-i answers and by real requests.
set -uo pipefail

SA="system:serviceaccount:starfleet:scout"
fail=0

for resource in nodes persistentvolumes; do
  for verb in get list watch; do
    answer="$(kubectl auth can-i "$verb" "$resource" --as="$SA" 2>/dev/null || true)"
    if [ "$answer" != "yes" ]; then
      echo "FAIL: scout cannot $verb $resource"
      fail=1
    fi
  done
done

if ! kubectl get nodes --as="$SA" >/dev/null 2>&1; then
  echo "FAIL: a real request to list nodes as scout was refused"
  fail=1
fi
if ! kubectl get persistentvolumes --as="$SA" >/dev/null 2>&1; then
  echo "FAIL: a real request to list PersistentVolumes as scout was refused"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: scout reads nodes and PersistentVolumes"
fi
exit "$fail"
