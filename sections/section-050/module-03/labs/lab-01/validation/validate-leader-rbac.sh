#!/usr/bin/env bash
# Check: scout-controller can manage leases in starfleet and has nothing broader.
set -uo pipefail

record_value() {
  local value
  value="$(kubectl -n starfleet get configmap control-plane-health -o go-template="{{index .data \"$1\"}}" 2>/dev/null || true)"
  if [ "$value" = "<no value>" ]; then value=""; fi
  printf '%s' "$value"
}
compare() {
  local actual
  actual="$(record_value "$1")"
  if [ -z "$2" ]; then
    echo "FAIL: could not read the source of $1 from the cluster"
    return 1
  fi
  if [ "$actual" != "$2" ]; then
    echo "FAIL: $1 is \"${actual}\", the cluster says \"${2}\""
    return 1
  fi
  echo "PASS: $1 is ${actual}"
}
lease_holder() {
  kubectl -n kube-system get lease "$1" -o jsonpath='{.spec.holderIdentity}' 2>/dev/null || true
}
pod_probe_path() {
  kubectl -n kube-system get pod -l component=kube-apiserver -o jsonpath="{.items[0].spec.containers[0].$1.httpGet.path}" 2>/dev/null || true
}

subject="system:serviceaccount:starfleet:scout-controller"
allowed() { kubectl auth can-i "$1" "$2" -n "$3" --as="$subject" 2>/dev/null; }
status=0
for verb in get create update; do
  if [ "$(allowed "$verb" leases.coordination.k8s.io starfleet)" = "yes" ]; then
    echo "PASS: scout-controller can $verb leases in starfleet"
  else
    echo "FAIL: scout-controller cannot $verb leases in starfleet"
    status=1
  fi
done
if [ "$(allowed delete leases.coordination.k8s.io starfleet)" = "yes" ]; then
  echo "FAIL: scout-controller can delete leases"
  status=1
else
  echo "PASS: scout-controller cannot delete leases"
fi
if [ "$(allowed get secrets starfleet)" = "yes" ]; then
  echo "FAIL: scout-controller can read Secrets"
  status=1
else
  echo "PASS: scout-controller cannot read Secrets"
fi
if [ "$(allowed update leases.coordination.k8s.io kube-system)" = "yes" ]; then
  echo "FAIL: scout-controller can update leases in kube-system"
  status=1
else
  echo "PASS: scout-controller cannot update leases in kube-system"
fi
exit "$status"
