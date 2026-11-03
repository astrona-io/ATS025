#!/usr/bin/env bash
# Check: the Deployment and the Service carry the Helm ownership metadata for release scout.
set -uo pipefail
pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; status=1; }
status=0

for kind in deployment service; do
  name="$(kubectl -n starfleet get "$kind" scout -o jsonpath='{.metadata.name}' 2>/dev/null || true)"
  if [ -z "$name" ]; then
    fail "$kind scout does not exist in starfleet"
    continue
  fi
  release="$(kubectl -n starfleet get "$kind" scout -o jsonpath='{.metadata.annotations.meta\.helm\.sh/release-name}' 2>/dev/null || true)"
  namespace="$(kubectl -n starfleet get "$kind" scout -o jsonpath='{.metadata.annotations.meta\.helm\.sh/release-namespace}' 2>/dev/null || true)"
  manager="$(kubectl -n starfleet get "$kind" scout -o jsonpath='{.metadata.labels.app\.kubernetes\.io/managed-by}' 2>/dev/null || true)"
  if [ "$release" = "scout" ] && [ "$namespace" = "starfleet" ] && [ "$manager" = "Helm" ]; then
    pass "$kind scout is owned by Helm release scout"
  else
    fail "$kind scout has release-name '$release', release-namespace '$namespace', managed-by '$manager'"
  fi
done
exit "$status"
