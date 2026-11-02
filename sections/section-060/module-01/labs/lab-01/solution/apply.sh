#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-025-lab-060-01-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
lab_directory="$(cd "$(dirname "$0")/.." && pwd)"
solution_directory="$lab_directory/solution"
cluster_name="astro-ats-025-lab-060-01-01"

helm upgrade --install demo "$lab_directory/assets/chart" -n starfleet --set replicaCount=2 --set version=v1 --wait --timeout 3m
kubectl -n starfleet rollout status deployment/helm-probe --timeout=180s
