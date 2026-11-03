#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

kubectl apply -f - <<'CRD'
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: missions.training.astrona.io
spec:
  group: training.astrona.io
  scope: Namespaced
  names:
    kind: Mission
    plural: missions
    singular: mission
    shortNames:
      - msn
  versions:
    - name: v1
      served: true
      storage: true
      subresources:
        status: {}
      additionalPrinterColumns:
        - name: Phase
          type: string
          jsonPath: .spec.phase
        - name: Crew
          type: integer
          jsonPath: .spec.crewSize
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              required:
                - callSign
                - phase
              x-kubernetes-validations:
                - rule: "self.callSign == oldSelf.callSign"
                  message: "callSign cannot be changed after creation"
              properties:
                callSign:
                  type: string
                phase:
                  type: string
                  enum:
                    - Planned
                    - Active
                    - Done
                crewSize:
                  type: integer
                  minimum: 1
                  maximum: 20
                  default: 3
            status:
              type: object
              x-kubernetes-preserve-unknown-fields: true
CRD
kubectl wait --for=condition=Established crd/missions.training.astrona.io --timeout=60s
kubectl apply -f - <<'RBAC'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: mission-operator
  namespace: mission-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: mission-operator
rules:
  - apiGroups: ["training.astrona.io"]
    resources: ["missions", "missions/status"]
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
  name: mission-operator
subjects:
  - kind: ServiceAccount
    name: mission-operator
    namespace: mission-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: mission-operator
RBAC
kubectl -n mission-system set serviceaccount deployment/mission-operator mission-operator
kubectl -n mission-system rollout status deployment/mission-operator --timeout=120s
kubectl apply -f - <<'MISSION'
apiVersion: training.astrona.io/v1
kind: Mission
metadata:
  name: apollo
  namespace: starfleet
spec:
  callSign: apollo-one
  phase: Planned
MISSION
echo "[solution] Applied."
