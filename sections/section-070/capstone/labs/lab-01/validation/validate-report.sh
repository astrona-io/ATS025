#!/usr/bin/env bash
# Check: ConfigMap platform-report records the pod range, Service address, default class and runtime facts.
set -uo pipefail

status=0
if ! kubectl -n starfleet get configmap platform-report >/dev/null 2>&1; then
  echo "FAIL: ConfigMap platform-report does not exist in starfleet"
  exit 1
fi
report() { kubectl -n starfleet get configmap platform-report -o "jsonpath={.data.$1}" 2>/dev/null; }
node() { kubectl get nodes -o "jsonpath={.items[0]$1}" 2>/dev/null; }

check_key() {
  local key="$1" expected="$2"
  if [ -n "$expected" ] && [ "$(report "$key")" = "$expected" ]; then
    echo "PASS: $key is $expected"
  else
    echo "FAIL: $key must be \"$expected\" (read it from the cluster)"
    status=1
  fi
}
check_key podCIDR "$(node '.spec.podCIDR')"
check_key probeClusterIP "$(kubectl -n starfleet get service probe -o jsonpath='{.spec.clusterIP}' 2>/dev/null)"
check_key defaultClass "$(kubectl get storageclass -o jsonpath='{range .items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")]}{.metadata.name}{end}' 2>/dev/null)"
check_key containerRuntime "$(node '.status.nodeInfo.containerRuntimeVersion')"
check_key kubeletVersion "$(node '.status.nodeInfo.kubeletVersion')"
exit "$status"
