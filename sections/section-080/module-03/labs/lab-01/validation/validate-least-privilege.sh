#!/usr/bin/env bash
# Check: the ServiceAccount is not over-privileged.
set -uo pipefail

who="system:serviceaccount:beacon-system:beacon-operator"
status=0
refuse() {
  local verb="$1" res="$2"
  if [ "$(kubectl auth can-i "$verb" "$res" --as="$who" 2>/dev/null)" = "yes" ]; then
    echo "FAIL: can ${verb} ${res}, which the controller does not need"
    status=1
  else
    echo "PASS: cannot ${verb} ${res}"
  fi
}
if ! kubectl -n beacon-system get serviceaccount beacon-operator >/dev/null 2>&1; then
  echo "FAIL: ServiceAccount beacon-operator does not exist"
  exit 1
fi
refuse delete beacons.training.astrona.io
refuse delete nodes
refuse get secrets
refuse create deployments.apps
exit "$status"
