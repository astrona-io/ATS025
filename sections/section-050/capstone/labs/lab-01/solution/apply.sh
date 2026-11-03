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
members="$(kubectl -n kube-system get pods -l component=etcd -o name | wc -l | tr -d ' ')"
quorum=$((members / 2 + 1))
tolerance=$((members - quorum))
if [ "$tolerance" -eq 0 ]; then
  verdict=single-point-of-failure
else
  verdict="tolerates-${tolerance}-failures"
fi
proposal="$(kubectl -n starfleet get configmap ha-proposal -o go-template='{{index .data "members"}}')"
proposal_quorum=$((proposal / 2 + 1))
proposal_tolerance=$((proposal - proposal_quorum))

kubectl -n starfleet create configmap ha-report \
  --from-literal=controlPlaneEndpoint="$endpoint" \
  --from-literal=etcdTopology="$topology" \
  --from-literal=etcdMembers="$members" \
  --from-literal=quorum="$quorum" \
  --from-literal=faultTolerance="$tolerance" \
  --from-literal=schedulerLeader="$(kubectl -n kube-system get lease kube-scheduler -o jsonpath='{.spec.holderIdentity}')" \
  --from-literal=controllerManagerLeader="$(kubectl -n kube-system get lease kube-controller-manager -o jsonpath='{.spec.holderIdentity}')" \
  --from-literal=proposalQuorum="$proposal_quorum" \
  --from-literal=proposalTolerance="$proposal_tolerance" \
  --from-literal=proposalOddMembers="$((2 * proposal_tolerance + 1))" \
  --from-literal=verdict="$verdict" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n mission-system delete rolebinding mission-edit --ignore-not-found
kubectl apply -f - <<'RBAC'
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: leader-election
  namespace: mission-system
rules:
  - apiGroups: ["coordination.k8s.io"]
    resources: ["leases"]
    verbs: ["get", "create", "update"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: leader-election
  namespace: mission-system
subjects:
  - kind: ServiceAccount
    name: mission-controller
    namespace: mission-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: leader-election
RBAC
echo "[solution] Applied."
