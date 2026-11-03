#!/usr/bin/env bash
# Check: no other binding gives shuttle access. The leftover binding in outpost
# is gone, shuttle cannot read or write anything in outpost, and no
# ClusterRoleBinding names shuttle.
set -uo pipefail

SA="system:serviceaccount:starfleet:shuttle"
fail=0
filter='any(.subjects[]?; .kind=="ServiceAccount" and .name=="shuttle" and .namespace=="starfleet")'

others="$(kubectl get rolebindings -A -o json 2>/dev/null | jq -r ".items[] | select($filter) | select(.metadata.namespace + \"/\" + .metadata.name != \"starfleet/shuttle-pod-reader\") | .metadata.namespace + \"/\" + .metadata.name")"
if [ -n "$others" ]; then
  echo "FAIL: other RoleBindings still name shuttle: $others"
  fail=1
fi

cluster="$(kubectl get clusterrolebindings -o json 2>/dev/null | jq -r ".items[] | select($filter) | .metadata.name")"
if [ -n "$cluster" ]; then
  echo "FAIL: ClusterRoleBindings name shuttle: $cluster"
  fail=1
fi

denied() {
  local answer
  answer="$(kubectl auth can-i "$@" --as="$SA" 2>/dev/null || true)"
  if [ "$answer" != "no" ]; then
    echo "FAIL: shuttle should not be allowed: $*"
    fail=1
  fi
}

denied list pods -n outpost
denied create pods -n outpost
denied create deployments.apps -n outpost
denied get secrets -n outpost
denied list pods --all-namespaces
denied list nodes

if [ "$fail" -eq 0 ]; then
  echo "PASS: shuttle has no grant outside the pod-reader binding"
fi
exit "$fail"
