#!/usr/bin/env bash
# Check: kubeProxyVersion equals the kube-proxy DaemonSet image tag and kubeletVersion equals the node status.
set -uo pipefail

record_value() {
  kubectl -n starfleet get configmap upgrade-review -o go-template="{{index .data \"$1\"}}" 2>/dev/null || true
}

# compare KEY EXPECTED : prints PASS or FAIL for one key and returns 1 on failure
compare() {
  local actual
  actual="$(record_value "$1")"
  if [ -z "$2" ]; then
    echo "FAIL: could not read the source of $1 from the cluster"
    return 1
  fi
  if [ "$actual" != "$2" ]; then
    echo "FAIL: $1 is '${actual}', the cluster says '${2}'"
    return 1
  fi
  echo "PASS: $1 is ${actual}"
}

proxy_tag="$(kubectl -n kube-system get daemonset kube-proxy -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null | sed 's/@.*//; s/.*://')"
kubelet_version="$(kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.kubeletVersion}' 2>/dev/null)"
status=0
compare kubeProxyVersion "$proxy_tag" || status=1
compare kubeletVersion "$kubelet_version" || status=1
exit "$status"
