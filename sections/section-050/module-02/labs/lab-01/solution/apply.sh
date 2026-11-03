#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

cluster_config="$(kubectl -n kube-system get configmap kubeadm-config -o go-template='{{index .data "ClusterConfiguration"}}')"
endpoint="$(printf '%s\n' "$cluster_config" | sed -n 's/^controlPlaneEndpoint: *//p' | head -n 1 | tr -d "\"' ")"
if printf '%s\n' "$cluster_config" | grep -q '^  external:'; then
  topology=external
else
  topology=stacked
fi
nodes="$(kubectl get nodes -l node-role.kubernetes.io/control-plane -o name | wc -l | tr -d ' ')"
members="$(kubectl -n kube-system get pods -l component=etcd -o name | wc -l | tr -d ' ')"
client_url="$(kubectl -n kube-system get pod -l component=etcd -o jsonpath='{.items[0].metadata.annotations.kubeadm\.kubernetes\.io/etcd\.advertise-client-urls}')"
quorum=$((members / 2 + 1))
tolerance=$((members - quorum))
proposal="$(kubectl -n starfleet get configmap ha-proposal -o go-template='{{index .data "members"}}')"
proposal_quorum=$((proposal / 2 + 1))
proposal_tolerance=$((proposal - proposal_quorum))
proposal_odd=$((2 * proposal_tolerance + 1))

kubectl -n starfleet create configmap topology-review \
  --from-literal=controlPlaneEndpoint="$endpoint" \
  --from-literal=etcdTopology="$topology" \
  --from-literal=controlPlaneNodes="$nodes" \
  --from-literal=etcdMembers="$members" \
  --from-literal=etcdClientUrl="$client_url" \
  --from-literal=quorum="$quorum" \
  --from-literal=faultTolerance="$tolerance" \
  --from-literal=proposalQuorum="$proposal_quorum" \
  --from-literal=proposalTolerance="$proposal_tolerance" \
  --from-literal=proposalOddMembers="$proposal_odd" \
  --dry-run=client -o yaml | kubectl apply -f -
echo "[solution] Applied."
