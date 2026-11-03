#!/usr/bin/env bash
# Check: the service account key pair keys equal the kube-apiserver and kube-controller-manager flags.
set -uo pipefail

flag_value() {
  kubectl -n kube-system get pod -l "component=$1" -o jsonpath='{range .items[0].spec.containers[0].command[*]}{@}{"\n"}{end}' 2>/dev/null | sed -n "s/^--$2=//p" | head -n 1
}
record_value() {
  kubectl -n starfleet get configmap pki-map -o go-template="{{index .data \"$1\"}}" 2>/dev/null || true
}

status=0
expected="$(flag_value kube-apiserver service-account-key-file)"
actual="$(record_value saPublicKey)"
if [ -z "$expected" ]; then
  echo "FAIL: --service-account-key-file not found on the kube-apiserver pod"
  status=1
elif [ "$actual" != "$expected" ]; then
  echo "FAIL: saPublicKey is '${actual}', the kube-apiserver pod declares '${expected}'"
  status=1
else
  echo "PASS: saPublicKey is ${actual}"
fi
expected="$(flag_value kube-controller-manager service-account-private-key-file)"
actual="$(record_value saSigningKey)"
if [ -z "$expected" ]; then
  echo "FAIL: --service-account-private-key-file not found on the kube-controller-manager pod"
  status=1
elif [ "$actual" != "$expected" ]; then
  echo "FAIL: saSigningKey is '${actual}', the kube-controller-manager pod declares '${expected}'"
  status=1
else
  echo "PASS: saSigningKey is ${actual}"
fi
exit "$status"
