#!/usr/bin/env bash
# Starting state: a probe Deployment and Service in starfleet, a shuttle pod in starfleet and a drifter pod in outpost, with no NetworkPolicy.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet wait --for=condition=Ready pod/shuttle --timeout=180s
kubectl -n outpost wait --for=condition=Ready pod/drifter --timeout=180s
echo "[lab] Ready."
