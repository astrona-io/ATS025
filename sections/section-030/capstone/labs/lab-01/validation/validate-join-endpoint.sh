#!/usr/bin/env bash
# Check: apiServerEndpoint equals the server line of the kubeconfig in cluster-info.
set -uo pipefail

expected="$(kubectl -n kube-public get configmap cluster-info -o jsonpath='{.data.kubeconfig}' 2>/dev/null | sed -n 's/^[[:space:]]*server:[[:space:]]*//p' | head -n 1 | tr -d '"' | tr -d '[:space:]')"
actual="$(kubectl -n starfleet get configmap init-review -o go-template='{{index .data "apiServerEndpoint"}}' 2>/dev/null || true)"
if [ -z "$expected" ]; then
  echo "FAIL: no server line found in the cluster-info ConfigMap"
  exit 1
fi
if [ "$actual" != "$expected" ]; then
  echo "FAIL: apiServerEndpoint is '${actual}', cluster-info says '${expected}'"
  exit 1
fi
echo "PASS: apiServerEndpoint is ${actual}"
