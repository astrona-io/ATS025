#!/usr/bin/env bash
# Check: etcdClient and etcdPeer equal the ports in the etcd listen URLs.
set -uo pipefail

etcd_args="$(kubectl -n kube-system get pod -l component=etcd -o jsonpath='{range .items[0].spec.containers[0].command[*]}{@}{"\n"}{end}' 2>/dev/null || true)"
if [ -z "$etcd_args" ]; then
  echo "FAIL: the etcd static pod was not found in kube-system"
  exit 1
fi

status=0
check_port() {
  local flag="$1" key="$2" expected actual
  expected="$(printf '%s\n' "$etcd_args" | sed -n "s/^--${flag}=//p" | head -n 1 | cut -d, -f1 | sed 's/.*://')"
  actual="$(kubectl -n starfleet get configmap control-plane-ports -o go-template="{{index .data \"$key\"}}" 2>/dev/null || true)"
  if [ -z "$expected" ]; then
    echo "FAIL: flag --${flag} not found on the etcd pod"
    status=1
  elif [ "$actual" != "$expected" ]; then
    echo "FAIL: ${key} is '${actual}', the etcd pod declares '${expected}'"
    status=1
  else
    echo "PASS: ${key} is ${actual}"
  fi
}
check_port listen-client-urls etcdClient
check_port listen-peer-urls etcdPeer
exit "$status"
