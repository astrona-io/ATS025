#!/usr/bin/env bash
# Check: the proposal in ha-proposal is judged with the quorum formula.
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

members="$(proposal_members)"
case "$members" in
  ''|*[!0-9]*) echo "FAIL: the ConfigMap ha-proposal has no numeric members value"; exit 1 ;;
esac
quorum=$((members / 2 + 1))
tolerance=$((members - quorum))
status=0
compare proposalQuorum "$quorum" || status=1
compare proposalTolerance "$tolerance" || status=1
compare proposalOddMembers "$((2 * tolerance + 1))" || status=1
exit "$status"
