#!/usr/bin/env bash
# Check: endpoint, topology, member count, quorum and fault tolerance equal the live cluster.
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

config="$(cluster_config)"
endpoint="$(printf '%s\n' "$config" | sed -n 's/^controlPlaneEndpoint: *//p' | head -n 1 | tr -d "\"' ")"
topology=""
if printf '%s\n' "$config" | grep -q '^  external:'; then topology=external
elif printf '%s\n' "$config" | grep -q '^  local:'; then topology=stacked
fi
members="$(live_members)"
if [ -z "$members" ] || [ "$members" = "0" ]; then
  echo "FAIL: could not count the etcd pods"
  exit 1
fi
quorum=$((members / 2 + 1))
status=0
compare controlPlaneEndpoint "$endpoint" || status=1
compare etcdTopology "$topology" || status=1
compare etcdMembers "$members" || status=1
compare quorum "$quorum" || status=1
compare faultTolerance "$((members - quorum))" || status=1
exit "$status"
