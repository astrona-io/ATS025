#!/usr/bin/env bash
# Starting state: a stale etcd-recovery record from an earlier cluster.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=180s
echo "[lab] Ready."
