#!/usr/bin/env bash
# Starting state: the Beacon CRD and an operator Deployment that still runs as the default ServiceAccount, without permissions.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl wait --for=condition=Established crd/beacons.training.astrona.io --timeout=60s
echo "[lab] Ready."
