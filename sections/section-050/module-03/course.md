---
draft: true
exam_objectives:
- Implement and configure a highly-available control plane
---
# Leader Election, Health Endpoints And Failure Behavior

A highly available control plane runs several copies of each program, but the copies do not all work the same way. Every API server answers requests at the same time. The scheduler and the controller manager must not: only one copy of each may act, and the others wait. This module shows how a load balancer finds a healthy API server, how the other programs choose a leader with a Lease object, and what stops working when each part fails.

Keep one idea in mind: **the API server is active on every node, while the scheduler and the controller manager are active on one node.** The first scales by adding copies behind a load balancer. The second fails over through a lease that the leader must renew.

The module has two parts. The first part covers the API server health endpoints, the probes that kubeadm sets, how in-cluster clients find the API servers and which certificate names matter. The second part covers leader election with Lease objects, the timing flags, the permissions that a controller needs for it, and what a failover changes.

## Learning objectives

After this module you can:

- Name the three health endpoints of the API server and say which one a load balancer should check.
- Read the probes of the `kube-apiserver` pod and the EndpointSlice of the `kubernetes` Service.
- Explain why the API server certificate must contain the control plane endpoint name.
- Read the Leases of the scheduler and the controller manager and name the current leader.
- Explain `leaseDurationSeconds`, the renew deadline and the retry period, and the worst-case time of a failover.
- Write a Role that gives a controller only the lease permissions that leader election needs.

## Before you start

You need Kubernetes basics: pods, namespaces, ServiceAccounts, Roles and `kubectl get`. You do not need to write a controller.

Your playground runs Kubernetes 1.35 with one control-plane node:

| Item | What is in it |
| --- | --- |
| `kube-system` | The control plane pods and their Leases |
| `starfleet` | An empty namespace |

`kubectl` already points at the playground cluster, as the cluster administrator. With one control-plane node, one scheduler and one controller manager are always the leader, but you can read every field that a failover would change.

## Reading order

1. API Server Endpoints And Health Checks
2. Leader Election With Leases
3. Summary

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
