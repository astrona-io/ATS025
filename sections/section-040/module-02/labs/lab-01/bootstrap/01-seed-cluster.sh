#!/usr/bin/env bash
# Starting state: a stale upgrade-review record, and a checksum of the stored
# kubeadm configuration so the grader can tell if it was edited.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n kube-system create configmap lab-baseline \
  --from-literal=kubeadmConfigChecksum="$(kubectl -n kube-system get configmap kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' | cksum | awk '{print $1}')" \
  --dry-run=client -o yaml | kubectl apply -f -
echo "[lab] Ready."
