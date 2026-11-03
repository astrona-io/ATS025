#!/usr/bin/env bash
# Check: the three API server certificate keys equal the kube-apiserver flags.
set -uo pipefail

flag_value() {
  kubectl -n kube-system get pod -l "component=$1" -o jsonpath='{range .items[0].spec.containers[0].command[*]}{@}{"\n"}{end}' 2>/dev/null | sed -n "s/^--$2=//p" | head -n 1
}
record_value() {
  kubectl -n starfleet get configmap pki-map -o go-template="{{index .data \"$1\"}}" 2>/dev/null || true
}

status=0
expected="$(flag_value kube-apiserver tls-cert-file)"
actual="$(record_value apiserverServingCert)"
if [ -z "$expected" ]; then
  echo "FAIL: --tls-cert-file not found on the kube-apiserver pod"
  status=1
elif [ "$actual" != "$expected" ]; then
  echo "FAIL: apiserverServingCert is '${actual}', the kube-apiserver pod declares '${expected}'"
  status=1
else
  echo "PASS: apiserverServingCert is ${actual}"
fi
expected="$(flag_value kube-apiserver kubelet-client-certificate)"
actual="$(record_value apiserverKubeletClientCert)"
if [ -z "$expected" ]; then
  echo "FAIL: --kubelet-client-certificate not found on the kube-apiserver pod"
  status=1
elif [ "$actual" != "$expected" ]; then
  echo "FAIL: apiserverKubeletClientCert is '${actual}', the kube-apiserver pod declares '${expected}'"
  status=1
else
  echo "PASS: apiserverKubeletClientCert is ${actual}"
fi
expected="$(flag_value kube-apiserver etcd-certfile)"
actual="$(record_value apiserverEtcdClientCert)"
if [ -z "$expected" ]; then
  echo "FAIL: --etcd-certfile not found on the kube-apiserver pod"
  status=1
elif [ "$actual" != "$expected" ]; then
  echo "FAIL: apiserverEtcdClientCert is '${actual}', the kube-apiserver pod declares '${expected}'"
  status=1
else
  echo "PASS: apiserverEtcdClientCert is ${actual}"
fi
exit "$status"
