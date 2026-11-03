---
draft: true
exam_objectives:
- Implement and configure a highly-available control plane
---
# Question

Solve this question on: `terminal`

The starfleet team wants to move its mission controller to a highly available control plane. Management asks for a written review of the current cluster, a verdict on a new etcd proposal, and a controller that is ready for leader election. The namespaces `starfleet` and `mission-system` exist.

Part A: review the live control plane.

The ConfigMap `ha-report` in `starfleet` exists, but every value is `unknown`. Fill these keys with values that you read from the cluster:

1. `controlPlaneEndpoint`: the endpoint in the kubeadm `ClusterConfiguration`.
2. `etcdTopology`: `stacked` or `external`, as the `ClusterConfiguration` declares.
3. `etcdMembers`, `quorum` and `faultTolerance`: the number of etcd members, the quorum and the number of members that can fail.
4. `schedulerLeader` and `controllerManagerLeader`: the current holders of the Leases `kube-scheduler` and `kube-controller-manager` in `kube-system`.

Part B: judge the proposal.

5. The ConfigMap `ha-proposal` in `starfleet` asks for a number of etcd members. Record `proposalQuorum` and `proposalTolerance` for that number.
6. Record `proposalOddMembers`: the smallest odd number of members that tolerates as many failures as the proposal.

Part C: the verdict.

7. Record `verdict`. Use `single-point-of-failure` when the live fault tolerance is 0. Otherwise use `tolerates-N-failures`, where N is the fault tolerance.

Part D: prepare the controller.

8. The ServiceAccount `mission-controller` in `mission-system` is bound to the ClusterRole `edit` by the RoleBinding `mission-edit`. Remove that binding.
9. Give `mission-controller`, in `mission-system` only, the permissions `get`, `create` and `update` on `leases` in the group `coordination.k8s.io`, with a Role and a RoleBinding and no wildcards. It must not be able to delete leases, read Secrets or update leases in `kube-system`.

Do not change `ha-proposal` and do not edit objects in `kube-system`. `kubectl` already points at the cluster as the cluster administrator.
