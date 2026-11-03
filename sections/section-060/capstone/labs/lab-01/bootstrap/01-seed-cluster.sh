#!/usr/bin/env bash
# Starting state: a hand-applied relay Deployment and Service in starfleet without Helm metadata, an empty outpost namespace and the unrelated bridge Deployment.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n starfleet rollout status deployment/relay --timeout=120s
kubectl -n starfleet rollout status deployment/bridge --timeout=120s
kubectl -n kube-system create configmap lab-baseline \
  --from-literal=relay-deployment-uid="$(kubectl -n starfleet get deployment relay -o jsonpath='{.metadata.uid}')" \
  --from-literal=relay-service-uid="$(kubectl -n starfleet get service relay -o jsonpath='{.metadata.uid}')" \
  --from-literal=bridge-deployment-uid="$(kubectl -n starfleet get deployment bridge -o jsonpath='{.metadata.uid}')"
echo "[lab] Ready."
