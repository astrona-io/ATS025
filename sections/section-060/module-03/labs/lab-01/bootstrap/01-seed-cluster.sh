#!/usr/bin/env bash
# Starting state: empty starfleet and outpost namespaces and one unrelated Deployment named bridge in starfleet.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n starfleet rollout status deployment/bridge --timeout=120s
echo "[lab] Ready."
