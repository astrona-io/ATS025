---
draft: true
exam_objectives:
- Create and manage Kubernetes clusters using kubeadm
---
# Question

Solve this question on: `terminal`

The outpost team plans a second cluster that follows the same Kubernetes version as the running cluster but uses its own address ranges. The plan is kept in the ConfigMap `kubeadm-plan` in the `starfleet` namespace, key `kubeadm.yaml`. The draft in it has mistakes. The running cluster was created with kubeadm, so it holds its own cluster configuration in the API.

1. Read the `ClusterConfiguration` that kubeadm stored in the running cluster. Create a ConfigMap `cluster-review` in `starfleet` with the keys `kubernetesVersion`, `clusterName`, `podSubnet` and `serviceSubnet`. Each value must be the value of the running cluster, written without spaces.

2. Replace the draft in the ConfigMap `kubeadm-plan` (same name, same key `kubeadm.yaml`) with a kubeadm configuration file that has two documents and uses the API version `kubeadm.k8s.io/v1beta4` in both:

   - An `InitConfiguration` whose `nodeRegistration.name` is `outpost-cp-1`.
   - A `ClusterConfiguration` with `clusterName` `outpost`, the same `kubernetesVersion` as the running cluster, `controlPlaneEndpoint` `outpost-api.example.test:6443`, `podSubnet` `10.200.0.0/16` and `serviceSubnet` `10.201.0.0/16`. Both subnets belong under `networking`.

Do not change anything in the `kube-system` namespace. `kubectl` already points at the cluster as the cluster administrator. After each change, run `astrona submit` to see which checks pass.
