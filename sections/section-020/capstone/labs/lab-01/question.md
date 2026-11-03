---
draft: true
exam_objectives:
- Prepare underlying infrastructure for installing a Kubernetes cluster
---
# Question

Solve this question on: `terminal`

The starfleet platform team plans an installation on new hosts and compares the plan with a running reference cluster. An earlier review left the ConfigMap `readiness-review` in the `starfleet` namespace. Its values describe an old installation and are wrong for this cluster. Nobody may log in to the node, so you must take every value from the Kubernetes API.

Set these eight keys in `readiness-review`:

1. `criSocket`: the container runtime socket that kubeadm recorded on the node as an annotation.
2. `containerRuntimeVersion`: the runtime name and version from the node status.
3. `cgroupDriver` and `failSwapOn`: the values in the `KubeletConfiguration` stored in the ConfigMap `kubelet-config` in `kube-system`. If `failSwapOn` is not stored, the kubelet default applies.
4. `apiserverPort`: the port the `kube-apiserver` static pod probes.
5. `etcdClientPort`: the port in the `--listen-client-urls` flag of the `etcd` static pod.
6. `serviceCIDR`: the value of `--service-cluster-ip-range` on the `kube-apiserver` pod.
7. `podCIDR`: the value of `--cluster-cidr` on the `kube-controller-manager` pod, or `none` if the flag is not set.

Keep the ConfigMap name and namespace. Do not edit the `kubelet-config` ConfigMap or any other object in `kube-system`. `kubectl` already points at the cluster as the cluster administrator.
