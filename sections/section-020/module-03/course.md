---
draft: true
exam_objectives:
- Prepare underlying infrastructure for installing a Kubernetes cluster
---
# Packages, Ports And kubeadm Preflight Checks

The last steps before `kubeadm init` are small and easy to get wrong: the right packages in the right version, a unique identity for every machine, and the right network ports open between them. kubeadm then runs its own preflight checks and refuses to continue when one of them fails. This module explains each of these steps and what the checks test.

Keep one sentence in mind: **a port number or a version is a fact that some component declares, and you can read the declaration instead of remembering the number.** You will read the ports that the control plane components of the playground cluster use from their static pod definitions, compare them with the documented defaults, and record them.

The module has two parts. **Packages And Host Identity** explains what kubeadm, kubelet and kubectl each do, how to install and pin them, and why each node needs a unique hostname, MAC address and `product_uuid`. **Ports And Preflight Checks** lists the ports that control plane and worker nodes need, shows how to read them from the cluster, and explains `kubeadm init phase preflight` and `--ignore-preflight-errors`.

## Learning objectives

After this module you can:

- Explain the role of kubeadm, kubelet and kubectl and pin their package versions.
- Check that hostname, MAC address and `product_uuid` are unique across nodes.
- Name the ports that control plane and worker nodes need and the component that uses each.
- Read the ports of the control plane components from their static pods.
- Run the kubeadm preflight phase and explain when `--ignore-preflight-errors` is acceptable.

## Before you start

You need Kubernetes basics: nodes, pods, namespaces, ConfigMaps, and the commands `kubectl get`, `kubectl apply` and `kubectl describe`. You do not need to install packages on a host.

Your playground is a single-node `kind` cluster running Kubernetes 1.35, built by kubeadm.

| Object | What it is |
| --- | --- |
| Static pods in `kube-system` | `kube-apiserver`, `etcd`, `kube-scheduler` and `kube-controller-manager`, each with the node name as suffix |
| Node | One control plane node with its kubelet port and identifiers in the status |
| ConfigMap `control-plane-ports` in `starfleet` | An empty record with the keys you fill in |

`kubectl` already points at the playground cluster, as the cluster administrator.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
