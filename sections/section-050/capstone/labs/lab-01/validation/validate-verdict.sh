#!/usr/bin/env bash
# Check: the verdict follows from the fault tolerance and the cluster is untouched.
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

members="$(live_members)"
if [ -z "$members" ] || [ "$members" = "0" ]; then
  echo "FAIL: could not count the etcd pods"
  exit 1
fi
tolerance=$((members - (members / 2 + 1)))
if [ "$tolerance" -eq 0 ]; then
  expected="single-point-of-failure"
else
  expected="tolerates-${tolerance}-failures"
fi
status=0
compare verdict "$expected" || status=1
if [ "$(kubectl get --raw=/readyz 2>/dev/null)" != "ok" ]; then
  echo "FAIL: the API server is not ready"
  status=1
else
  echo "PASS: the API server is ready"
fi
if [ "$(proposal_members)" != "6" ]; then
  echo "FAIL: ha-proposal was changed"
  status=1
else
  echo "PASS: ha-proposal is unchanged"
fi
if [ -z "$(lease_holder kube-scheduler)" ] || [ -z "$(lease_holder kube-controller-manager)" ]; then
  echo "FAIL: a control plane Lease has no holder"
  status=1
else
  echo "PASS: the control plane Leases have holders"
fi
exit "$status"
