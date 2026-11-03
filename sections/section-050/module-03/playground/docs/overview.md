---
draft: true
exam_objectives:
- Implement and configure a highly-available control plane
---
# Overview: Leader Election, Health Endpoints And Failure Behavior (Playground)

This is a playground, not a lab. It starts a clean cluster and then waits. There is no task, no `astrona submit` and no pass or fail. Read, change, break and start over.

## What is in the box

A `kind` cluster that runs Kubernetes 1.35 with one control-plane node. `kubectl` already points at the cluster, as the cluster administrator.

| Item | What is in it |
| --- | --- |
| `kube-system` | The control plane pods and the Leases of the scheduler and controller manager |
| `starfleet` | An empty namespace for your own ServiceAccounts, Roles and bindings |

With one control-plane node, one scheduler and one controller manager are always the leader. You can still read every field that a failover would change.

## Practice tasks

- Read `/livez`, `/readyz` and `/healthz` with `kubectl get --raw`, and add `?verbose`.
- Exclude one check with `?exclude=etcd` and read the result.
- Read the probes of the `kube-apiserver` pod.
- Read the Lease `kube-scheduler` twice and compare `renewTime`.
- Read the leader election flags of the scheduler and the controller manager.
- Create a ServiceAccount and a Role for leases, bind them, and test with `kubectl auth can-i --as`.
- Read the EndpointSlice of the `kubernetes` Service in the `default` namespace.
