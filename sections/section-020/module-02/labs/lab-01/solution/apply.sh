#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

kubelet_yaml="$(kubectl -n kube-system get configmap kubelet-config -o jsonpath='{.data.kubelet}')"
cgroup_driver="$(printf '%s\n' "$kubelet_yaml" | sed -n 's/^cgroupDriver:[[:space:]]*//p' | tr -d '"' | head -n 1)"
cgroup_driver="${cgroup_driver:-systemd}"
fail_swap_on="$(printf '%s\n' "$kubelet_yaml" | sed -n 's/^failSwapOn:[[:space:]]*//p' | tr -d '"' | head -n 1)"
fail_swap_on="${fail_swap_on:-true}"

node_fact() {
  kubectl get nodes -o jsonpath="{.items[0].status.nodeInfo.$1}"
}

kubectl -n starfleet create configmap host-readiness \
  --from-literal=cgroupDriver="$cgroup_driver" \
  --from-literal=failSwapOn="$fail_swap_on" \
  --from-literal=containerRuntimeVersion="$(node_fact containerRuntimeVersion)" \
  --from-literal=kubeletVersion="$(node_fact kubeletVersion)" \
  --from-literal=kernelVersion="$(node_fact kernelVersion)" \
  --from-literal=osImage="$(node_fact osImage)" \
  --dry-run=client -o yaml | kubectl apply -f -
echo "[solution] Applied."
