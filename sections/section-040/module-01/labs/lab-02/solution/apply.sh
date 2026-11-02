#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-025-lab-040-01-02" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
lab_directory="$(cd "$(dirname "$0")/.." && pwd)"
solution_directory="$lab_directory/solution"
node_name="astro-ats-025-lab-040-01-02-control-plane"
worker_name="astro-ats-025-lab-040-01-02-worker"
kubectl -n kube-system exec etcd-astro-ats-025-lab-040-01-02-control-plane -- etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt --key=/etc/kubernetes/pki/etcd/healthcheck-client.key snapshot save /tmp/training-snapshot.db
kubectl apply -f "$solution_directory/configmap-snapshot-review.yaml"
python3 "$solution_directory/record-snapshot.py"
