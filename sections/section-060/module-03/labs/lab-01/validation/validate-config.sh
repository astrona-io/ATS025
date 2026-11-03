#!/usr/bin/env bash
# Check: the generated ConfigMap has a hash suffix and MODE=patrol, and the Deployment refers to that exact name.
set -uo pipefail
pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; status=1; }
status=0

ref="$(kubectl -n outpost get deployment outpost-shuttle -o jsonpath='{.spec.template.spec.containers[?(@.name=="shuttle")].envFrom[0].configMapRef.name}' 2>/dev/null || true)"
if [ -z "$ref" ]; then
  fail "the Deployment has no envFrom configMapRef"
  exit 1
fi
if echo "$ref" | grep -Eq '^outpost-shuttle-config-[a-z0-9]{10}$'; then
  pass "the Deployment refers to $ref (prefix and hash suffix present)"
else
  fail "the referenced ConfigMap name is '$ref', expected outpost-shuttle-config-<10 character hash>"
fi
mode="$(kubectl -n outpost get configmap "$ref" -o jsonpath='{.data.MODE}' 2>/dev/null || true)"
if [ -z "$mode" ] && ! kubectl -n outpost get configmap "$ref" >/dev/null 2>&1; then
  fail "the referenced ConfigMap $ref does not exist"
else
  [ "$mode" = "patrol" ] && pass "MODE is patrol" || fail "MODE is '$mode', expected patrol"
fi
exit "$status"
