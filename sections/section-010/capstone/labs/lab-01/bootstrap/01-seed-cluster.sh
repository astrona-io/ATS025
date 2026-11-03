#!/usr/bin/env bash
# Starting state for the capstone. Environment only: it creates the
# namespaces, workloads, ServiceAccounts and the leftover binding. It creates
# no Role, ClusterRole, key, request or binding that the learner must write.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n starfleet rollout status deployment/scout --timeout=180s
kubectl -n outpost rollout status deployment/drifter --timeout=180s
echo "[lab] Ready."
