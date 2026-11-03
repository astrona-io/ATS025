#!/usr/bin/env bash
# Check: apiserver equals the port of the kube-apiserver static pod. The probe
# port is used; the --secure-port flag is the fallback; 6443 is the default.
set -uo pipefail

expected="$(kubectl -n kube-system get pod -l component=kube-apiserver -o jsonpath='{.items[0].spec.containers[0].livenessProbe.httpGet.port}' 2>/dev/null || true)"
if [ -z "$expected" ]; then
  expected="$(kubectl -n kube-system get pod -l component=kube-apiserver -o jsonpath='{range .items[0].spec.containers[0].command[*]}{@}{"\n"}{end}' 2>/dev/null | sed -n 's/^--secure-port=//p' | head -n 1)"
fi
expected="${expected:-6443}"
actual="$(kubectl -n starfleet get configmap control-plane-ports -o go-template='{{index .data "apiserver"}}' 2>/dev/null || true)"

if [ "$actual" != "$expected" ]; then
  echo "FAIL: apiserver is '${actual}', the kube-apiserver pod declares '${expected}'"
  exit 1
fi
echo "PASS: apiserver port is ${actual}"
