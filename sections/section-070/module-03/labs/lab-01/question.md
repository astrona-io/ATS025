---
draft: true
exam_objectives:
- Understand extension interfaces (CNI, CSI, CRI, etc.)
---
# Question

Solve this question on: `terminal`

The starfleet team wants a storage class for logs that keeps the data after a claim is deleted. The cluster is a kind cluster with the default StorageClass `standard`. An old claim `legacy-claim` already exists in `starfleet` and names no class.

1. Create the StorageClass `outpost-retain`. It must use the same provisioner as the `standard` class, keep the volume when its claim is deleted (reclaim policy `Retain`), create the volume only when a pod uses the claim (`WaitForFirstConsumer`), and allow volume expansion. It must not become a default class. `standard` must stay the only default class.
2. Create the CSIDriver object `logbook.csi.astrona.io` with these settings: no attach step (`attachRequired: false`), pod information passed on mount (`podInfoOnMount: true`), the lifecycle modes `Persistent` and `Ephemeral`, and `fsGroupPolicy: File`.
3. Create the PersistentVolumeClaim `logbook` in `starfleet`. It requests `1Gi` with the access mode `ReadWriteOnce` from the class `outpost-retain`. Do not create a pod. The claim must stay `Pending`.
4. Create the ConfigMap `storage-report` in `starfleet` with these keys, read from the cluster: `defaultClass` (the name of the default StorageClass), `provisioner`, `bindingMode` and `reclaimPolicy` (all three taken from the default class), and `legacyClaimClass` (the `storageClassName` of `legacy-claim`).

`kubectl` already points at the cluster as the cluster administrator.
