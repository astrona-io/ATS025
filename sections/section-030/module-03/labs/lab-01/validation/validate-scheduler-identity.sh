#!/usr/bin/env bash
# Check: schedulerKubeconfig equals the --kubeconfig flag of the kube-scheduler pod.
set -uo pipefail

flag_value() {
  kubectl -n kube-system get pod -l "component=$1" -o jsonpath='{range .items[0].spec.containers[0].command[*]}{@}{"\n"}{end}' 2>/dev/null | sed -n "s/^--$2=//p" | head -n 1
}
record_value() {
  kubectl -n starfleet get configmap pki-map -o go-template="{{index .data \"$1\"}}" 2>/dev/null || true
}

status=0
expected="$(flag_value kube-scheduler kubeconfig)"
actual="$(record_value schedulerKubeconfig)"
if [ -z "$expected" ]; then
  echo "FAIL: --kubeconfig not found on the kube-scheduler pod"
  status=1
elif [ "$actual" != "$expected" ]; then
  echo "FAIL: schedulerKubeconfig is '${actual}', the kube-scheduler pod declares '${expected}'"
  status=1
else
  echo "PASS: schedulerKubeconfig is ${actual}"
fi
exit "$status"
