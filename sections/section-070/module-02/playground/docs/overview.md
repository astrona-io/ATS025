---
draft: true
exam_objectives:
- Understand extension interfaces (CNI, CSI, CRI, etc.)
---
# Overview: Pod Networking Through CNI (Playground)

This is a playground, not a lab. It starts a clean cluster and then waits. There is no task, no `astrona submit` and no pass or fail. Read, change, break and start over.

## What is in the box

A `kind` cluster that runs Kubernetes 1.35 with one node. `kubectl` already points at it, as the cluster administrator.

| Item | What is in it |
| --- | --- |
| `starfleet` | The `probe` Deployment (two pods, listening on TCP 8080), the Service `probe` on port 80, and the pod `shuttle` |
| `outpost` | The pod `drifter` |
| policies | No NetworkPolicy exists |

## Practice tasks

- Read the container runtime, the node address and the pod range with `kubectl get nodes -o wide` and a `jsonpath` query for `spec.podCIDR`.
- List the pods with `-o wide` and check that every pod address lies inside the pod range of the node.
- Read the cluster IP of the `probe` Service and the addresses in its EndpointSlice.
- Send a request from `shuttle` to `http://probe` with `wget`, and read `/etc/resolv.conf` inside the pod.
- Look at the CNI configuration directory of the node with `kubectl debug node/<name>`.
- Scale `probe` to three replicas and watch the EndpointSlice change.
- Apply a default-deny ingress policy, then an allow policy for `shuttle`, and compare the requests from `shuttle` and `drifter`.
- Change the `from` entry of a policy between one combined entry and two separate entries, and read the result with `kubectl describe networkpolicy`.
