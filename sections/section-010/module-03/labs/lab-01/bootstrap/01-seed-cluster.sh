#!/usr/bin/env bash
# Starting state for the cluster-scope lab. Environment only: it creates the
# objects and the leftover over-broad binding. It creates no ClusterRole that
# the learner must write.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n starfleet get serviceaccount scout
echo "[lab] Ready."
