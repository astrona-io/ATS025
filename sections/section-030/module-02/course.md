---
draft: true
exam_objectives:
- Create and manage Kubernetes clusters using kubeadm
---
# kubeadm Configuration Files And Init Phases

A `kubeadm init` command with a dozen flags is hard to review, hard to repeat and hard to keep in version control. A kubeadm configuration file holds the same choices in one place. It also decides what ends up in the cluster afterwards, because kubeadm stores the cluster-wide part in a ConfigMap that every later `join`, `upgrade` and `reset` reads.

Keep one idea in mind for this module: **kubeadm reads one file with several kinds of settings, runs a fixed list of phases, and leaves a copy of the cluster-wide settings in the API.** You will read that copy in a running cluster, find the fields that matter for networking and the control plane endpoint, and write a correct file for a new cluster.

The module has two parts. The first part names the configuration kinds (`InitConfiguration`, `ClusterConfiguration`, `JoinConfiguration` and `KubeletConfiguration`), prints the defaults and explains the networking and version fields. The second part walks through the phases of `kubeadm init`, what each phase writes and where kubeadm keeps its configuration inside the cluster.

## Learning objectives

After this module you can:

- Name the four configuration kinds and say which settings belong to each.
- Print the default configuration and validate a configuration file.
- Read `kubernetesVersion`, `podSubnet`, `serviceSubnet`, `clusterName` and `controlPlaneEndpoint` from the `kubeadm-config` ConfigMap.
- List the phases of `kubeadm init` in order and say what each one creates.
- Write a configuration file with the correct API version, kinds and field nesting.

## Before you start

You need Kubernetes basics: pods, namespaces, ConfigMaps, labels, and the commands `kubectl get`, `kubectl apply` and `kubectl describe`. You do not need a second machine. The playground is a `kind` cluster that kubeadm created, so its `kubeadm-config` ConfigMap is real.

Your playground runs Kubernetes 1.35 with one control-plane node and one worker node:

| Item | What is in it |
| --- | --- |
| `kube-system` | The `kubeadm-config` and `kubelet-config` ConfigMaps that kubeadm wrote when it created the cluster |
| `starfleet` | A `probe` Deployment and a ConfigMap `kubeadm-plan` that holds a draft configuration file with mistakes |
| `outpost` | An empty namespace for your own notes |

`kubectl` already points at the playground cluster, as the cluster administrator.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
