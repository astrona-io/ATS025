---
draft: true
exam_objectives:
- Understand extension interfaces (CNI, CSI, CRI, etc.)
---
# Question

Solve this question on: `terminal`

The starfleet platform team runs a `probe` Deployment with two pods and a `probe` Service in the `starfleet` namespace. The pods listen on TCP port 8080. A `shuttle` pod runs in `starfleet` and a `drifter` pod runs in `outpost`. No NetworkPolicy exists yet. The cluster has one node.

Part A: record the network facts.

1. Create the ConfigMap `network-report` in `starfleet` with these keys, and read every value from the cluster instead of typing it from memory:
   - `podCIDR`: the pod address range of the node (`spec.podCIDR`).
   - `shuttleIP`: the pod IP address of the `shuttle` pod.
   - `probeClusterIP`: the cluster IP address of the `probe` Service.
   - `readyEndpoints`: the number of ready endpoints that the EndpointSlice of the `probe` Service lists.
   - `dnsName`: the fully qualified DNS name of the `probe` Service inside the cluster.

Part B: restrict access.

2. Create the NetworkPolicy `default-deny-ingress` in `starfleet`. It selects every pod in the namespace and denies all ingress traffic.
3. Create the NetworkPolicy `probe-ingress` in `starfleet`. It selects the pods labelled `app=probe` and allows ingress only from the pods labelled `app=shuttle` in the same namespace, only on TCP port 8080.

Both policies control ingress only. Do not create an egress policy and do not change the `probe` Deployment. The grader reads the policy objects through the Kubernetes API. `kubectl` already points at the cluster as the cluster administrator.
