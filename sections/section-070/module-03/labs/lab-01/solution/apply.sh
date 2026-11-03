#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

provisioner="$(kubectl get storageclass standard -o jsonpath='{.provisioner}')"
binding_mode="$(kubectl get storageclass standard -o jsonpath='{.volumeBindingMode}')"
reclaim_policy="$(kubectl get storageclass standard -o jsonpath='{.reclaimPolicy}')"
legacy_class="$(kubectl -n starfleet get pvc legacy-claim -o jsonpath='{.spec.storageClassName}')"

kubectl apply -f - <<MANIFEST
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: outpost-retain
provisioner: ${provisioner}
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
---
apiVersion: storage.k8s.io/v1
kind: CSIDriver
metadata:
  name: logbook.csi.astrona.io
spec:
  attachRequired: false
  podInfoOnMount: true
  fsGroupPolicy: File
  volumeLifecycleModes:
    - Persistent
    - Ephemeral
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: logbook
  namespace: starfleet
spec:
  storageClassName: outpost-retain
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
MANIFEST

kubectl -n starfleet create configmap storage-report \
  --from-literal=defaultClass=standard \
  --from-literal=provisioner="$provisioner" \
  --from-literal=bindingMode="$binding_mode" \
  --from-literal=reclaimPolicy="$reclaim_policy" \
  --from-literal=legacyClaimClass="$legacy_class" \
  --dry-run=client -o yaml | kubectl apply -f -
echo "[solution] Applied."
