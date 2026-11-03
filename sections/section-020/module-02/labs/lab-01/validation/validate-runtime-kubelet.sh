#!/usr/bin/env bash
# Check: containerRuntimeVersion and kubeletVersion equal the node status.
set -uo pipefail

status=0
expected="$(kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.containerRuntimeVersion}' 2>/dev/null || true)"
actual="$(kubectl -n starfleet get configmap host-readiness -o go-template='{{index .data "containerRuntimeVersion"}}' 2>/dev/null || true)"
if [ -z "$expected" ]; then
  echo "FAIL: node status has no containerRuntimeVersion"
  status=1
elif [ "$actual" != "$expected" ]; then
  echo "FAIL: containerRuntimeVersion is '${actual}', the node reports '${expected}'"
  status=1
else
  echo "PASS: containerRuntimeVersion is ${actual}"
fi
expected="$(kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.kubeletVersion}' 2>/dev/null || true)"
actual="$(kubectl -n starfleet get configmap host-readiness -o go-template='{{index .data "kubeletVersion"}}' 2>/dev/null || true)"
if [ -z "$expected" ]; then
  echo "FAIL: node status has no kubeletVersion"
  status=1
elif [ "$actual" != "$expected" ]; then
  echo "FAIL: kubeletVersion is '${actual}', the node reports '${expected}'"
  status=1
else
  echo "PASS: kubeletVersion is ${actual}"
fi
exit "$status"
