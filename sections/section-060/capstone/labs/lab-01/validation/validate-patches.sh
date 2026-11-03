#!/usr/bin/env bash
# Check: relay-outpost pods have tier=outpost, the memory limit is 64Mi and the Service has endpoints.
set -uo pipefail
pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; status=1; }
status=0

if ! kubectl -n outpost get deployment relay-outpost >/dev/null 2>&1; then
  fail "Deployment relay-outpost does not exist in outpost"
  exit 1
fi
tier="$(kubectl -n outpost get deployment relay-outpost -o jsonpath='{.spec.template.metadata.labels.tier}' 2>/dev/null || true)"
[ "$tier" = "outpost" ] && pass "pod template label tier=outpost" || fail "pod template label tier is '$tier', expected outpost"
memory="$(kubectl -n outpost get deployment relay-outpost -o jsonpath='{.spec.template.spec.containers[?(@.name=="relay")].resources.limits.memory}' 2>/dev/null || true)"
[ "$memory" = "64Mi" ] && pass "memory limit is 64Mi" || fail "memory limit is '$memory', expected 64Mi"
addresses="$(kubectl -n outpost get endpointslices -l kubernetes.io/service-name=relay-outpost -o jsonpath='{.items[*].endpoints[*].addresses[*]}' 2>/dev/null || true)"
[ -n "$addresses" ] && pass "Service relay-outpost has endpoints" || fail "Service relay-outpost has no endpoints"
exit "$status"
