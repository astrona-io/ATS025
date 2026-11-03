#!/usr/bin/env bash
# Check: The kubeadm-config ConfigMap still has its original content (checksum taken at the start).
set -uo pipefail

expected="$(kubectl -n kube-system get configmap lab-baseline -o jsonpath='{.data.kubeadmConfigChecksum}' 2>/dev/null)"
actual="$(kubectl -n kube-system get configmap kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' 2>/dev/null | cksum | awk '{print $1}')"
if [ -z "$expected" ]; then
  echo "FAIL: the baseline checksum is missing"
  exit 1
fi
if [ "$expected" != "$actual" ]; then
  echo "FAIL: kubeadm-config was edited; fix the record, not the cluster"
  exit 1
fi
echo "PASS: kubeadm-config is unchanged"
