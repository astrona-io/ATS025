#!/usr/bin/env bash
# Check: the group reviewers holds the built-in view ClusterRole through a
# RoleBinding in starfleet, and through no binding anywhere else.
set -uo pipefail

fail=0
subject='any(.subjects[]?; (.kind=="Group" and .name=="reviewers") or (.kind=="User" and .name=="jane"))'

match="$(kubectl get rolebindings -n starfleet -o json 2>/dev/null | jq -r ".items[] | select(any(.subjects[]?; .kind==\"Group\" and .name==\"reviewers\")) | .roleRef.kind + \"/\" + .roleRef.name")"
if ! printf '%s\n' "$match" | grep -qx 'ClusterRole/view'; then
  echo "FAIL: no RoleBinding in starfleet binds the group reviewers to ClusterRole/view"
  fail=1
fi

other="$(printf '%s\n' "$match" | grep -v '^ClusterRole/view$' | grep -v '^$' || true)"
if [ -n "$other" ]; then
  echo "FAIL: the group reviewers is also bound to: $other"
  fail=1
fi

wide="$(kubectl get clusterrolebindings -o json 2>/dev/null | jq -r ".items[] | select($subject) | .metadata.name")"
if [ -n "$wide" ]; then
  echo "FAIL: ClusterRoleBinding names reviewers or jane: $wide"
  fail=1
fi

outside="$(kubectl get rolebindings -A -o json 2>/dev/null | jq -r ".items[] | select(.metadata.namespace != \"starfleet\") | select($subject) | .metadata.namespace + \"/\" + .metadata.name")"
if [ -n "$outside" ]; then
  echo "FAIL: a RoleBinding outside starfleet names reviewers or jane: $outside"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: reviewers holds view through a RoleBinding in starfleet only"
fi
exit "$fail"
