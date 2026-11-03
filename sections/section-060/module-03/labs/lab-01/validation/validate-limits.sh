#!/usr/bin/env bash
# Check: container shuttle has the limits cpu 100m and memory 64Mi (strategic merge patch).
set -uo pipefail
pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; status=1; }
status=0

memory="$(kubectl -n outpost get deployment outpost-shuttle -o jsonpath='{.spec.template.spec.containers[?(@.name=="shuttle")].resources.limits.memory}' 2>/dev/null || true)"
cpu="$(kubectl -n outpost get deployment outpost-shuttle -o jsonpath='{.spec.template.spec.containers[?(@.name=="shuttle")].resources.limits.cpu}' 2>/dev/null || true)"
containers="$(kubectl -n outpost get deployment outpost-shuttle -o jsonpath='{.spec.template.spec.containers[*].name}' 2>/dev/null || true)"
[ "$containers" = "shuttle" ] && pass "the Deployment has one container, shuttle" || fail "the container names are '$containers', expected only shuttle (a patch must name the existing container)"
[ "$memory" = "64Mi" ] && pass "memory limit is 64Mi" || fail "memory limit is '$memory', expected 64Mi"
[ "$cpu" = "100m" ] && pass "cpu limit is 100m" || fail "cpu limit is '$cpu', expected 100m"
exit "$status"
