#!/usr/bin/env bash
# Check: RoleBinding shuttle-pod-reader in starfleet binds the Role pod-reader
# to the ServiceAccount shuttle in starfleet and to no other subject.
set -uo pipefail

if ! kubectl -n starfleet get rolebinding shuttle-pod-reader >/dev/null 2>&1; then
  echo "FAIL: RoleBinding shuttle-pod-reader does not exist in starfleet"
  exit 1
fi

fail=0
binding="$(kubectl -n starfleet get rolebinding shuttle-pod-reader -o json 2>/dev/null)"

if [ "$(printf '%s' "$binding" | jq -r '.roleRef.kind + "/" + .roleRef.name')" != "Role/pod-reader" ]; then
  echo "FAIL: roleRef must be Role/pod-reader"
  fail=1
fi
if [ "$(printf '%s' "$binding" | jq -c '[.subjects[]? | {kind, name, namespace}]')" != '[{"kind":"ServiceAccount","name":"shuttle","namespace":"starfleet"}]' ]; then
  echo "FAIL: the only subject must be the ServiceAccount shuttle in starfleet"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: shuttle-pod-reader binds Role pod-reader to ServiceAccount shuttle only"
fi
exit "$fail"
