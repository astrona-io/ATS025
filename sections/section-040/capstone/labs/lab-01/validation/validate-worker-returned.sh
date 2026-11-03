#!/usr/bin/env bash
# Check: workerName is the worker node, the worker is schedulable and the probe Deployment has all replicas available.
set -uo pipefail

record_value() {
  kubectl -n starfleet get configmap lifecycle-review -o go-template="{{index .data \"$1\"}}" 2>/dev/null || true
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

worker="$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)"
status=0
compare workerName "$worker" || status=1
if [ -z "$worker" ]; then
  exit 1
fi
unschedulable="$(kubectl get node "$worker" -o jsonpath='{.spec.unschedulable}' 2>/dev/null)"
if [ "$unschedulable" = "true" ]; then
  echo "FAIL: node $worker is still cordoned"
  status=1
else
  echo "PASS: node $worker is schedulable"
fi
ready="$(kubectl -n starfleet get deployment probe -o jsonpath='{.status.availableReplicas}' 2>/dev/null)"
if [ "${ready:-0}" != "2" ]; then
  echo "FAIL: the probe Deployment has ${ready:-0} of 2 replicas available"
  status=1
else
  echo "PASS: the probe Deployment has 2 of 2 replicas available"
fi
exit "$status"
