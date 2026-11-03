---
draft: true
exam_objectives:
- Implement and configure a highly-available control plane
---
# Question

Solve this question on: `terminal`

The starfleet platform team plans to make its control plane highly available, and it needs a written review of the cluster as it is today. The ConfigMap `topology-review` in the `starfleet` namespace already exists, but every value is `unknown`. A second ConfigMap, `ha-proposal`, holds the team's idea of how many etcd members to run.

Fill every key of `topology-review` with a value that you read from the cluster:

1. `controlPlaneEndpoint`: the value of `controlPlaneEndpoint` in the kubeadm `ClusterConfiguration`.
2. `etcdTopology`: `stacked` when the `ClusterConfiguration` uses a local etcd, or `external` when it points at an external etcd.
3. `controlPlaneNodes`: the number of nodes that carry the control-plane label.
4. `etcdMembers`: the number of etcd static pods in `kube-system`.
5. `etcdClientUrl`: the client URL that kubeadm records as an annotation on the etcd pod.
6. `quorum` and `faultTolerance`: the etcd quorum and the number of members that can fail, calculated from `etcdMembers`.
7. `proposalQuorum` and `proposalTolerance`: the same two values for the number in `ha-proposal`.
8. `proposalOddMembers`: the smallest odd number of members that has the same fault tolerance as the proposal.

Do not change `ha-proposal`, `kubeadm-config` or any object in `kube-system`. `kubectl` already points at the cluster as the cluster administrator.
