#!/usr/bin/env bash
# Check: the adopted Deployment shows the release values and carries Helm ownership metadata.
set -uo pipefail
pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; status=1; }
status=0

replicas="$(kubectl -n starfleet get deployment relay -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
[ "$replicas" = "2" ] && pass "spec.replicas is 2" || fail "spec.replicas is '$replicas', expected 2"
available="$(kubectl -n starfleet get deployment relay -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
[ "${available:-0}" = "2" ] && pass "2 replicas are available" || fail "${available:-0} replicas are available, expected 2"
level="$(kubectl -n starfleet get deployment relay -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="LOG_LEVEL")].value}' 2>/dev/null || true)"
[ "$level" = "debug" ] && pass "LOG_LEVEL is debug" || fail "LOG_LEVEL is '$level', expected debug"
for kind in deployment service; do
  release="$(kubectl -n starfleet get "$kind" relay -o jsonpath='{.metadata.annotations.meta\.helm\.sh/release-name}' 2>/dev/null || true)"
  manager="$(kubectl -n starfleet get "$kind" relay -o jsonpath='{.metadata.labels.app\.kubernetes\.io/managed-by}' 2>/dev/null || true)"
  if [ "$release" = "relay" ] && [ "$manager" = "Helm" ]; then
    pass "$kind relay is owned by Helm release relay"
  else
    fail "$kind relay has release-name '$release' and managed-by '$manager'"
  fi
done
exit "$status"
