#!/usr/bin/env bash
# Check: the unrelated bridge Deployment is unchanged and not owned by Helm.
set -uo pipefail
pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; status=1; }
status=0

replicas="$(kubectl -n starfleet get deployment bridge -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
if [ -z "$replicas" ]; then
  fail "Deployment bridge was deleted"
  exit 1
fi
[ "$replicas" = "1" ] && pass "bridge still has 1 replica" || fail "bridge has $replicas replicas, expected 1"
image="$(kubectl -n starfleet get deployment bridge -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)"
[ "$image" = "docker.io/library/busybox:1.37.0" ] && pass "bridge image is unchanged" || fail "bridge image is '$image'"
owner="$(kubectl -n starfleet get deployment bridge -o jsonpath='{.metadata.annotations.meta\.helm\.sh/release-name}' 2>/dev/null || true)"
[ -z "$owner" ] && pass "bridge is not owned by a Helm release" || fail "bridge is owned by Helm release '$owner'"
exit "$status"
