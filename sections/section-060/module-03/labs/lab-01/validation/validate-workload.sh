#!/usr/bin/env bash
# Check: 3 available replicas and the image set by the images transformer.
set -uo pipefail
pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; status=1; }
status=0

replicas="$(kubectl -n outpost get deployment outpost-shuttle -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
if [ -z "$replicas" ]; then
  fail "Deployment outpost-shuttle does not exist in outpost"
  exit 1
fi
[ "$replicas" = "3" ] && pass "spec.replicas is 3" || fail "spec.replicas is $replicas, expected 3"
available="$(kubectl -n outpost get deployment outpost-shuttle -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
[ "${available:-0}" = "3" ] && pass "3 replicas are available" || fail "${available:-0} replicas are available, expected 3"
image="$(kubectl -n outpost get deployment outpost-shuttle -o jsonpath='{.spec.template.spec.containers[?(@.name=="shuttle")].image}' 2>/dev/null || true)"
[ "$image" = "docker.io/library/busybox:1.37.0" ] && pass "image is $image" || fail "image is '$image', expected docker.io/library/busybox:1.37.0"
exit "$status"
