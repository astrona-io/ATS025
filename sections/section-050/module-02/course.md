---
draft: true
exam_objectives:
- Implement and configure a highly-available control plane
---
# Control Plane Topology With kubeadm

A Kubernetes control plane that runs on one node stops the whole cluster when that node fails. A highly available control plane runs several copies of the API server and several members of the etcd datastore, so the cluster keeps working when one node is lost. This module shows how kubeadm builds that layout, how to read it from a running cluster, and how to calculate what it can survive.

Keep one idea in mind: **a control plane is only as available as its smallest majority.** The number of API servers decides who can answer requests. The number of etcd members decides whether the cluster can still store its state.

The module has two parts. The first part compares the stacked and the external etcd topology, and reads the kubeadm configuration that records the choice. The second part calculates etcd quorum, reads the members of a live etcd cluster, and walks through the steps that add and remove a control-plane node.

## Learning objectives

After this module you can:

- Explain the stacked and the external etcd topology and name the failure that each one adds.
- Say what `controlPlaneEndpoint` is and why kubeadm needs it before the second control-plane node joins.
- Read the topology from the `kubeadm-config` ConfigMap, the node labels and the etcd pods.
- Calculate the quorum and the fault tolerance for any number of etcd members.
- List the steps that add a control-plane node and remove an etcd member.

## Before you start

You need Kubernetes basics: pods, namespaces, `kubectl get` and how to read YAML. You do not need to run kubeadm yourself.

Your playground runs Kubernetes 1.35 with one control-plane node that kind built with kubeadm:

| Item | What is in it |
| --- | --- |
| `kube-system` | The control plane pods and the ConfigMap `kubeadm-config` |
| `starfleet` | An empty namespace |
| etcd | One member, so quorum is 1 and the fault tolerance is 0 |

`kubectl` already points at the playground cluster, as the cluster administrator. The playground has one control-plane node, so you read the real objects of a stacked cluster but you cannot remove a node to watch a failover.

## Reading order

1. Stacked And External etcd Topologies In kubeadm Clusters
2. Reading Quorum And Members From A Running Cluster
3. Summary

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
