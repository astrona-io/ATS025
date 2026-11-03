#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

kubectl apply -f - <<'BUNDLE'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: beacon-operator
  namespace: beacon-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: beacon-operator
rules:
  - apiGroups: ["training.astrona.io"]
    resources: ["beacons", "beacons/status"]
    verbs: ["get", "list", "watch", "update", "patch"]
  - apiGroups: ["coordination.k8s.io"]
    resources: ["leases"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["create", "patch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: beacon-operator
subjects:
  - kind: ServiceAccount
    name: beacon-operator
    namespace: beacon-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: beacon-operator
BUNDLE
kubectl -n beacon-system set serviceaccount deployment/beacon-operator beacon-operator
kubectl -n beacon-system set env deployment/beacon-operator WATCH_NAMESPACE=starfleet
kubectl -n beacon-system rollout status deployment/beacon-operator --timeout=120s
kubectl apply -f - <<'BEACON'
apiVersion: training.astrona.io/v1
kind: Beacon
metadata:
  name: first-beacon
  namespace: starfleet
spec:
  channel: alpha
BEACON
echo "[solution] Applied."
