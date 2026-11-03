---
draft: true
exam_objectives:
- Create and manage Kubernetes clusters using kubeadm
---
# Question

Solve this question on: `terminal`

The starfleet platform team prepares to add a worker node to a running cluster and keeps a join review in the ConfigMap `init-review` in the `starfleet` namespace. The review describes an old cluster and every value is wrong. The cluster was created with kubeadm, so it holds its own facts in the API. Nobody may log in to a node.

Set these eight keys in `init-review`:

1. `kubernetesVersion`, `podSubnet` and `certificatesDir`: the values in the `ClusterConfiguration` that kubeadm stored in the ConfigMap `kubeadm-config` in `kube-system`. `podSubnet` is under `networking`.
2. `apiServerEndpoint`: the `server` address in the kubeconfig held by the ConfigMap `cluster-info` in the `kube-public` namespace.
3. `joinGroup` and `autoApproveRole`: the subject name and the role name of the ClusterRoleBinding `kubeadm:node-autoapprove-bootstrap`.
4. `workerNodeName`: the name of the node that does not have the control-plane role label.
5. `clusterDNS`: the first address of `clusterDNS` in the `KubeletConfiguration` stored in the ConfigMap `kubelet-config` in `kube-system`.

Keep the ConfigMap name and namespace. Do not change any object in `kube-system` or `kube-public`. `kubectl` already points at the cluster as the cluster administrator.
