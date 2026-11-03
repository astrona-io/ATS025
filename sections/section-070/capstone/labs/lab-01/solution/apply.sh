#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

provisioner="$(kubectl get storageclass standard -o jsonpath='{.provisioner}')"
pod_cidr="$(kubectl get nodes -o jsonpath='{.items[0].spec.podCIDR}')"
cluster_ip="$(kubectl -n starfleet get service probe -o jsonpath='{.spec.clusterIP}')"
runtime="$(kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.containerRuntimeVersion}')"
kubelet_version="$(kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.kubeletVersion}')"

kubectl -n starfleet create configmap platform-report \
  --from-literal=podCIDR="$pod_cidr" \
  --from-literal=probeClusterIP="$cluster_ip" \
  --from-literal=defaultClass=standard \
  --from-literal=containerRuntime="$runtime" \
  --from-literal=kubeletVersion="$kubelet_version" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f - <<MANIFEST
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: starfleet
spec:
  podSelector: {}
  policyTypes:
    - Ingress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: probe-from-shuttle
  namespace: starfleet
spec:
  podSelector:
    matchLabels:
      app: probe
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: shuttle
      ports:
        - protocol: TCP
          port: 8080
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: probe-from-outpost
  namespace: starfleet
spec:
  podSelector:
    matchLabels:
      app: probe
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: outpost
          podSelector:
            matchLabels:
              app: drifter
      ports:
        - protocol: TCP
          port: 8080
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: starfleet-data
provisioner: ${provisioner}
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
---
apiVersion: storage.k8s.io/v1
kind: CSIDriver
metadata:
  name: data.csi.astrona.io
spec:
  attachRequired: false
  podInfoOnMount: true
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: probe-data
  namespace: starfleet
spec:
  storageClassName: starfleet-data
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: recorder
  namespace: starfleet
  labels:
    app: recorder
spec:
  containers:
    - name: recorder
      image: docker.io/library/busybox:1.37.0
      command: ["sh", "-c", "sleep 3600"]
      volumeMounts:
        - name: data
          mountPath: /data
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: probe-data
MANIFEST
echo "[solution] Applied."
