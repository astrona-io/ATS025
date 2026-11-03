#!/usr/bin/env bash
# Check: failSwapOn equals the stored kubelet configuration. An absent field
# means the kubelet default, which is true.
set -uo pipefail

kubelet_yaml="$(kubectl -n kube-system get configmap kubelet-config -o jsonpath='{.data.kubelet}' 2>/dev/null || true)"
if [ -z "$kubelet_yaml" ]; then
  echo "FAIL: ConfigMap kubelet-config is missing or empty in kube-system"
  exit 1
fi
expected="$(printf '%s\n' "$kubelet_yaml" | sed -n 's/^failSwapOn:[[:space:]]*//p' | tr -d '"' | head -n 1)"
expected="${expected:-true}"
actual="$(kubectl -n starfleet get configmap host-readiness -o go-template='{{index .data "failSwapOn"}}' 2>/dev/null || true)"

if [ "$actual" != "$expected" ]; then
  echo "FAIL: failSwapOn is '${actual}', the kubelet configuration says '${expected}'"
  exit 1
fi
echo "PASS: failSwapOn is ${actual}"
