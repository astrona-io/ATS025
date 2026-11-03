#!/usr/bin/env bash
# Check: the Service listens on 8080 and still targets the named container port (JSON 6902 patch).
set -uo pipefail
pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; status=1; }
status=0

port="$(kubectl -n outpost get service outpost-shuttle -o jsonpath='{.spec.ports[0].port}' 2>/dev/null || true)"
target="$(kubectl -n outpost get service outpost-shuttle -o jsonpath='{.spec.ports[0].targetPort}' 2>/dev/null || true)"
count="$(kubectl -n outpost get service outpost-shuttle -o jsonpath='{.spec.ports[*].port}' 2>/dev/null | wc -w | tr -d ' ')"
[ "$port" = "8080" ] && pass "the Service port is 8080" || fail "the Service port is '$port', expected 8080"
[ "$target" = "http" ] && pass "targetPort is still http" || fail "targetPort is '$target', expected http"
[ "$count" = "1" ] && pass "the Service has one port" || fail "the Service has $count ports, expected 1"
exit "$status"
