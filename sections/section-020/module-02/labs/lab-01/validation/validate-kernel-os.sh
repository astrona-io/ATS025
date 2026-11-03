#!/usr/bin/env bash
# Check: kernelVersion and osImage equal the node status.
set -uo pipefail

status=0
expected="$(kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.kernelVersion}' 2>/dev/null || true)"
actual="$(kubectl -n starfleet get configmap host-readiness -o go-template='{{index .data "kernelVersion"}}' 2>/dev/null || true)"
if [ -z "$expected" ]; then
  echo "FAIL: node status has no kernelVersion"
  status=1
elif [ "$actual" != "$expected" ]; then
  echo "FAIL: kernelVersion is '${actual}', the node reports '${expected}'"
  status=1
else
  echo "PASS: kernelVersion is ${actual}"
fi
expected="$(kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.osImage}' 2>/dev/null || true)"
actual="$(kubectl -n starfleet get configmap host-readiness -o go-template='{{index .data "osImage"}}' 2>/dev/null || true)"
if [ -z "$expected" ]; then
  echo "FAIL: node status has no osImage"
  status=1
elif [ "$actual" != "$expected" ]; then
  echo "FAIL: osImage is '${actual}', the node reports '${expected}'"
  status=1
else
  echo "PASS: osImage is ${actual}"
fi
exit "$status"
