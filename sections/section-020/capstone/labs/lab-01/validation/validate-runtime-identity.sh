#!/usr/bin/env bash
# Check: criSocket equals the kubeadm annotation on the node (when kubeadm set
# one, otherwise any unix:// path), and containerRuntimeVersion equals the node status.
set -uo pipefail

status=0
socket="$(kubectl get nodes -o jsonpath='{.items[0].metadata.annotations.kubeadm\.alpha\.kubernetes\.io/cri-socket}' 2>/dev/null || true)"
actual="$(kubectl -n starfleet get configmap readiness-review -o go-template='{{index .data "criSocket"}}' 2>/dev/null || true)"
if [ -n "$socket" ]; then
  if [ "$actual" != "$socket" ]; then
    echo "FAIL: criSocket is '${actual}', the node annotation says '${socket}'"
    status=1
  else
    echo "PASS: criSocket is ${actual}"
  fi
else
  case "$actual" in
    unix://*) echo "PASS: criSocket is ${actual}" ;;
    *) echo "FAIL: criSocket '${actual}' is not a unix:// path"; status=1 ;;
  esac
fi

expected="$(kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.containerRuntimeVersion}' 2>/dev/null || true)"
actual="$(kubectl -n starfleet get configmap readiness-review -o go-template='{{index .data "containerRuntimeVersion"}}' 2>/dev/null || true)"
if [ -z "$expected" ] || [ "$actual" != "$expected" ]; then
  echo "FAIL: containerRuntimeVersion is '${actual}', the node reports '${expected}'"
  status=1
else
  echo "PASS: containerRuntimeVersion is ${actual}"
fi
exit "$status"
