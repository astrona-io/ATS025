---
draft: true
exam_objectives:
- Implement and configure a highly-available control plane
---
# Question

Solve this question on: `terminal`

The starfleet platform team is about to run a second copy of its `scout` controller, so the controller needs leader election. Before that, the team wants a record of how the control plane elects its own leaders, and the controller must get the smallest permissions that leader election needs.

Part A: the record.

The ConfigMap `control-plane-health` in the `starfleet` namespace exists, but every value is `unknown`. Fill every key with a value that you read from the cluster:

1. `schedulerLeader` and `controllerManagerLeader`: the current holders of the Leases `kube-scheduler` and `kube-controller-manager` in `kube-system`.
2. `leaseDurationSeconds`: the lease duration of the `kube-scheduler` Lease.
3. `leaderElectFlag`: the value of the `--leader-elect` flag in the scheduler command.
4. `apiServerLivenessPath` and `apiServerReadinessPath`: the HTTP paths of the liveness and readiness probes of the `kube-apiserver` pod.
5. `apiServerEndpointCount`: the number of addresses in the EndpointSlice of the `kubernetes` Service in the `default` namespace.

Part B: the permissions.

6. The ServiceAccount `scout-controller` in `starfleet` is bound to the ClusterRole `edit` by the RoleBinding `scout-edit`. Remove that binding.
7. Give `scout-controller`, in `starfleet` only, the permissions `get`, `create` and `update` on `leases` in the group `coordination.k8s.io`. Use a Role and a RoleBinding, no wildcards. The ServiceAccount must not be able to delete leases, read Secrets or update leases in `kube-system`.

Do not delete Leases and do not edit objects in `kube-system`. `kubectl` already points at the cluster as the cluster administrator.
