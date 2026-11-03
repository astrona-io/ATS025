#!/usr/bin/env bash
# Check: the ServiceAccount can do what the controller loop needs.
set -uo pipefail

who="system:serviceaccount:beacon-system:beacon-operator"
status=0
check() {
  local verb="$1" res="$2" ns="${3:-}"
  local args=(auth can-i "$verb" "$res" --as="$who")
  [ -n "$ns" ] && args+=(-n "$ns")
  if [ "$(kubectl "${args[@]}" 2>/dev/null)" = "yes" ]; then
    echo "PASS: can ${verb} ${res}"
  else
    echo "FAIL: cannot ${verb} ${res}"
    status=1
  fi
}
check list beacons.training.astrona.io
check watch beacons.training.astrona.io
check update beacons.training.astrona.io
check update beacons.training.astrona.io/status
check create leases.coordination.k8s.io beacon-system
check update leases.coordination.k8s.io beacon-system
check create events beacon-system
exit "$status"
