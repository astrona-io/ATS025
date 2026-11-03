---
draft: true
exam_objectives:
- Understand extension interfaces (CNI, CSI, CRI, etc.)
---
# Storage Through CSI

A pod that needs data to survive a restart asks for a volume. Kubernetes does not create disks. A storage driver that follows the Container Storage Interface (CSI) creates, attaches and mounts them, and a few Kubernetes objects describe what the driver should do. When a claim stays `Pending` or a pod cannot start because of its volume, you must know which object and which component is responsible. This module explains that split.

Keep one idea in mind: **claims, classes and volumes are API objects, and the driver behind the class does the real storage work.** You read and write these objects and watch how a claim moves through its states.

The module has three parts. The first part covers StorageClass, PersistentVolumeClaim and PersistentVolume, and the order of events when a claim is provisioned. The second part opens a CSI driver: its services, its parts in the cluster, and the objects CSIDriver, CSINode and VolumeAttachment. The third part covers reclaim policy, expansion, access modes and how to diagnose a failure.

## Learning objectives

After this module you can:

- Say what a StorageClass, a PersistentVolumeClaim and a PersistentVolume are, and which one the user writes.
- Describe dynamic provisioning and the difference between `Immediate` and `WaitForFirstConsumer`.
- Name the CSI controller and node services and the sidecar containers that connect a driver to Kubernetes.
- Read the objects CSIDriver, CSINode and VolumeAttachment.
- Choose a reclaim policy, enable expansion, and find the failed stage of a volume.

## Before you start

You need Kubernetes basics: pods, namespaces, `kubectl get` and `kubectl apply`, and how to read YAML.

Your playground runs Kubernetes 1.35 with one node:

| Item | What is in it |
| --- | --- |
| `starfleet` | An empty namespace for claims and pods |
| cluster scope | The default StorageClass `standard` that kind creates, and no CSIDriver objects |

`kubectl` already points at the playground cluster, as the cluster administrator.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
