#!/usr/bin/env bash
# Check: kubernetesVersion, podSubnet and certificatesDir equal the values in the
# ClusterConfiguration stored in the kubeadm-config ConfigMap.
set -uo pipefail

cluster_yaml="$(kubectl -n kube-system get configmap kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' 2>/dev/null || true)"
if [ -z "$cluster_yaml" ]; then
  echo "FAIL: cannot read ClusterConfiguration from kubeadm-config in kube-system"
  exit 1
fi
top_field() {
  printf '%s\n' "$cluster_yaml" | grep -E "^$1:" | head -1 | sed -E "s/^[^:]*:[[:space:]]*//; s/[\"']//g; s/[[:space:]]+\$//"
}
net_field() {
  printf '%s\n' "$cluster_yaml" | awk -v key="$1" '
    /^networking:[ \t]*$/ { inside = 1; next }
    /^[^ \t#]/ { inside = 0 }
    inside && $0 ~ ("^[ \t]+" key ":") { value = $0; sub(/^[^:]*:[ \t]*/, "", value); gsub(/["\047]/, "", value); sub(/[ \t]+$/, "", value); print value; exit }'
}
record_value() {
  kubectl -n starfleet get configmap init-review -o go-template="{{index .data \"$1\"}}" 2>/dev/null || true
}

status=0
check() {
  local key="$1" expected="$2" actual
  actual="$(record_value "$key")"
  if [ -z "$expected" ]; then
    echo "FAIL: cannot read the expected value for ${key}"; status=1
  elif [ "$actual" != "$expected" ]; then
    echo "FAIL: ${key} is '${actual}', the stored configuration says '${expected}'"; status=1
  else
    echo "PASS: ${key} is ${actual}"
  fi
}
check kubernetesVersion "$(top_field kubernetesVersion)"
check podSubnet "$(net_field podSubnet)"
check certificatesDir "$(top_field certificatesDir)"
exit "$status"
