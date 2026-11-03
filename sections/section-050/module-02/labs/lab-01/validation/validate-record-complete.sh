#!/usr/bin/env bash
# Check: all ten keys of topology-review hold a real value.
set -uo pipefail

record_value() {
  local value
  value="$(kubectl -n starfleet get configmap topology-review -o go-template="{{index .data \"$1\"}}" 2>/dev/null || true)"
  if [ "$value" = "<no value>" ]; then value=""; fi
  printf "%s" "$value"
}
cluster_config() {
  kubectl -n kube-system get configmap kubeadm-config -o go-template="{{index .data \"ClusterConfiguration\"}}" 2>/dev/null
}
live_endpoint() {
  cluster_config | sed -n "s/^controlPlaneEndpoint: *//p" | head -n 1 | tr -d "\"' "
}
live_topology() {
  local config
  config="$(cluster_config)"
  if printf "%s\n" "$config" | grep -q "^  external:"; then echo external
  elif printf "%s\n" "$config" | grep -q "^  local:"; then echo stacked
  fi
}
live_members() {
  kubectl -n kube-system get pods -l component=etcd -o name 2>/dev/null | wc -l | tr -d " "
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

status=0
for key in controlPlaneEndpoint etcdTopology controlPlaneNodes etcdMembers etcdClientUrl quorum faultTolerance proposalQuorum proposalTolerance proposalOddMembers; do
  value="$(record_value "$key")"
  if [ -z "$value" ] || [ "$value" = "unknown" ]; then
    echo "FAIL: $key has no real value"
    status=1
  else
    echo "PASS: $key is set"
  fi
done
exit "$status"
