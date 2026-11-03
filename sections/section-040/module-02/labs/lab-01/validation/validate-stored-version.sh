#!/usr/bin/env bash
# Check: storedVersion equals kubernetesVersion in the stored ClusterConfiguration.
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

stored="$(kubectl -n kube-system get configmap kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' 2>/dev/null | sed -n 's/^kubernetesVersion:[[:space:]]*//p' | tr -d '"' | tr -d '[:space:]' | head -n 1)"
compare storedVersion "$stored"
