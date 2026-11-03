#!/usr/bin/env bash
# Starting state: a stale host-readiness record, and a checksum of the stored
# kubelet configuration so the grader can tell if it was edited.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"

checksum="$(kubectl -n kube-system get configmap kubelet-config -o jsonpath='{.data.kubelet}' | cksum | awk '{print $1}')"
kubectl -n kube-system create configmap lab-baseline --from-literal=kubeletConfigChecksum="$checksum" \
  --dry-run=client -o yaml | kubectl apply -f -
echo "[lab] Ready."
