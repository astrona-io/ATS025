#!/usr/bin/env bash
# Check: the ServiceAccount has the loop permissions and nothing wider.
set -uo pipefail

who="system:serviceaccount:mission-system:mission-operator"
status=0
if ! kubectl -n mission-system get serviceaccount mission-operator >/dev/null 2>&1; then
  echo "FAIL: ServiceAccount mission-operator does not exist"
  exit 1
fi
want() {
  local verb="$1" res="$2" ns="${3:-}"
  local args=(auth can-i "$verb" "$res" --as="$who")
  [ -n "$ns" ] && args+=(-n "$ns")
  if [ "$(kubectl "${args[@]}" 2>/dev/null)" = "yes" ]; then echo "PASS: can ${verb} ${res}"; else echo "FAIL: cannot ${verb} ${res}"; status=1; fi
}
refuse() {
  if [ "$(kubectl auth can-i "$1" "$2" --as="$who" 2>/dev/null)" = "yes" ]; then echo "FAIL: can ${1} ${2}, which is not needed"; status=1; else echo "PASS: cannot ${1} ${2}"; fi
}
want watch missions.training.astrona.io
want update missions.training.astrona.io/status
want create leases.coordination.k8s.io mission-system
want create events mission-system
refuse delete missions.training.astrona.io
refuse get secrets
refuse delete nodes
exit "$status"
