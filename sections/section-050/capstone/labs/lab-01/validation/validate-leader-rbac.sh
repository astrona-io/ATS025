#!/usr/bin/env bash
# Check: mission-controller can manage leases in mission-system and has nothing broader.
set -uo pipefail

record_value() {
  local value
  value="$(kubectl -n starfleet get configmap ha-report -o go-template="{{index .data \"$1\"}}" 2>/dev/null || true)"
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
cluster_config() {
  kubectl -n kube-system get configmap kubeadm-config -o go-template='{{index .data "ClusterConfiguration"}}' 2>/dev/null
}
live_members() {
  kubectl -n kube-system get pods -l component=etcd -o name 2>/dev/null | wc -l | tr -d ' '
}
lease_holder() {
  kubectl -n kube-system get lease "$1" -o jsonpath='{.spec.holderIdentity}' 2>/dev/null || true
}
proposal_members() {
  kubectl -n starfleet get configmap ha-proposal -o go-template='{{index .data "members"}}' 2>/dev/null || true
}

subject="system:serviceaccount:mission-system:mission-controller"
allowed() { kubectl auth can-i "$1" "$2" -n "$3" --as="$subject" 2>/dev/null; }
status=0
for verb in get create update; do
  if [ "$(allowed "$verb" leases.coordination.k8s.io mission-system)" = "yes" ]; then
    echo "PASS: mission-controller can $verb leases in mission-system"
  else
    echo "FAIL: mission-controller cannot $verb leases in mission-system"
    status=1
  fi
done
if [ "$(allowed delete leases.coordination.k8s.io mission-system)" = "yes" ]; then
  echo "FAIL: mission-controller can delete leases"
  status=1
else
  echo "PASS: mission-controller cannot delete leases"
fi
if [ "$(allowed get secrets mission-system)" = "yes" ]; then
  echo "FAIL: mission-controller can read Secrets"
  status=1
else
  echo "PASS: mission-controller cannot read Secrets"
fi
if [ "$(allowed update leases.coordination.k8s.io kube-system)" = "yes" ]; then
  echo "FAIL: mission-controller can update leases in kube-system"
  status=1
else
  echo "PASS: mission-controller cannot update leases in kube-system"
fi
exit "$status"
