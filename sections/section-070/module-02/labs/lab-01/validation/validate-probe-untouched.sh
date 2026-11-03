#!/usr/bin/env bash
# Check: the probe Deployment still has two ready replicas and no egress policy exists.
set -uo pipefail

status=0
ready="$(kubectl -n starfleet get deployment probe -o jsonpath='{.status.readyReplicas}' 2>/dev/null)"
if [ "$ready" = "2" ]; then
  echo "PASS: probe has two ready replicas"
else
  echo "FAIL: probe must keep two ready replicas (found: ${ready:-none})"
  status=1
fi
if kubectl -n starfleet get networkpolicy -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.policyTypes[*]}{"\n"}{end}' 2>/dev/null | grep -q 'Egress'; then
  echo "FAIL: a NetworkPolicy uses policyTypes Egress; this task needs ingress only"
  status=1
else
  echo "PASS: no egress policy exists"
fi
count="$(kubectl -n starfleet get networkpolicy -o name 2>/dev/null | grep -c .)"
if [ "$count" = "2" ]; then
  echo "PASS: exactly two NetworkPolicy objects exist"
else
  echo "FAIL: expected exactly two NetworkPolicy objects in starfleet, found $count"
  status=1
fi
exit "$status"
