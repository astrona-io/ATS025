#!/usr/bin/env bash
# Check: the Deployment runs as the ServiceAccount beacon-operator and is available.
set -uo pipefail

status=0
if ! kubectl -n beacon-system get serviceaccount beacon-operator >/dev/null 2>&1; then
  echo "FAIL: ServiceAccount beacon-operator does not exist in beacon-system"
  status=1
else
  echo "PASS: ServiceAccount beacon-operator exists"
fi
sa="$(kubectl -n beacon-system get deployment beacon-operator -o jsonpath='{.spec.template.spec.serviceAccountName}' 2>/dev/null || true)"
if [ "$sa" != "beacon-operator" ]; then
  echo "FAIL: the Deployment uses ServiceAccount '${sa:-default}', expected beacon-operator"
  status=1
else
  echo "PASS: the Deployment uses beacon-operator"
fi
avail="$(kubectl -n beacon-system get deployment beacon-operator -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ "${avail:-0}" -ge 1 ] 2>/dev/null; then
  echo "PASS: the Deployment has an available replica"
else
  echo "FAIL: the Deployment has no available replica"
  status=1
fi
exit "$status"
