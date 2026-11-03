#!/usr/bin/env bash
# Check: cgroupDriver and failSwapOn equal the stored kubelet configuration.
# Absent cgroupDriver: systemd or cgroupfs accepted. Absent failSwapOn: true.
set -uo pipefail

kubelet_yaml="$(kubectl -n kube-system get configmap kubelet-config -o jsonpath='{.data.kubelet}' 2>/dev/null || true)"
if [ -z "$kubelet_yaml" ]; then
  echo "FAIL: ConfigMap kubelet-config is missing or empty in kube-system"
  exit 1
fi
status=0

expected="$(printf '%s\n' "$kubelet_yaml" | sed -n 's/^cgroupDriver:[[:space:]]*//p' | tr -d '"' | head -n 1)"
actual="$(kubectl -n starfleet get configmap readiness-review -o go-template='{{index .data "cgroupDriver"}}' 2>/dev/null || true)"
if [ -n "$expected" ] && [ "$actual" != "$expected" ]; then
  echo "FAIL: cgroupDriver is '${actual}', the kubelet configuration says '${expected}'"
  status=1
elif [ -z "$expected" ] && [ "$actual" != "systemd" ] && [ "$actual" != "cgroupfs" ]; then
  echo "FAIL: cgroupDriver is '${actual}', expected systemd or cgroupfs"
  status=1
else
  echo "PASS: cgroupDriver is ${actual}"
fi

expected="$(printf '%s\n' "$kubelet_yaml" | sed -n 's/^failSwapOn:[[:space:]]*//p' | tr -d '"' | head -n 1)"
expected="${expected:-true}"
actual="$(kubectl -n starfleet get configmap readiness-review -o go-template='{{index .data "failSwapOn"}}' 2>/dev/null || true)"
if [ "$actual" != "$expected" ]; then
  echo "FAIL: failSwapOn is '${actual}', the kubelet configuration says '${expected}'"
  status=1
else
  echo "PASS: failSwapOn is ${actual}"
fi
exit "$status"
