#!/usr/bin/env bash
# Check: scout is granted through ClusterRoleBinding(s) to a custom ClusterRole
# only, with no built-in broad role, no wildcard rule and no RoleBinding.
set -uo pipefail

fail=0
subject_filter='any(.subjects[]?; .kind=="ServiceAccount" and .name=="scout" and .namespace=="starfleet")'

bound="$(kubectl get clusterrolebindings -o json 2>/dev/null | jq -r ".items[] | select($subject_filter) | .roleRef.kind + \"/\" + .roleRef.name")"
if [ -z "$bound" ]; then
  echo "FAIL: no ClusterRoleBinding names the ServiceAccount scout in starfleet"
  fail=1
fi

while IFS= read -r ref; do
  [ -z "$ref" ] && continue
  name="${ref#*/}"
  case "$ref" in
    ClusterRole/cluster-admin|ClusterRole/admin|ClusterRole/edit|ClusterRole/view|ClusterRole/system:*)
      echo "FAIL: scout is bound to the broad or built-in role $name"
      fail=1
      continue
      ;;
  esac
  if [ "$(kubectl get clusterrole "$name" -o json 2>/dev/null | jq '[.rules[]? | select((.verbs // []) + (.resources // []) + (.apiGroups // []) + (.nonResourceURLs // []) | index("*"))] | length')" != "0" ]; then
    echo "FAIL: ClusterRole $name contains a wildcard"
    fail=1
  fi
done <<< "$bound"

rolebindings="$(kubectl get rolebindings -A -o json 2>/dev/null | jq -r ".items[] | select($subject_filter) | .metadata.namespace + \"/\" + .metadata.name")"
if [ -n "$rolebindings" ]; then
  echo "FAIL: scout also has RoleBindings: $rolebindings"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: scout is granted by a custom ClusterRole only"
fi
exit "$fail"
