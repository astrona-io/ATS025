#!/usr/bin/env bash
# Check: the cluster signing certificate and the etcd peer certificate equal the control plane flags.
set -uo pipefail

flag_value() {
  kubectl -n kube-system get pod -l "component=$1" -o jsonpath='{range .items[0].spec.containers[0].command[*]}{@}{"\n"}{end}' 2>/dev/null | sed -n "s/^--$2=//p" | head -n 1
}
record_value() {
  kubectl -n starfleet get configmap pki-map -o go-template="{{index .data \"$1\"}}" 2>/dev/null || true
}

status=0
expected="$(flag_value kube-controller-manager cluster-signing-cert-file)"
actual="$(record_value clusterSigningCert)"
if [ -z "$expected" ]; then
  echo "FAIL: --cluster-signing-cert-file not found on the kube-controller-manager pod"
  status=1
elif [ "$actual" != "$expected" ]; then
  echo "FAIL: clusterSigningCert is '${actual}', the kube-controller-manager pod declares '${expected}'"
  status=1
else
  echo "PASS: clusterSigningCert is ${actual}"
fi
expected="$(flag_value etcd peer-cert-file)"
actual="$(record_value etcdPeerCert)"
if [ -z "$expected" ]; then
  echo "FAIL: --peer-cert-file not found on the etcd pod"
  status=1
elif [ "$actual" != "$expected" ]; then
  echo "FAIL: etcdPeerCert is '${actual}', the etcd pod declares '${expected}'"
  status=1
else
  echo "PASS: etcdPeerCert is ${actual}"
fi
exit "$status"
