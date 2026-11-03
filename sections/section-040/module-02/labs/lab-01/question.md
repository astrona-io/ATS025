---
draft: true
exam_objectives:
- Manage the lifecycle of Kubernetes clusters
---
# Question

Solve this question on: `terminal`

The starfleet platform team reviews the cluster before an upgrade. An earlier review left the ConfigMap `upgrade-review` in the `starfleet` namespace, but its values are stale. Nobody may log in to a node, so you must take every value from the Kubernetes API.

1. Set `apiServerVersion`, `controllerManagerVersion` and `schedulerVersion` to the version in the image tag of the matching control plane static pod in `kube-system`. Write the tag with the leading `v`, for example `v1.35.0`.

2. Set `kubeProxyVersion` to the image tag of the `kube-proxy` DaemonSet in `kube-system`, and `kubeletVersion` to the kubelet version that the node reports in its status.

3. Set `storedVersion` to the `kubernetesVersion` value in the `ClusterConfiguration` that the ConfigMap `kubeadm-config` in `kube-system` stores.

4. Apply the version skew policy to the API server version. Set `oldestKubelet` to the oldest minor version that a kubelet may have, and `nextMinor` to the minor version that kubeadm upgrades to next. Write both as `1.NN`, without the `v`. Set `skewVerdict` to `supported` or `unsupported` for a worker whose kubelet is at `v1.31.4`.

5. Keep the ConfigMap name and namespace, and keep all nine keys. Do not edit `kubeadm-config` or any other object in `kube-system`.

Check your work with `kubectl -n starfleet get configmap upgrade-review -o yaml`. `kubectl` already points at the cluster as the cluster administrator.
