#!/usr/bin/env bash
# Check: scout is granted through a ClusterRoleBinding to a custom ClusterRole
# that reads nodes, with no built-in role, no wildcard and nothing else.
set -uo pipefail

SA="system:serviceaccount:starfleet:scout"
fail=0
filter='any(.subjects[]?; .kind=="ServiceAccount" and .name=="scout" and .namespace=="starfleet")'

bound="$(kubectl get clusterrolebindings -o json 2>/dev/null | jq -r ".items[] | select($filter) | .roleRef.kind + \"/\" + .roleRef.name")"
if [ -z "$bound" ]; then
  echo "FAIL: no ClusterRoleBinding names the ServiceAccount scout in starfleet"
  fail=1
fi

while IFS= read -r ref; do
  [ -z "$ref" ] && continue
  name="${ref#*/}"
  case "$ref" in
    ClusterRole/cluster-admin|ClusterRole/admin|ClusterRole/edit|ClusterRole/view|ClusterRole/system:*)
      echo "FAIL: scout is bound to the built-in role $name"
      fail=1
      continue
      ;;
  esac
  if [ "$(kubectl get clusterrole "$name" -o json 2>/dev/null | jq '[.rules[]? | select((.verbs // []) + (.resources // []) + (.apiGroups // []) | index("*"))] | length')" != "0" ]; then
    echo "FAIL: ClusterRole $name contains a wildcard"
    fail=1
  fi
done <<< "$bound"

for verb in get list watch; do
  answer="$(kubectl auth can-i "$verb" nodes --as="$SA" 2>/dev/null || true)"
  if [ "$answer" != "yes" ]; then
    echo "FAIL: scout cannot $verb nodes"
    fail=1
  fi
done

if ! kubectl get nodes --as="$SA" >/dev/null 2>&1; then
  echo "FAIL: a real request to list nodes as scout was refused"
  fail=1
fi

denied() {
  local answer
  answer="$(kubectl auth can-i "$@" --as="$SA" 2>/dev/null || true)"
  if [ "$answer" != "no" ]; then
    echo "FAIL: scout should not be allowed: $*"
    fail=1
  fi
}

denied update nodes
denied delete nodes
denied list persistentvolumes
denied list pods --all-namespaces
denied list pods -n starfleet
denied get secrets -n starfleet
denied list namespaces

if [ "$fail" -eq 0 ]; then
  echo "PASS: scout reads nodes through a custom ClusterRole and nothing more"
fi
exit "$fail"
