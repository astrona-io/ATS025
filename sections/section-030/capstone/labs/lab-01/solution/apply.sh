#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

cluster_yaml="$(kubectl -n kube-system get configmap kubeadm-config -o jsonpath='{.data.ClusterConfiguration}')"
top_field() { printf '%s\n' "$cluster_yaml" | grep -E "^$1:" | head -1 | sed -E 's/^[^:]*:[[:space:]]*//; s/["'"'"']//g; s/[[:space:]]+$//'; }
pod_subnet="$(printf '%s\n' "$cluster_yaml" | awk '/^networking:/ { inside = 1; next } /^[^ \t#]/ { inside = 0 } inside && /^[ \t]+podSubnet:/ { sub(/^[^:]*:[ \t]*/, ""); gsub(/["\047]/, ""); print; exit }')"
kubelet_yaml="$(kubectl -n kube-system get configmap kubelet-config -o jsonpath='{.data.kubelet}')"
cluster_dns="$(printf '%s\n' "$kubelet_yaml" | awk '/^clusterDNS:/ { found = 1; next } found && /^[[:space:]]*-/ { sub(/^[[:space:]]*-[[:space:]]*/, ""); gsub(/["\047[:space:]]/, ""); print; exit }')"

kubectl -n starfleet create configmap init-review \
  --from-literal=kubernetesVersion="$(top_field kubernetesVersion)" \
  --from-literal=podSubnet="$pod_subnet" \
  --from-literal=certificatesDir="$(top_field certificatesDir)" \
  --from-literal=apiServerEndpoint="$(kubectl -n kube-public get configmap cluster-info -o jsonpath='{.data.kubeconfig}' | sed -n 's/^[[:space:]]*server:[[:space:]]*//p' | head -n 1 | tr -d '[:space:]')" \
  --from-literal=joinGroup="$(kubectl get clusterrolebinding kubeadm:node-autoapprove-bootstrap -o jsonpath='{.subjects[0].name}')" \
  --from-literal=autoApproveRole="$(kubectl get clusterrolebinding kubeadm:node-autoapprove-bootstrap -o jsonpath='{.roleRef.name}')" \
  --from-literal=workerNodeName="$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].metadata.name}')" \
  --from-literal=clusterDNS="$cluster_dns" \
  --dry-run=client -o yaml | kubectl apply -f -
echo "[solution] Applied."
