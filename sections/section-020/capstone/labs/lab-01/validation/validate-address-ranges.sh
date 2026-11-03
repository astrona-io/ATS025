#!/usr/bin/env bash
# Check: serviceCIDR equals the kube-apiserver --service-cluster-ip-range flag
# and podCIDR equals the kube-controller-manager --cluster-cidr flag. If the
# controller manager has no --cluster-cidr flag, the value 'none' is expected.
set -uo pipefail

flag_value() {
  kubectl -n kube-system get pod -l "component=$1" -o jsonpath='{range .items[0].spec.containers[0].command[*]}{@}{"\n"}{end}' 2>/dev/null | sed -n "s/^--$2=//p" | head -n 1
}

status=0
expected="$(flag_value kube-apiserver service-cluster-ip-range)"
actual="$(kubectl -n starfleet get configmap readiness-review -o go-template='{{index .data "serviceCIDR"}}' 2>/dev/null || true)"
if [ -z "$expected" ]; then
  echo "FAIL: --service-cluster-ip-range not found on the kube-apiserver pod"
  status=1
elif [ "$actual" != "$expected" ]; then
  echo "FAIL: serviceCIDR is '${actual}', the kube-apiserver pod declares '${expected}'"
  status=1
else
  echo "PASS: serviceCIDR is ${actual}"
fi

expected="$(flag_value kube-controller-manager cluster-cidr)"
expected="${expected:-none}"
actual="$(kubectl -n starfleet get configmap readiness-review -o go-template='{{index .data "podCIDR"}}' 2>/dev/null || true)"
if [ "$actual" != "$expected" ]; then
  echo "FAIL: podCIDR is '${actual}', the kube-controller-manager pod declares '${expected}'"
  status=1
else
  echo "PASS: podCIDR is ${actual}"
fi
exit "$status"
