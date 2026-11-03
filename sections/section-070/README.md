# Extension Interfaces: CNI, CSI And CRI

This section explains how Kubernetes uses three extension interfaces to connect the core cluster to other software. The Container Runtime Interface (CRI) connects the kubelet to the container runtime. The Container Network Interface (CNI) connects pods to the network. The Container Storage Interface (CSI) connects pods to storage. Each interface has its own responsibilities, its own objects and its own failure signs.

After this section you can:

- Distinguish CNI, CSI and CRI responsibilities and name the component that calls each one.
- Follow the steps from a scheduled pod to a running container with an address and a volume.
- Read pod ranges, Service addresses and EndpointSlices, and write NetworkPolicy objects.
- Write StorageClass, PersistentVolumeClaim and CSIDriver objects, and diagnose the failed stage of a volume.

## Modules

| Module | Title | What it covers |
| --- | --- | --- |
| module-01 | Networking, Storage And Runtime Interfaces | The three interfaces side by side, runtimes and Kubernetes integration |
| module-02 | Pod Networking Through CNI | The call chain from the kubelet to the plugin, pod addresses, Services and DNS, NetworkPolicy and who enforces it |
| module-03 | Storage Through CSI | StorageClass, claims and provisioning, CSI drivers and their objects, reclaim, expansion and failure cases |

Every module has a playground, a graded lab and a summary. The section ends with a capstone lab and a knowledge check.

## Other files

| Path | Purpose |
| --- | --- |
| `capstone/labs/lab-01` | Capstone lab that combines network policy, storage and node facts |
| `quiz.yaml` | Knowledge check for the section |
| `questions.yaml` | Earlier question bank, kept as it is |
