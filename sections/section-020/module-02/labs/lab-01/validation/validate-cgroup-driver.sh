#!/usr/bin/env bash
# Check: cgroupDriver equals the value stored in the kubelet-config ConfigMap.
# If the field is absent there, systemd or cgroupfs is accepted.
set -uo pipefail

kubelet_yaml="$(kubectl -n kube-system get configmap kubelet-config -o jsonpath='{.data.kubelet}' 2>/dev/null || true)"
if [ -z "$kubelet_yaml" ]; then
  echo "FAIL: ConfigMap kubelet-config is missing or empty in kube-system"
  exit 1
fi
expected="$(printf '%s\n' "$kubelet_yaml" | sed -n 's/^cgroupDriver:[[:space:]]*//p' | tr -d '"' | head -n 1)"
actual="$(kubectl -n starfleet get configmap host-readiness -o go-template='{{index .data "cgroupDriver"}}' 2>/dev/null || true)"

if [ -n "$expected" ]; then
  if [ "$actual" != "$expected" ]; then
    echo "FAIL: cgroupDriver is '${actual}', the kubelet configuration says '${expected}'"
    exit 1
  fi
else
  if [ "$actual" != "systemd" ] && [ "$actual" != "cgroupfs" ]; then
    echo "FAIL: cgroupDriver is '${actual}', expected systemd or cgroupfs"
    exit 1
  fi
fi
echo "PASS: cgroupDriver is ${actual}"
