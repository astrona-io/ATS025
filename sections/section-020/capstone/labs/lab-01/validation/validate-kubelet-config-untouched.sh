#!/usr/bin/env bash
# Check: the kubelet-config ConfigMap still has the content it had at the start.
# Rejects the shortcut of editing the cluster to match a wrong record.
set -uo pipefail

baseline="$(kubectl -n kube-system get configmap lab-baseline -o jsonpath='{.data.kubeletConfigChecksum}' 2>/dev/null || true)"
if [ -z "$baseline" ]; then
  echo "FAIL: the lab baseline ConfigMap is missing; do not delete lab-baseline"
  exit 1
fi
current="$(kubectl -n kube-system get configmap kubelet-config -o jsonpath='{.data.kubelet}' 2>/dev/null | cksum | awk '{print $1}')"
if [ "$current" != "$baseline" ]; then
  echo "FAIL: kubelet-config was changed; fix the review, not the cluster"
  exit 1
fi
echo "PASS: kubelet-config is unchanged"
