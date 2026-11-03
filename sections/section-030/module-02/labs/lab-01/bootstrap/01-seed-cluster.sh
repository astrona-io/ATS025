#!/usr/bin/env bash
# Starting state for the kubeadm configuration lab. Environment only: the
# namespaces, a probe Deployment and a draft kubeadm-plan ConfigMap with
# mistakes. The learner fixes the draft and records the cluster values.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=180s
echo "[lab] Ready."
