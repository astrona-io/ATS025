#!/usr/bin/env bash
# Check: in starfleet, shuttle cannot write pods, read Secrets, read pod logs
# or read other resource types.
set -uo pipefail

SA="system:serviceaccount:starfleet:shuttle"
fail=0

denied() {
  local answer
  answer="$(kubectl auth can-i "$@" --as="$SA" 2>/dev/null || true)"
  if [ "$answer" != "no" ]; then
    echo "FAIL: shuttle should not be allowed: $*"
    fail=1
  fi
}

denied create pods -n starfleet
denied delete pods -n starfleet
denied patch pods -n starfleet
denied get pods/log -n starfleet
denied create pods/exec -n starfleet
denied get secrets -n starfleet
denied list secrets -n starfleet
denied list configmaps -n starfleet
denied list deployments.apps -n starfleet
denied create rolebindings.rbac.authorization.k8s.io -n starfleet

if [ "$fail" -eq 0 ]; then
  echo "PASS: shuttle has no other permission in starfleet"
fi
exit "$fail"
