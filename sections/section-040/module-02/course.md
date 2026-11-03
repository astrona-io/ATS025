---
draft: true
exam_objectives:
- Manage the lifecycle of Kubernetes clusters
---
# kubeadm Upgrade Workflow And Version Skew

A cluster upgrade is not one command. kubeadm changes the control plane in a fixed order, and every other component then has to stay inside a supported version distance from the API server. An upgrade that ignores either rule can leave a cluster with a kubelet that the API server no longer accepts, or with a controller manager that is newer than the API server it talks to.

Keep one sentence in mind: **kubeadm upgrades the control plane one minor version at a time, and every other component must stay within the version distance that the API server allows.** You will read the version of every control plane component, the kubelet and the stored kubeadm configuration from the API, and you will compute which versions are allowed before and after an upgrade.

The module has two parts. **The kubeadm Upgrade Workflow** explains what `kubeadm upgrade plan`, `kubeadm upgrade apply` and `kubeadm upgrade node` each change, in which order the nodes are handled and where the cluster keeps the configuration that the upgrade reads. **Version Skew Policy And Reading Versions** explains the maximum difference that Kubernetes supports between components, and how to read the real versions from the cluster.

## Learning objectives

After this module you can:

- Explain why kubeadm upgrades one minor version at a time and why patch versions can be skipped.
- Describe what `kubeadm upgrade plan`, `kubeadm upgrade apply` and `kubeadm upgrade node` change on a node.
- Give the order for upgrading control plane nodes, worker nodes and the kubelet package.
- State the version skew rules for the kube-apiserver, the controller manager, the scheduler, the kubelet, kube-proxy and kubectl.
- Read component versions from static pod images, node status and the `kubeadm-config` ConfigMap.

## Before you start

You need Kubernetes basics: nodes, namespaces, ConfigMaps, static pods and the commands `kubectl get` and `kubectl describe`. You do not need to upgrade anything. The playground cannot run `kubeadm upgrade`, because the node is a container. It does hold the same stored configuration and the same component pods that a real kubeadm cluster has, so you can read everything an upgrade plan starts from.

Your playground is a single-node `kind` cluster running Kubernetes 1.35.

| Object | What it is |
| --- | --- |
| Static pods in `kube-system` | The API server, controller manager, scheduler and etcd of the control plane node |
| ConfigMap `kubeadm-config` in `kube-system` | The `ClusterConfiguration` that kubeadm stored, including `kubernetesVersion` |
| ConfigMap `upgrade-review` in `starfleet` | An empty record with the keys you can fill in |

`kubectl` already points at the playground cluster, as the cluster administrator.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
