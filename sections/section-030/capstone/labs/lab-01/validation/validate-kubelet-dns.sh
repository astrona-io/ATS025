#!/usr/bin/env bash
# Check: clusterDNS equals the first address of clusterDNS in the stored kubelet configuration.
set -uo pipefail

kubelet_yaml="$(kubectl -n kube-system get configmap kubelet-config -o jsonpath='{.data.kubelet}' 2>/dev/null || true)"
expected="$(printf '%s\n' "$kubelet_yaml" | awk '/^clusterDNS:/ { found = 1; next } found && /^[[:space:]]*-/ { sub(/^[[:space:]]*-[[:space:]]*/, ""); gsub(/["\047[:space:]]/, ""); print; exit } found && /^[^[:space:]-]/ { exit }')"
actual="$(kubectl -n starfleet get configmap init-review -o go-template='{{index .data "clusterDNS"}}' 2>/dev/null || true)"
if [ -z "$expected" ]; then
  echo "FAIL: clusterDNS not found in the kubelet-config ConfigMap"
  exit 1
fi
if [ "$actual" != "$expected" ]; then
  echo "FAIL: clusterDNS is '${actual}', the kubelet configuration says '${expected}'"
  exit 1
fi
echo "PASS: clusterDNS is ${actual}"
