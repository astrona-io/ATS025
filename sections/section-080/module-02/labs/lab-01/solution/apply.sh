#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

kubectl apply -f - <<'CRD'
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: beacons.training.astrona.io
spec:
  group: training.astrona.io
  scope: Namespaced
  names:
    kind: Beacon
    plural: beacons
    singular: beacon
    shortNames:
      - bcn
  versions:
    - name: v1
      served: true
      storage: true
      subresources:
        status: {}
      additionalPrinterColumns:
        - name: Channel
          type: string
          jsonPath: .spec.channel
        - name: Interval
          type: integer
          jsonPath: .spec.interval
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              required:
                - channel
              x-kubernetes-validations:
                - rule: "self.channel == oldSelf.channel"
                  message: "channel cannot be changed after creation"
              properties:
                channel:
                  type: string
                  enum:
                    - alpha
                    - beta
                    - gamma
                interval:
                  type: integer
                  minimum: 5
                  maximum: 3600
                  default: 60
            status:
              type: object
              x-kubernetes-preserve-unknown-fields: true
CRD
kubectl wait --for=condition=Established crd/beacons.training.astrona.io --timeout=60s
echo "[solution] Applied."
