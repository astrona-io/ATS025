---
draft: true
exam_objectives:
- Implement and configure a highly-available control plane
---
# Overview: Control Plane Topology With kubeadm (Playground)

This is a playground, not a lab. It starts a clean cluster and then waits. There is no task, no `astrona submit` and no pass or fail. Read, change, break and start over.

## What is in the box

A `kind` cluster that runs Kubernetes 1.35 with one control-plane node. kind builds the cluster with kubeadm, so the kubeadm objects exist. `kubectl` already points at the cluster, as the cluster administrator.

| Item | What is in it |
| --- | --- |
| `kube-system` | The static pods of the control plane and the ConfigMap `kubeadm-config` |
| `starfleet` | An empty namespace for your own notes and objects |
| etcd | One stacked member, so the quorum is 1 and the fault tolerance is 0 |

The cluster has only one control-plane node. It shows what a stacked topology looks like, but it cannot show a failure that a three-member cluster survives.

## Practice tasks

- Read the `ClusterConfiguration` in `kubeadm-config` and find `controlPlaneEndpoint` and the `etcd` block.
- List the control-plane nodes with their label and the etcd pods with their label.
- Read the annotations of the etcd pod and the API server pod that kubeadm sets.
- Run `etcdctl member list` and `etcdctl endpoint status` inside the etcd pod.
- Calculate the quorum and the fault tolerance from the member count with shell arithmetic.
- Compute the quorum for 2, 3, 4, 5 and 6 members and compare the fault tolerance of each.
- Write the `ClusterConfiguration` block that would point kubeadm at an external etcd. Do not apply it: it is for a new host.
