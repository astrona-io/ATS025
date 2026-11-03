#!/usr/bin/env bash
# Check: default-deny-ingress denies all ingress in starfleet.
set -uo pipefail

status=0
policy="default-deny-ingress"
if ! kubectl -n starfleet get networkpolicy "$policy" >/dev/null 2>&1; then
  echo "FAIL: NetworkPolicy $policy does not exist in starfleet"
  exit 1
fi
get() { kubectl -n starfleet get networkpolicy "$policy" -o "jsonpath=$1" 2>/dev/null; }

[ "$(get '{.spec.podSelector}')" = "{}" ] && echo "PASS: every pod is selected" || { echo "FAIL: podSelector must be empty ({})"; status=1; }
[ "$(get '{.spec.policyTypes[*]}')" = "Ingress" ] && echo "PASS: policyTypes is Ingress only" || { echo "FAIL: policyTypes must be exactly Ingress"; status=1; }
[ -z "$(get '{.spec.ingress}')" ] && echo "PASS: no ingress rules" || { echo "FAIL: the policy must have no ingress rules"; status=1; }
exit "$status"
