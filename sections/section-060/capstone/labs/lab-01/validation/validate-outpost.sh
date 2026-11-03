#!/usr/bin/env bash
# Check: the Kustomize copy relay-outpost runs 4 replicas in outpost and is not owned by Helm.
set -uo pipefail
pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; status=1; }
status=0

replicas="$(kubectl -n outpost get deployment relay-outpost -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
if [ -z "$replicas" ]; then
  fail "Deployment relay-outpost does not exist in outpost"
  exit 1
fi
[ "$replicas" = "4" ] && pass "spec.replicas is 4" || fail "spec.replicas is $replicas, expected 4"
available="$(kubectl -n outpost get deployment relay-outpost -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
[ "${available:-0}" = "4" ] && pass "4 replicas are available" || fail "${available:-0} replicas are available, expected 4"
owner="$(kubectl -n outpost get deployment relay-outpost -o jsonpath='{.metadata.annotations.meta\.helm\.sh/release-name}' 2>/dev/null || true)"
[ -z "$owner" ] && pass "relay-outpost is not owned by Helm" || fail "relay-outpost is owned by Helm release '$owner'; apply the overlay with kubectl instead"
applied="$(kubectl -n outpost get deployment relay-outpost -o jsonpath='{.metadata.annotations.kubectl\.kubernetes\.io/last-applied-configuration}' 2>/dev/null || true)"
[ -n "$applied" ] && pass "relay-outpost was applied with kubectl apply" || fail "relay-outpost has no last-applied-configuration; use kubectl apply -k"
exit "$status"
