#!/usr/bin/env bash
# Check: ConfigMap network-report records the node pod range and the shuttle pod address.
set -uo pipefail

status=0
report() { kubectl -n starfleet get configmap network-report -o "jsonpath={.data.$1}" 2>/dev/null; }

if ! kubectl -n starfleet get configmap network-report >/dev/null 2>&1; then
  echo "FAIL: ConfigMap network-report does not exist in starfleet"
  exit 1
fi

actual_cidr="$(kubectl get nodes -o jsonpath='{.items[0].spec.podCIDR}' 2>/dev/null)"
actual_ip="$(kubectl -n starfleet get pod shuttle -o jsonpath='{.status.podIP}' 2>/dev/null)"
if [ -z "$actual_cidr" ] || [ -z "$actual_ip" ]; then
  echo "FAIL: the cluster did not return a pod range or a shuttle address"
  exit 1
fi

if [ "$(report podCIDR)" = "$actual_cidr" ]; then
  echo "PASS: podCIDR is $actual_cidr"
else
  echo "FAIL: podCIDR must be $actual_cidr (the spec.podCIDR of the node)"
  status=1
fi
if [ "$(report shuttleIP)" = "$actual_ip" ]; then
  echo "PASS: shuttleIP is $actual_ip"
else
  echo "FAIL: shuttleIP must be $actual_ip (status.podIP of pod shuttle)"
  status=1
fi
exit "$status"
