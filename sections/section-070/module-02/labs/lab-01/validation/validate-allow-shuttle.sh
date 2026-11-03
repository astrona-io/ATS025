#!/usr/bin/env bash
# Check: probe-ingress allows only the shuttle pods to reach probe on TCP 8080.
set -uo pipefail

status=0
policy="probe-ingress"
if ! kubectl -n starfleet get networkpolicy "$policy" >/dev/null 2>&1; then
  echo "FAIL: NetworkPolicy $policy does not exist in starfleet"
  exit 1
fi
get() { kubectl -n starfleet get networkpolicy "$policy" -o "jsonpath=$1" 2>/dev/null; }

if [ "$(get '{.spec.podSelector.matchLabels.app}')" = "probe" ]; then
  echo "PASS: the policy selects app=probe"
else
  echo "FAIL: podSelector must match the label app=probe"
  status=1
fi
if [ "$(get '{.spec.policyTypes[*]}')" = "Ingress" ]; then
  echo "PASS: policyTypes is Ingress only"
else
  echo "FAIL: policyTypes must be exactly Ingress"
  status=1
fi
rules="$(get '{range .spec.ingress[*]}r{end}')"
sources="$(get '{range .spec.ingress[*].from[*]}s{end}')"
if [ "$rules" = "r" ] && [ "$sources" = "s" ]; then
  echo "PASS: one ingress rule with one source"
else
  echo "FAIL: use exactly one ingress rule with exactly one from entry"
  status=1
fi
if [ "$(get '{.spec.ingress[0].from[0].podSelector.matchLabels.app}')" = "shuttle" ] \
   && [ -z "$(get '{.spec.ingress[0].from[0].namespaceSelector}')" ] \
   && [ -z "$(get '{.spec.ingress[0].from[0].ipBlock}')" ]; then
  echo "PASS: the only source is the pods labelled app=shuttle in starfleet"
else
  echo "FAIL: the source must be a podSelector for app=shuttle, with no namespaceSelector or ipBlock"
  status=1
fi
if [ "$(get '{.spec.ingress[0].ports[0].port}')" = "8080" ] \
   && [ "$(get '{.spec.ingress[0].ports[0].protocol}')" = "TCP" ] \
   && [ "$(get '{range .spec.ingress[0].ports[*]}p{end}')" = "p" ]; then
  echo "PASS: the only port is TCP 8080"
else
  echo "FAIL: allow exactly one port: TCP 8080"
  status=1
fi
exit "$status"
