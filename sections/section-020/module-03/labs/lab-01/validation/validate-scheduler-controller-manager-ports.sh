#!/usr/bin/env bash
# Check: scheduler and controllerManager equal the probe ports of their static
# pods. Rejects the old ports 10251 and 10252 from outdated guides.
set -uo pipefail

status=0
check_component() {
  local component="$1" key="$2" default_port="$3" expected actual
  expected="$(kubectl -n kube-system get pod -l "component=${component}" -o jsonpath='{.items[0].spec.containers[0].livenessProbe.httpGet.port}' 2>/dev/null || true)"
  expected="${expected:-$default_port}"
  actual="$(kubectl -n starfleet get configmap control-plane-ports -o go-template="{{index .data \"$key\"}}" 2>/dev/null || true)"
  if [ "$actual" != "$expected" ]; then
    echo "FAIL: ${key} is '${actual}', the ${component} pod declares '${expected}'"
    status=1
  else
    echo "PASS: ${key} is ${actual}"
  fi
}
check_component kube-scheduler scheduler 10259
check_component kube-controller-manager controllerManager 10257
exit "$status"
