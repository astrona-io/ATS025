---
draft: true
exam_objectives:
- Implement and configure a highly-available control plane
---
# Implement and configure a highly-available control plane

Two datastore members in a three-member cluster can maintain quorum, but one cannot. Adding an API load balancer does not change that consensus requirement.

The explanations identify the responsible components, compare intended and observed state, and work through the decisions needed to preserve the requirement. The section has three modules. The first reasons about stable API access and datastore quorum. The second covers control plane topology with kubeadm: stacked and external etcd, the control plane endpoint, quorum and member operations, read from a live cluster. The third covers how the API server reports health, how the scheduler and the controller manager elect a leader with a Lease, and what stops while no leader exists. Every module has a playground and a graded lab, and the section closes with a capstone lab and a knowledge check.

Each module begins with its goals and ends with a summary.

## Modules

1. Resilient Control-Plane Topology
2. Control Plane Topology With kubeadm
3. Leader Election, Health Endpoints And Failure Behavior

## Learning Outcomes

- Explain stable API access and backend health.
- Compare stacked and external datastore topology.
- Calculate majority quorum and failure tolerance.
- Distinguish management-plane from application availability.
- Read the etcd topology, the control plane endpoint and the member count from a running kubeadm cluster.
- Describe the steps that add and remove a control-plane node and its etcd member.
- Choose the API server health path that a load balancer should check.
- Read the Leases of the scheduler and the controller manager and estimate a failover.
- Give a controller the smallest permissions that leader election needs.
