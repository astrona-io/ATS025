#!/usr/bin/env bash
# Starting state for the pod reader lab. Environment only: it creates the
# namespaces, the ServiceAccount and the leftover binding. It creates no Role
# and no RoleBinding that the learner must write.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n starfleet get serviceaccount shuttle
echo "[lab] Ready."
