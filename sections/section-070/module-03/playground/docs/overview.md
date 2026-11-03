---
draft: true
exam_objectives:
- Understand extension interfaces (CNI, CSI, CRI, etc.)
---
# Overview: Storage Through CSI (Playground)

This is a playground, not a lab. It starts a clean cluster and then waits. There is no task, no `astrona submit` and no pass or fail. Read, change, break and start over.

## What is in the box

A `kind` cluster that runs Kubernetes 1.35 with one node. `kubectl` already points at it, as the cluster administrator.

| Item | What is in it |
| --- | --- |
| `starfleet` | An empty namespace for claims and pods |
| cluster scope | The default StorageClass `standard` that kind creates, and no CSIDriver objects |

## Practice tasks

- Read the default StorageClass with `kubectl get storageclass standard -o yaml` and find the provisioner, the binding mode and the reclaim policy.
- Create a claim without a class and read which class the API server assigned.
- Create a pod that uses the claim, and watch the claim go from `Pending` to `Bound`.
- Read the PersistentVolume that the provisioner created and find its reclaim policy and node affinity.
- Create a second StorageClass with `Retain`, delete a bound claim, and read the phase of the volume.
- Create a CSIDriver object and read it back. List `csinodes` and `volumeattachments`.
- Try to expand a claim whose class has `allowVolumeExpansion` unset and read the error.
- Add the default-class annotation to a second class and create a claim without a class. Read the result.
