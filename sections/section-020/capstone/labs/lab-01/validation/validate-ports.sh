#!/usr/bin/env bash
# Check: apiserverPort equals the kube-apiserver probe port (fallback 6443) and
# etcdClientPort equals the port in the etcd --listen-client-urls flag.
set -uo pipefail

status=0
expected="$(kubectl -n kube-system get pod -l component=kube-apiserver -o jsonpath='{.items[0].spec.containers[0].livenessProbe.httpGet.port}' 2>/dev/null || true)"
expected="${expected:-6443}"
actual="$(kubectl -n starfleet get configmap readiness-review -o go-template='{{index .data "apiserverPort"}}' 2>/dev/null || true)"
if [ "$actual" != "$expected" ]; then
  echo "FAIL: apiserverPort is '${actual}', the kube-apiserver pod declares '${expected}'"
  status=1
else
  echo "PASS: apiserverPort is ${actual}"
fi

expected="$(kubectl -n kube-system get pod -l component=etcd -o jsonpath='{range .items[0].spec.containers[0].command[*]}{@}{"\n"}{end}' 2>/dev/null | sed -n 's/^--listen-client-urls=//p' | head -n 1 | cut -d, -f1 | sed 's/.*://')"
actual="$(kubectl -n starfleet get configmap readiness-review -o go-template='{{index .data "etcdClientPort"}}' 2>/dev/null || true)"
if [ -z "$expected" ]; then
  echo "FAIL: --listen-client-urls not found on the etcd pod"
  status=1
elif [ "$actual" != "$expected" ]; then
  echo "FAIL: etcdClientPort is '${actual}', the etcd pod declares '${expected}'"
  status=1
else
  echo "PASS: etcdClientPort is ${actual}"
fi
exit "$status"
