#!/usr/bin/env bash
# Check: all eleven keys of ha-report hold a real value.
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

status=0
for key in controlPlaneEndpoint etcdTopology etcdMembers quorum faultTolerance schedulerLeader controllerManagerLeader proposalQuorum proposalTolerance proposalOddMembers verdict; do
  value="$(record_value "$key")"
  if [ -z "$value" ] || [ "$value" = "unknown" ]; then
    echo "FAIL: $key has no real value"
    status=1
  else
    echo "PASS: $key is set"
  fi
done
exit "$status"
