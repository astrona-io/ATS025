#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

component_args() {
  kubectl -n kube-system get pod -l "component=$1" -o jsonpath='{range .items[0].spec.containers[0].command[*]}{@}{"\n"}{end}'
}
probe_port() {
  kubectl -n kube-system get pod -l "component=$1" -o jsonpath='{.items[0].spec.containers[0].livenessProbe.httpGet.port}'
}
url_port() {
  component_args etcd | sed -n "s/^--$1=//p" | head -n 1 | cut -d, -f1 | sed 's/.*://'
}

kubectl -n starfleet create configmap control-plane-ports \
  --from-literal=apiserver="$(probe_port kube-apiserver)" \
  --from-literal=etcdClient="$(url_port listen-client-urls)" \
  --from-literal=etcdPeer="$(url_port listen-peer-urls)" \
  --from-literal=scheduler="$(probe_port kube-scheduler)" \
  --from-literal=controllerManager="$(probe_port kube-controller-manager)" \
  --from-literal=kubelet="$(kubectl get nodes -o jsonpath='{.items[0].status.daemonEndpoints.kubeletEndpoint.Port}')" \
  --dry-run=client -o yaml | kubectl apply -f -
echo "[solution] Applied."
