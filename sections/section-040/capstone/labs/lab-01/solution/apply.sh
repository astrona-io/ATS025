#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

image_tag() {
  kubectl -n kube-system get pod -l "component=$1" -o jsonpath='{.items[0].spec.containers[0].image}' | sed 's/@.*//; s/.*://'
}

api_version="$(image_tag kube-apiserver)"
api_minor="$(printf '%s\n' "$api_version" | sed -n 's/^v1\.\([0-9]*\).*/\1/p')"
stored="$(kubectl -n kube-system get configmap kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' | sed -n 's/^kubernetesVersion:[[:space:]]*//p' | tr -d '"' | tr -d '[:space:]' | head -n 1)"
worker="$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].metadata.name}')"
pod="$(kubectl -n kube-system get pod -l component=etcd -o jsonpath='{.items[0].metadata.name}')"

kubectl -n kube-system exec "$pod" -- etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt \
  --key=/etc/kubernetes/pki/etcd/healthcheck-client.key snapshot save /tmp/lifecycle-snapshot.db
status_json="$(kubectl -n kube-system exec "$pod" -- etcdutl snapshot status /tmp/lifecycle-snapshot.db --write-out=json)"
revision="$(printf '%s\n' "$status_json" | sed -n 's/.*"revision":\([0-9]*\).*/\1/p')"
total_keys="$(printf '%s\n' "$status_json" | sed -n 's/.*"totalKey":\([0-9]*\).*/\1/p')"

kubectl uncordon "$worker"

kubectl -n starfleet create configmap lifecycle-review \
  --from-literal=apiServerVersion="$api_version" \
  --from-literal=kubeletVersion="$(kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.kubeletVersion}')" \
  --from-literal=storedVersion="$stored" \
  --from-literal=etcdVersion="$(image_tag etcd)" \
  --from-literal=oldestKubelet="1.$((api_minor - 3))" \
  --from-literal=nextMinor="1.$((api_minor + 1))" \
  --from-literal=snapshotRevision="$revision" \
  --from-literal=snapshotTotalKeys="$total_keys" \
  --from-literal=snapshotPath=/tmp/lifecycle-snapshot.db \
  --from-literal=workerName="$worker" \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl -n starfleet rollout status deployment/probe --timeout=180s
echo "[solution] Applied."
