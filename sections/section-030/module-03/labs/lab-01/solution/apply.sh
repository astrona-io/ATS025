#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

flag_value() {
  kubectl -n kube-system get pod -l "component=$1" -o jsonpath='{range .items[0].spec.containers[0].command[*]}{@}{"\n"}{end}' | sed -n "s/^--$2=//p" | head -n 1
}

kubectl -n starfleet create configmap pki-map \
  --from-literal=apiserverServingCert="$(flag_value kube-apiserver tls-cert-file)" \
  --from-literal=apiserverKubeletClientCert="$(flag_value kube-apiserver kubelet-client-certificate)" \
  --from-literal=apiserverEtcdClientCert="$(flag_value kube-apiserver etcd-certfile)" \
  --from-literal=saPublicKey="$(flag_value kube-apiserver service-account-key-file)" \
  --from-literal=saSigningKey="$(flag_value kube-controller-manager service-account-private-key-file)" \
  --from-literal=clusterSigningCert="$(flag_value kube-controller-manager cluster-signing-cert-file)" \
  --from-literal=etcdPeerCert="$(flag_value etcd peer-cert-file)" \
  --from-literal=schedulerKubeconfig="$(flag_value kube-scheduler kubeconfig)" \
  --dry-run=client -o yaml | kubectl apply -f -
echo "[solution] Applied."
