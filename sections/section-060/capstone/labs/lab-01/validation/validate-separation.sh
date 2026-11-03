#!/usr/bin/env bash
# Check: the outpost copy has no Helm release, and the bridge Deployment is unchanged.
set -uo pipefail
pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; status=1; }
status=0

count="$(kubectl get secrets -A -l owner=helm,name=relay-outpost -o name 2>/dev/null | wc -l | tr -d ' ')"
[ "$count" = "0" ] && pass "no Helm release named relay-outpost exists" || fail "a Helm release named relay-outpost exists; the outpost copy must come from kubectl apply -k"
count="$(kubectl -n outpost get secrets -l owner=helm -o name 2>/dev/null | wc -l | tr -d ' ')"
[ "$count" = "0" ] && pass "no Helm release lives in outpost" || fail "Helm release records exist in outpost"
expected="$(kubectl -n kube-system get configmap lab-baseline -o jsonpath='{.data.bridge-deployment-uid}' 2>/dev/null || true)"
actual="$(kubectl -n starfleet get deployment bridge -o jsonpath='{.metadata.uid}' 2>/dev/null || true)"
[ -n "$expected" ] && [ "$expected" = "$actual" ] && pass "bridge was not recreated" || fail "bridge was deleted or recreated"
owner="$(kubectl -n starfleet get deployment bridge -o jsonpath='{.metadata.annotations.meta\.helm\.sh/release-name}' 2>/dev/null || true)"
[ -z "$owner" ] && pass "bridge is not owned by Helm" || fail "bridge is owned by Helm release '$owner'"
exit "$status"
