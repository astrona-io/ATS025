---
draft: true
exam_objectives:
- Prepare underlying infrastructure for installing a Kubernetes cluster
---
# Question

Solve this question on: `terminal`

The starfleet platform team reviews a node before a cluster upgrade. An earlier review left the ConfigMap `host-readiness` in the `starfleet` namespace, but its values are stale or wrong. Nobody may log in to the node, so you must take every value from the Kubernetes API.

1. Read the `KubeletConfiguration` that kubeadm stored in the ConfigMap `kubelet-config` in the `kube-system` namespace. Set the keys `cgroupDriver` and `failSwapOn` in `host-readiness` to the values stored there. If `failSwapOn` is not in the stored configuration, the kubelet default applies.

2. Read the node status. Set the keys `containerRuntimeVersion`, `kubeletVersion`, `kernelVersion` and `osImage` in `host-readiness` to the values the node reports in `status.nodeInfo`. Copy each value exactly.

3. Keep the ConfigMap name and namespace, and keep all six keys. Do not edit the `kubelet-config` ConfigMap or any other object in `kube-system`.

Check your work with `kubectl -n starfleet get configmap host-readiness -o yaml` and compare each value with its source. `kubectl` already points at the cluster as the cluster administrator.
