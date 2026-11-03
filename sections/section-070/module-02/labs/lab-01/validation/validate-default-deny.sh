#!/usr/bin/env bash
# Check: default-deny-ingress selects every pod in starfleet and denies all ingress.
set -uo pipefail

status=0
policy="default-deny-ingress"
if ! kubectl -n starfleet get networkpolicy "$policy" >/dev/null 2>&1; then
  echo "FAIL: NetworkPolicy $policy does not exist in starfleet"
  exit 1
fi
get() { kubectl -n starfleet get networkpolicy "$policy" -o "jsonpath=$1" 2>/dev/null; }

selector="$(get '{.spec.podSelector}')"
if [ "$selector" = "{}" ]; then
  echo "PASS: podSelector is empty, so every pod is selected"
else
  echo "FAIL: podSelector must be empty ({}), found: $selector"
  status=1
fi
if [ "$(get '{.spec.policyTypes[*]}')" = "Ingress" ]; then
  echo "PASS: policyTypes is Ingress only"
else
  echo "FAIL: policyTypes must be exactly Ingress"
  status=1
fi
if [ -z "$(get '{.spec.ingress}')" ]; then
  echo "PASS: no ingress rules, so all ingress is denied"
else
  echo "FAIL: the policy must have no ingress rules"
  status=1
fi
exit "$status"
