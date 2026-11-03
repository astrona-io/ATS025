#!/usr/bin/env bash
# Starting state: a stale lifecycle-review record, a cordoned worker and a probe
# Deployment whose pods cannot be scheduled until the worker is schedulable.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl wait --for=condition=Ready node --all --timeout=180s
worker="$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].metadata.name}')"
kubectl cordon "$worker"
kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n kube-system create configmap lab-baseline \
  --from-literal=kubeadmConfigChecksum="$(kubectl -n kube-system get configmap kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' | cksum | awk '{print $1}')" \
  --dry-run=client -o yaml | kubectl apply -f -
echo "[lab] Ready."
