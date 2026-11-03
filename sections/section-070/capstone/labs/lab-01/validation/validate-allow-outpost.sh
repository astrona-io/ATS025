#!/usr/bin/env bash
# Check: probe-from-outpost allows only the drifter pods in outpost on TCP 8080.
set -uo pipefail

status=0
policy="probe-from-outpost"
if ! kubectl -n starfleet get networkpolicy "$policy" >/dev/null 2>&1; then
  echo "FAIL: NetworkPolicy $policy does not exist in starfleet"
  exit 1
fi
get() { kubectl -n starfleet get networkpolicy "$policy" -o "jsonpath=$1" 2>/dev/null; }

[ "$(get '{.spec.podSelector.matchLabels.app}')" = "probe" ] && echo "PASS: the policy selects app=probe" || { echo "FAIL: podSelector must match app=probe"; status=1; }
[ "$(get '{.spec.policyTypes[*]}')" = "Ingress" ] && echo "PASS: policyTypes is Ingress only" || { echo "FAIL: policyTypes must be exactly Ingress"; status=1; }
if [ "$(get '{range .spec.ingress[*].from[*]}s{end}')" = "s" ] \
   && [ "$(get '{.spec.ingress[0].from[0].namespaceSelector.matchLabels.kubernetes\.io/metadata\.name}')" = "outpost" ] \
   && [ "$(get '{.spec.ingress[0].from[0].podSelector.matchLabels.app}')" = "drifter" ] \
   && [ -z "$(get '{.spec.ingress[0].from[0].ipBlock}')" ]; then
  echo "PASS: one from entry combines namespace outpost and pods app=drifter"
else
  echo "FAIL: use exactly one from entry with both a namespaceSelector (kubernetes.io/metadata.name=outpost) and a podSelector (app=drifter)"
  status=1
fi
if [ "$(get '{range .spec.ingress[0].ports[*]}p{end}')" = "p" ] \
   && [ "$(get '{.spec.ingress[0].ports[0].port}')" = "8080" ] \
   && [ "$(get '{.spec.ingress[0].ports[0].protocol}')" = "TCP" ]; then
  echo "PASS: the only port is TCP 8080"
else
  echo "FAIL: allow exactly one port, TCP 8080"
  status=1
fi
exit "$status"
