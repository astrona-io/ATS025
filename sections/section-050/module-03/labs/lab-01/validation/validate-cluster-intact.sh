#!/usr/bin/env bash
# Check: the API server is ready and the control plane Leases still exist.
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
if [ "$(kubectl get --raw=/readyz 2>/dev/null)" != "ok" ]; then
  echo "FAIL: the API server is not ready"
  status=1
else
  echo "PASS: the API server is ready"
fi
for name in kube-scheduler kube-controller-manager; do
  if [ -z "$(lease_holder "$name")" ]; then
    echo "FAIL: the Lease $name has no holder"
    status=1
  else
    echo "PASS: the Lease $name has a holder"
  fi
done
exit "$status"
