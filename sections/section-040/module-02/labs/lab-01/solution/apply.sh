#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

image_tag() {
  kubectl -n kube-system get pod -l "component=$1" -o jsonpath='{.items[0].spec.containers[0].image}' | sed 's/@.*//; s/.*://'
}

api_version="$(image_tag kube-apiserver)"
api_minor="$(printf '%s\n' "$api_version" | sed -n 's/^v1\.\([0-9]*\).*/\1/p')"
if [ 31 -ge $((api_minor - 3)) ]; then verdict=supported; else verdict=unsupported; fi
stored="$(kubectl -n kube-system get configmap kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' | sed -n 's/^kubernetesVersion:[[:space:]]*//p' | tr -d '"' | tr -d '[:space:]' | head -n 1)"

kubectl -n starfleet create configmap upgrade-review \
  --from-literal=apiServerVersion="$api_version" \
  --from-literal=controllerManagerVersion="$(image_tag kube-controller-manager)" \
  --from-literal=schedulerVersion="$(image_tag kube-scheduler)" \
  --from-literal=kubeProxyVersion="$(kubectl -n kube-system get daemonset kube-proxy -o jsonpath='{.spec.template.spec.containers[0].image}' | sed 's/@.*//; s/.*://')" \
  --from-literal=kubeletVersion="$(kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.kubeletVersion}')" \
  --from-literal=storedVersion="$stored" \
  --from-literal=oldestKubelet="1.$((api_minor - 3))" \
  --from-literal=nextMinor="1.$((api_minor + 1))" \
  --from-literal=skewVerdict="$verdict" \
  --dry-run=client -o yaml | kubectl apply -f -
echo "[solution] Applied."
