#!/usr/bin/env bash
# Starting state: the default StorageClass of kind, and an old claim in starfleet that names no class.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Wait until the default StorageClass exists, so the claim receives it when it is created.
for i in $(seq 1 60); do
  kubectl get storageclass standard >/dev/null 2>&1 && break
  sleep 2
done
kubectl apply -f "$DIR/manifests/lab-start.yaml"
echo "[lab] Ready."
