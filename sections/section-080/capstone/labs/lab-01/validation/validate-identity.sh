#!/usr/bin/env bash
# Check: the operator Deployment uses ServiceAccount mission-operator and is available.
set -uo pipefail

status=0
if kubectl -n mission-system get serviceaccount mission-operator >/dev/null 2>&1; then
  echo "PASS: ServiceAccount mission-operator exists"
else
  echo "FAIL: ServiceAccount mission-operator does not exist in mission-system"
  status=1
fi
sa="$(kubectl -n mission-system get deployment mission-operator -o jsonpath='{.spec.template.spec.serviceAccountName}' 2>/dev/null || true)"
if [ "$sa" = "mission-operator" ]; then
  echo "PASS: the Deployment uses mission-operator"
else
  echo "FAIL: the Deployment uses '${sa:-default}', expected mission-operator"
  status=1
fi
avail="$(kubectl -n mission-system get deployment mission-operator -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ "${avail:-0}" -ge 1 ] 2>/dev/null; then
  echo "PASS: the Deployment has an available replica"
else
  echo "FAIL: the Deployment has no available replica"
  status=1
fi
exit "$status"
