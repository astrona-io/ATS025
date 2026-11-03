---
draft: true
exam_objectives:
- Understand CRDs, install and configure operators
---
# Overview: Installing And Configuring An Operator (Playground)

This is a playground, not a lab. It starts a cluster with a stand-in operator installed and then waits. There is no task, no `astrona submit` and no pass or fail. Read, change, break and start over.

## What is in the box

A `kind` cluster that runs Kubernetes 1.35 with one node. `kubectl` already points at it, as the cluster administrator. The operator is a container that only sleeps, so it never changes any object. The wiring around it is complete.

| Item | What is in it |
| --- | --- |
| `beacon-system` | The Deployment, the ServiceAccount `beacon-operator` |
| `starfleet` | An empty namespace for custom resources |
| cluster scope | The CRD `beacons.training.astrona.io`, the ClusterRole and the ClusterRoleBinding `beacon-operator` |

## Practice tasks

- Read the ClusterRole and explain why each rule exists.
- Run `kubectl auth can-i --as=system:serviceaccount:beacon-system:beacon-operator` for different verbs and resources, and find one answer that is `no`.
- Remove the `beacons/status` resource from the ClusterRole and check what the identity can no longer do.
- Delete the ClusterRoleBinding and watch the answers of `can-i` change.
- Create a `Beacon` with a finalizer, delete it, read `deletionTimestamp` and remove the finalizer by hand.
- Scale the Deployment to two replicas and read the Lease holder.
- List the custom resources before you delete the CRD, then delete the CRD in a throwaway cluster and list again.
