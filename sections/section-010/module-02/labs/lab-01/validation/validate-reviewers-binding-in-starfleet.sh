#!/usr/bin/env bash
# Check: the group reviewers is bound by a RoleBinding in starfleet, and no
# other binding gives reviewers or jane anything.
set -uo pipefail

fail=0
count="$(kubectl get rolebindings -n starfleet -o json 2>/dev/null | jq '[.items[] | select(any(.subjects[]?; .kind=="Group" and .name=="reviewers"))] | length')"
if [ "${count:-0}" -lt 1 ]; then
  echo "FAIL: no RoleBinding in starfleet names the group reviewers"
  fail=1
fi

wide="$(kubectl get clusterrolebindings -o json 2>/dev/null | jq -r '.items[] | select(any(.subjects[]?; (.kind=="Group" and .name=="reviewers") or (.kind=="User" and .name=="jane"))) | .metadata.name')"
if [ -n "$wide" ]; then
  echo "FAIL: ClusterRoleBinding names reviewers or jane: $wide"
  fail=1
fi

outside="$(kubectl get rolebindings -A -o json 2>/dev/null | jq -r '.items[] | select(.metadata.namespace != "starfleet") | select(any(.subjects[]?; (.kind=="Group" and .name=="reviewers") or (.kind=="User" and .name=="jane"))) | .metadata.namespace + "/" + .metadata.name')"
if [ -n "$outside" ]; then
  echo "FAIL: a RoleBinding outside starfleet names reviewers or jane: $outside"
  fail=1
fi

broad="$(kubectl get rolebindings -n starfleet -o json 2>/dev/null | jq -r '.items[] | select(any(.subjects[]?; .kind=="Group" and .name=="reviewers")) | select(.roleRef.name=="cluster-admin" or .roleRef.name=="admin" or .roleRef.name=="edit") | .metadata.name')"
if [ -n "$broad" ]; then
  echo "FAIL: reviewers is bound to a broad role in $broad"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: reviewers is bound by a RoleBinding in starfleet only"
fi
exit "$fail"
