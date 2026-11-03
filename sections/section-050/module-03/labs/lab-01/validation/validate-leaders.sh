#!/usr/bin/env bash
# Check: schedulerLeader and controllerManagerLeader equal the current Lease holders.
set -uo pipefail

record_value() {
  local value
  value="$(kubectl -n starfleet get configmap control-plane-health -o go-template="{{index .data \"$1\"}}" 2>/dev/null || true)"
  if [ "$value" = "<no value>" ]; then value=""; fi
  printf '%s' "$value"
}
compare() {
  local actual
  actual="$(record_value "$1")"
  if [ -z "$2" ]; then
    echo "FAIL: could not read the source of $1 from the cluster"
    return 1
  fi
  if [ "$actual" != "$2" ]; then
    echo "FAIL: $1 is \"${actual}\", the cluster says \"${2}\""
    return 1
  fi
  echo "PASS: $1 is ${actual}"
}
lease_holder() {
  kubectl -n kube-system get lease "$1" -o jsonpath='{.spec.holderIdentity}' 2>/dev/null || true
}
pod_probe_path() {
  kubectl -n kube-system get pod -l component=kube-apiserver -o jsonpath="{.items[0].spec.containers[0].$1.httpGet.path}" 2>/dev/null || true
}

status=0
compare schedulerLeader "$(lease_holder kube-scheduler)" || status=1
compare controllerManagerLeader "$(lease_holder kube-controller-manager)" || status=1
exit "$status"
