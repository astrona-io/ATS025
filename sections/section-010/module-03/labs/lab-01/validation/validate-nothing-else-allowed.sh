#!/usr/bin/env bash
# Check: scout cannot change nodes or PersistentVolumes and cannot read pods,
# Secrets or namespaces.
set -uo pipefail

SA="system:serviceaccount:starfleet:scout"
fail=0

denied() {
  local answer
  answer="$(kubectl auth can-i "$@" --as="$SA" 2>/dev/null || true)"
  if [ "$answer" != "no" ]; then
    echo "FAIL: scout should not be allowed: $*"
    fail=1
  fi
}

for verb in create update patch delete; do
  denied "$verb" nodes
  denied "$verb" persistentvolumes
done
denied list pods --all-namespaces
denied list pods -n starfleet
denied get secrets -n starfleet
denied list secrets --all-namespaces
denied list namespaces
denied create clusterrolebindings.rbac.authorization.k8s.io

if [ "$fail" -eq 0 ]; then
  echo "PASS: scout cannot change anything and cannot read anything else"
fi
exit "$fail"
