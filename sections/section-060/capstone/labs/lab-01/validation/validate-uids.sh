#!/usr/bin/env bash
# Check: the relay Deployment and Service were adopted, not deleted and recreated.
set -uo pipefail
pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; status=1; }
status=0

baseline() { kubectl -n kube-system get configmap lab-baseline -o jsonpath="{.data['$1']}" 2>/dev/null || true; }

for pair in "deployment:relay-deployment-uid" "service:relay-service-uid"; do
  kind="${pair%%:*}"
  key="${pair##*:}"
  expected="$(baseline "$key")"
  actual="$(kubectl -n starfleet get "$kind" relay -o jsonpath='{.metadata.uid}' 2>/dev/null || true)"
  if [ -z "$expected" ]; then
    fail "the lab baseline is missing ($key); restart the lab"
  elif [ "$expected" = "$actual" ]; then
    pass "$kind relay kept its original UID"
  else
    fail "$kind relay was recreated or deleted; adopt it instead"
  fi
done
exit "$status"
