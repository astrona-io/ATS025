#!/usr/bin/env bash
# Check: label environment=outpost on the Deployment, its selector and pods, and on the Service selector; the Service has endpoints.
set -uo pipefail
pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; status=1; }
status=0

get_value() { kubectl -n outpost get "$1" outpost-shuttle -o jsonpath="$2" 2>/dev/null || true; }

if ! kubectl -n outpost get deployment outpost-shuttle >/dev/null 2>&1; then
  fail "Deployment outpost-shuttle does not exist in outpost"
  exit 1
fi
[ "$(get_value deployment '{.metadata.labels.environment}')" = "outpost" ] && pass "Deployment label environment=outpost" || fail "the Deployment has no label environment=outpost"
[ "$(get_value deployment '{.spec.selector.matchLabels.environment}')" = "outpost" ] && pass "Deployment selector includes environment=outpost" || fail "the Deployment selector does not include environment=outpost"
[ "$(get_value deployment '{.spec.template.metadata.labels.environment}')" = "outpost" ] && pass "pod template label environment=outpost" || fail "the pod template has no label environment=outpost"
[ "$(get_value service '{.spec.selector.environment}')" = "outpost" ] && pass "Service selector includes environment=outpost" || fail "the Service selector does not include environment=outpost"
addresses="$(kubectl -n outpost get endpointslices -l kubernetes.io/service-name=outpost-shuttle -o jsonpath='{.items[*].endpoints[*].addresses[*]}' 2>/dev/null || true)"
[ -n "$addresses" ] && pass "the Service has endpoints" || fail "the Service has no endpoints; check that its selector matches the pod labels"
exit "$status"
