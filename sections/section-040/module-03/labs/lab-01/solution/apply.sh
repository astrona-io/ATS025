#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

pod="$(kubectl -n kube-system get pod -l component=etcd -o jsonpath='{.items[0].metadata.name}')"
etcd_flag() {
  kubectl -n kube-system get pod -l component=etcd -o jsonpath='{range .items[0].spec.containers[0].command[*]}{@}{"\n"}{end}' | sed -n "s/^--$1=//p" | head -n 1
}
volume_path() {
  kubectl -n kube-system get pod -l component=etcd -o jsonpath="{.items[0].spec.volumes[?(@.name==\"$1\")].hostPath.path}"
}

kubectl -n kube-system exec "$pod" -- etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt \
  --key=/etc/kubernetes/pki/etcd/healthcheck-client.key snapshot save /tmp/recovery-snapshot.db
status_json="$(kubectl -n kube-system exec "$pod" -- etcdutl snapshot status /tmp/recovery-snapshot.db --write-out=json)"
revision="$(printf '%s\n' "$status_json" | sed -n 's/.*"revision":\([0-9]*\).*/\1/p')"
total_keys="$(printf '%s\n' "$status_json" | sed -n 's/.*"totalKey":\([0-9]*\).*/\1/p')"

kubectl -n starfleet create configmap etcd-recovery \
  --from-literal=dataDir="$(etcd_flag data-dir)" \
  --from-literal=memberName="$(etcd_flag name)" \
  --from-literal=trustedCaFile="$(etcd_flag trusted-ca-file)" \
  --from-literal=peerUrl="$(etcd_flag initial-advertise-peer-urls)" \
  --from-literal=dataHostPath="$(volume_path etcd-data)" \
  --from-literal=certHostPath="$(volume_path etcd-certs)" \
  --from-literal=snapshotRevision="$revision" \
  --from-literal=snapshotTotalKeys="$total_keys" \
  --dry-run=client -o yaml | kubectl apply -f -
echo "[solution] Applied."
