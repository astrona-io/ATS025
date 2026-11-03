#!/usr/bin/env bash
# Check: every ClusterRole bound to the ServiceAccount has no wildcard.
set -uo pipefail

roles="$(kubectl get clusterrolebinding -o jsonpath='{range .items[*]}{.roleRef.kind}{"/"}{.roleRef.name}{" "}{range .subjects[*]}{.kind}{"/"}{.namespace}{"/"}{.name}{" "}{end}{"\n"}{end}' 2>/dev/null | awk '/ServiceAccount\/beacon-system\/beacon-operator/ && $1 ~ /^ClusterRole\// {sub("ClusterRole/","",$1); print $1}')"
if [ -z "$roles" ]; then
  echo "FAIL: no ClusterRoleBinding binds ServiceAccount beacon-operator to a ClusterRole"
  exit 1
fi
status=0
for r in $roles; do
  rules="$(kubectl get clusterrole "$r" -o jsonpath='{range .rules[*]}{.apiGroups}{" "}{.resources}{" "}{.verbs}{"\n"}{end}' 2>/dev/null)"
  if echo "$rules" | grep -q '\*'; then
    echo "FAIL: ClusterRole ${r} contains a wildcard"
    status=1
  else
    echo "PASS: ClusterRole ${r} has no wildcard"
  fi
done
exit "$status"
