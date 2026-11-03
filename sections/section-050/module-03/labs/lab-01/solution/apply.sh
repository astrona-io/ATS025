#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

scheduler_leader="$(kubectl -n kube-system get lease kube-scheduler -o jsonpath='{.spec.holderIdentity}')"
manager_leader="$(kubectl -n kube-system get lease kube-controller-manager -o jsonpath='{.spec.holderIdentity}')"
duration="$(kubectl -n kube-system get lease kube-scheduler -o jsonpath='{.spec.leaseDurationSeconds}')"
flag="$(kubectl -n kube-system get pod -l component=kube-scheduler -o jsonpath='{range .items[0].spec.containers[0].command[*]}{@}{"\n"}{end}' | sed -n 's/^--leader-elect=//p' | head -n 1)"
liveness="$(kubectl -n kube-system get pod -l component=kube-apiserver -o jsonpath='{.items[0].spec.containers[0].livenessProbe.httpGet.path}')"
readiness="$(kubectl -n kube-system get pod -l component=kube-apiserver -o jsonpath='{.items[0].spec.containers[0].readinessProbe.httpGet.path}')"
endpoint_count="$(kubectl -n default get endpointslices -l kubernetes.io/service-name=kubernetes -o jsonpath='{range .items[*].endpoints[*]}{.addresses[0]}{"\n"}{end}' | grep -c . || true)"

kubectl -n starfleet create configmap control-plane-health \
  --from-literal=schedulerLeader="$scheduler_leader" \
  --from-literal=controllerManagerLeader="$manager_leader" \
  --from-literal=leaseDurationSeconds="$duration" \
  --from-literal=leaderElectFlag="$flag" \
  --from-literal=apiServerLivenessPath="$liveness" \
  --from-literal=apiServerReadinessPath="$readiness" \
  --from-literal=apiServerEndpointCount="$endpoint_count" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n starfleet delete rolebinding scout-edit --ignore-not-found
kubectl apply -f - <<'RBAC'
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: leader-election
  namespace: starfleet
rules:
  - apiGroups: ["coordination.k8s.io"]
    resources: ["leases"]
    verbs: ["get", "create", "update"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: leader-election
  namespace: starfleet
subjects:
  - kind: ServiceAccount
    name: scout-controller
    namespace: starfleet
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: leader-election
RBAC
echo "[solution] Applied."
