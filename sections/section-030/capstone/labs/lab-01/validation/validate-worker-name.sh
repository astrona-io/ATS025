#!/usr/bin/env bash
# Check: workerNodeName is the name of the node without the control-plane role label.
set -uo pipefail

expected="$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
actual="$(kubectl -n starfleet get configmap init-review -o go-template='{{index .data "workerNodeName"}}' 2>/dev/null || true)"
if [ -z "$expected" ]; then
  echo "FAIL: no worker node found"
  exit 1
fi
if [ "$actual" != "$expected" ]; then
  echo "FAIL: workerNodeName is '${actual}', the worker node is '${expected}'"
  exit 1
fi
echo "PASS: workerNodeName is ${actual}"
