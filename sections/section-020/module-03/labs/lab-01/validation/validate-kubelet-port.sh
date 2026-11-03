#!/usr/bin/env bash
# Check: kubelet equals the kubelet port in the node status.
set -uo pipefail

expected="$(kubectl get nodes -o jsonpath='{.items[0].status.daemonEndpoints.kubeletEndpoint.Port}' 2>/dev/null || true)"
actual="$(kubectl -n starfleet get configmap control-plane-ports -o go-template='{{index .data "kubelet"}}' 2>/dev/null || true)"

if [ -z "$expected" ]; then
  echo "FAIL: the node status has no kubelet endpoint port"
  exit 1
fi
if [ "$actual" != "$expected" ]; then
  echo "FAIL: kubelet is '${actual}', the node reports '${expected}'"
  exit 1
fi
echo "PASS: kubelet port is ${actual}"
