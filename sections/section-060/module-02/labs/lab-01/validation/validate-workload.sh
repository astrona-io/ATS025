#!/usr/bin/env bash
# Check: the scout Deployment runs the values of revision 1 again (2 available replicas, LOG_LEVEL info).
set -uo pipefail
pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; status=1; }
status=0

replicas="$(kubectl -n starfleet get deployment scout -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
if [ -z "$replicas" ]; then
  fail "Deployment scout does not exist in starfleet"
  exit 1
fi
[ "$replicas" = "2" ] && pass "spec.replicas is 2" || fail "spec.replicas is $replicas, expected 2"
available="$(kubectl -n starfleet get deployment scout -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
[ "${available:-0}" = "2" ] && pass "2 replicas are available" || fail "${available:-0} replicas are available, expected 2"
level="$(kubectl -n starfleet get deployment scout -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="LOG_LEVEL")].value}' 2>/dev/null || true)"
[ "$level" = "info" ] && pass "LOG_LEVEL is info" || fail "LOG_LEVEL is '$level', expected info"
image="$(kubectl -n starfleet get deployment scout -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)"
[ "$image" = "docker.io/library/busybox:1.37.0" ] && pass "image is $image" || fail "image is '$image', expected docker.io/library/busybox:1.37.0"
exit "$status"
