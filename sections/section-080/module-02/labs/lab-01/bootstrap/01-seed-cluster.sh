#!/usr/bin/env bash
# Starting state: a Beacon CRD that accepts any content, and one stored Beacon object.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl wait --for=condition=Established crd/beacons.training.astrona.io --timeout=60s
for i in $(seq 1 30); do
  kubectl -n starfleet get beacon legacy-beacon >/dev/null 2>&1 && break
  kubectl apply -f "$DIR/manifests/legacy-beacon.yaml" >/dev/null 2>&1 || true
  sleep 2
done
echo "[lab] Ready."
