#!/usr/bin/env bash
# Check: shuttle reads pods in starfleet through Role pod-reader and nothing
# more, and the leftover cluster-admin binding is gone.
set -uo pipefail

SA="system:serviceaccount:starfleet:shuttle"
fail=0
filter='any(.subjects[]?; .kind=="ServiceAccount" and .name=="shuttle" and .namespace=="starfleet")'

if [ "$(kubectl -n starfleet get rolebinding shuttle-pod-reader -o json 2>/dev/null | jq -r '.roleRef.kind + "/" + .roleRef.name')" != "Role/pod-reader" ]; then
  echo "FAIL: RoleBinding shuttle-pod-reader in starfleet must reference Role/pod-reader"
  fail=1
fi

cluster="$(kubectl get clusterrolebindings -o json 2>/dev/null | jq -r ".items[] | select($filter) | .metadata.name")"
if [ -n "$cluster" ]; then
  echo "FAIL: ClusterRoleBindings still name shuttle: $cluster"
  fail=1
fi

for verb in get list watch; do
  answer="$(kubectl auth can-i "$verb" pods -n starfleet --as="$SA" 2>/dev/null || true)"
  if [ "$answer" != "yes" ]; then
    echo "FAIL: shuttle cannot $verb pods in starfleet"
    fail=1
  fi
done

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
denied get secrets -n starfleet
denied list pods -n outpost
denied list nodes
denied create clusterrolebindings.rbac.authorization.k8s.io

if [ "$fail" -eq 0 ]; then
  echo "PASS: shuttle reads pods in starfleet only"
fi
exit "$fail"
