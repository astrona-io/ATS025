#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cluster_yaml="$(kubectl -n kube-system get configmap kubeadm-config -o jsonpath='{.data.ClusterConfiguration}')"
read_top() { printf '%s\n' "$cluster_yaml" | grep -E "^$1:" | head -1 | sed -E 's/^[^:]*:[[:space:]]*//; s/["'"'"']//g; s/[[:space:]]+$//'; }
read_net() {
  printf '%s\n' "$cluster_yaml" | awk -v key="$1" '
    /^networking:/ { inside = 1; next }
    /^[^ \t#]/ { inside = 0 }
    inside && $0 ~ ("^[ \t]+" key ":") { value = $0; sub(/^[^:]*:[ \t]*/, "", value); gsub(/["\047]/, "", value); print value; exit }'
}

version="$(read_top kubernetesVersion)"
kubectl -n starfleet create configmap cluster-review \
  --from-literal=kubernetesVersion="$version" \
  --from-literal=clusterName="$(read_top clusterName)" \
  --from-literal=podSubnet="$(read_net podSubnet)" \
  --from-literal=serviceSubnet="$(read_net serviceSubnet)" \
  --dry-run=client -o yaml | kubectl apply -f -

sed "s/__VERSION__/${version}/" "$DIR/kubeadm-plan.yaml" | kubectl apply -f -
echo "[solution] Applied."
