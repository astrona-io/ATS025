#!/usr/bin/env bash
# Check: dataHostPath and certHostPath equal the hostPath of the etcd-data and etcd-certs volumes.
set -uo pipefail

record_value() {
  kubectl -n starfleet get configmap etcd-recovery -o go-template="{{index .data \"$1\"}}" 2>/dev/null || true
}

# compare KEY EXPECTED : prints PASS or FAIL for one key and returns 1 on failure
compare() {
  local actual
  actual="$(record_value "$1")"
  if [ -z "$2" ]; then
    echo "FAIL: could not read the source of $1 from the cluster"
    return 1
  fi
  if [ "$actual" != "$2" ]; then
    echo "FAIL: $1 is '${actual}', the cluster says '${2}'"
    return 1
  fi
  echo "PASS: $1 is ${actual}"
}

etcd_flag() {
  kubectl -n kube-system get pod -l component=etcd -o jsonpath='{range .items[0].spec.containers[0].command[*]}{@}{"\n"}{end}' 2>/dev/null | sed -n "s/^--$1=//p" | head -n 1
}
etcd_volume_path() {
  kubectl -n kube-system get pod -l component=etcd -o jsonpath="{.items[0].spec.volumes[?(@.name==\"$1\")].hostPath.path}" 2>/dev/null
}

status=0
compare dataHostPath "$(etcd_volume_path etcd-data)" || status=1
compare certHostPath "$(etcd_volume_path etcd-certs)" || status=1
exit "$status"
