---
draft: true
exam_objectives:
- Understand extension interfaces (CNI, CSI, CRI, etc.)
---
# Question

Solve this question on: `terminal`

The starfleet platform team must lock down the `probe` workload in `starfleet` and give it a place to keep data. The `probe` Deployment has two pods that listen on TCP port 8080 and a Service `probe`. The pod `shuttle` runs in `starfleet` and the pod `drifter` runs in `outpost`. The cluster has one node and the default StorageClass `standard`. Nothing of the new design exists yet.

Part A: record the platform facts.

1. Create the ConfigMap `platform-report` in `starfleet` with these keys, read from the cluster: `podCIDR` (the pod address range of the node), `probeClusterIP` (the cluster IP of the `probe` Service), `defaultClass` (the name of the default StorageClass), `containerRuntime` (the container runtime name and version that the node reports in `status.nodeInfo`) and `kubeletVersion` (the kubelet version the node reports).

Part B: network access.

2. Create the NetworkPolicy `default-deny-ingress` in `starfleet`. It selects every pod and denies all ingress.
3. Create the NetworkPolicy `probe-from-shuttle` in `starfleet`. It selects `app=probe` and allows ingress only from the pods `app=shuttle` in the same namespace, on TCP 8080.
4. Create the NetworkPolicy `probe-from-outpost` in `starfleet`. It selects `app=probe` and allows ingress only from pods labelled `app=drifter` that run in the namespace `outpost`, on TCP 8080. A pod labelled `app=drifter` in another namespace must not match. Use the automatic namespace label `kubernetes.io/metadata.name`.

All three policies control ingress only.

Part C: storage.

5. Create the StorageClass `starfleet-data`. It uses the same provisioner as `standard`, has the reclaim policy `Retain`, uses `WaitForFirstConsumer` and allows expansion. `standard` stays the only default class.
6. Create the CSIDriver object `data.csi.astrona.io` with `attachRequired: false` and `podInfoOnMount: true`.
7. Create the PersistentVolumeClaim `probe-data` in `starfleet`: `2Gi`, `ReadWriteOnce`, class `starfleet-data`.
8. Create the pod `recorder` in `starfleet` with the label `app=recorder`. Its first container uses the image `docker.io/library/busybox:1.37.0` with the command `sleep 3600` and mounts the claim `probe-data` at `/data`.

`kubectl` already points at the cluster as the cluster administrator. The grader reads the API objects. It does not require the pod to be running.
