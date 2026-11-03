#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

component_args() {
  kubectl -n kube-system get pod -l "component=$1" -o jsonpath='{range .items[0].spec.containers[0].command[*]}{@}{"\n"}{end}'
}
flag_value() {
  component_args "$1" | sed -n "s/^--$2=//p" | head -n 1
}

kubelet_yaml="$(kubectl -n kube-system get configmap kubelet-config -o jsonpath='{.data.kubelet}')"
cgroup_driver="$(printf '%s\n' "$kubelet_yaml" | sed -n 's/^cgroupDriver:[[:space:]]*//p' | tr -d '"' | head -n 1)"
cgroup_driver="${cgroup_driver:-systemd}"
fail_swap_on="$(printf '%s\n' "$kubelet_yaml" | sed -n 's/^failSwapOn:[[:space:]]*//p' | tr -d '"' | head -n 1)"
fail_swap_on="${fail_swap_on:-true}"
cri_socket="$(kubectl get nodes -o jsonpath='{.items[0].metadata.annotations.kubeadm\.alpha\.kubernetes\.io/cri-socket}')"
etcd_client_port="$(flag_value etcd listen-client-urls | cut -d, -f1 | sed 's/.*://')"
pod_cidr="$(flag_value kube-controller-manager cluster-cidr)"

kubectl -n starfleet create configmap readiness-review \
  --from-literal=criSocket="$cri_socket" \
  --from-literal=containerRuntimeVersion="$(kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.containerRuntimeVersion}')" \
  --from-literal=cgroupDriver="$cgroup_driver" \
  --from-literal=failSwapOn="$fail_swap_on" \
  --from-literal=apiserverPort="$(kubectl -n kube-system get pod -l component=kube-apiserver -o jsonpath='{.items[0].spec.containers[0].livenessProbe.httpGet.port}')" \
  --from-literal=etcdClientPort="$etcd_client_port" \
  --from-literal=podCIDR="${pod_cidr:-none}" \
  --from-literal=serviceCIDR="$(flag_value kube-apiserver service-cluster-ip-range)" \
  --dry-run=client -o yaml | kubectl apply -f -
echo "[solution] Applied."
