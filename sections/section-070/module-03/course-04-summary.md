---
draft: true
exam_objectives:
- Understand extension interfaces (CNI, CSI, CRI, etc.)
---
# Summary

Storage in Kubernetes is described by three objects. A user writes a PersistentVolumeClaim, a request for a size and an access mode. A StorageClass names the provisioner and sets the reclaim policy, the binding mode and whether expansion is allowed. A PersistentVolume represents the storage that was created. The API server fills in the default class when a claim names none. An empty class name means no class and static binding.

A provisioner creates volumes on demand, and the PV controller binds the claim to the new volume. With `Immediate` binding, provisioning starts at once. With `WaitForFirstConsumer`, it waits until the scheduler picks a node for a pod that uses the claim, so a claim without a pod stays `Pending` by design.

The Container Storage Interface moves storage code out of Kubernetes into drivers that run as pods. A driver serves an identity, a controller and a node service. The controller group runs with Kubernetes sidecars that watch claims, attach requests and resize requests. The node group runs on every node and registers with the kubelet, which calls the node service to stage and publish volumes. The class names the driver in its provisioner field.

Three objects connect drivers to the cluster. A CSIDriver declares how Kubernetes must treat a driver, for example whether it needs an attach step. A CSINode lists the drivers registered on a node. A VolumeAttachment records an attach request. These objects describe a driver and do not run one.

The reclaim policy decides the fate of the data when a claim is deleted. `Delete` removes the volume, and `Retain` keeps it in the `Released` phase until an administrator acts. Expansion needs a class that allows it and a driver that implements it, and it runs in a controller stage and a node stage. A stuck volume is found by asking which stage failed: provisioning, binding, attaching, staging or publishing. Each stage has its own owner and its own events.

Key facts:

- The user writes the claim, the provisioner creates the volume, the PV controller binds them.
- A CSIDriver object is a declaration, not a running driver.
- A `Pending` claim can be correct, and the events tell the reason.

<!-- astrona:playground:destroy -->
