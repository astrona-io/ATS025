---
draft: true
exam_objectives:
- Understand extension interfaces (CNI, CSI, CRI, etc.)
---
# Pod Networking Through CNI

Kubernetes does not give a pod its network address by itself. A plugin that follows the Container Network Interface (CNI) does that work on every node, and the plugin also decides whether a NetworkPolicy has any effect. When a pod stays in `ContainerCreating` or a policy seems to do nothing, you must know which component is responsible before you change anything. This module explains that split.

Keep one idea in mind: **the Kubernetes API stores the desired network objects, and the CNI plugin on each node makes them real.** You read the addresses and objects that the API shows, and you test what a policy does.

The module has three parts. The first part follows the call chain from the kubelet through the container runtime to the CNI plugin when a pod starts. The second part covers pod addresses, the address ranges of the cluster, Services and DNS. The third part covers NetworkPolicy and the question of who enforces it.

## Learning objectives

After this module you can:

- Name the component that creates a pod network namespace and the component that calls the CNI plugin.
- Say what the CNI operations `ADD`, `DEL` and `CHECK` do, and where the plugin configuration and binaries live on a node.
- Read the pod range of a node, a pod IP, a Service cluster IP and an EndpointSlice with `kubectl`.
- Explain what kube-proxy and CoreDNS do for a Service.
- Write a NetworkPolicy with ingress rules and explain why the CNI plugin decides whether it is enforced.

## Before you start

You need Kubernetes basics: pods, Services, namespaces, `kubectl get` and `kubectl apply`, and how to read YAML.

Your playground runs Kubernetes 1.35 with one node:

| Item | What is in it |
| --- | --- |
| `starfleet` | The `probe` Deployment with two pods that listen on TCP 8080, the Service `probe`, and the pod `shuttle` |
| `outpost` | The pod `drifter` |
| policies | No NetworkPolicy yet |

`kubectl` already points at the playground cluster, as the cluster administrator.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
