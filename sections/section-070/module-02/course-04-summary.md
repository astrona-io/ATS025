---
draft: true
exam_objectives:
- Understand extension interfaces (CNI, CSI, CRI, etc.)
---
# Summary

A pod gets its network through a fixed chain on the node. The kubelet asks the container runtime for a pod sandbox through the Container Runtime Interface. The runtime creates the network namespace and calls the Container Network Interface plugin with the `ADD` operation. The plugin reads its configuration from a directory on the node, assigns an address through its address management plugin and returns it. The runtime reports the sandbox as ready only after that, so a broken plugin leaves pods in `ContainerCreating` and makes the node report that it is not ready.

The Kubernetes network model says that every pod has its own IP address and that pods reach each other without address translation. Each node receives a pod range in `spec.podCIDR` from the controller manager, and most plugins hand out addresses from it. Pod addresses change when pods are replaced. A Service gives a stable cluster IP from a separate range, the EndpointSlice controller lists the ready pods behind it, and kube-proxy or a replacement writes the rules on each node that rewrite the cluster IP to a pod address. CoreDNS resolves Service names, and the kubelet configures every pod to use it.

A NetworkPolicy limits traffic between pods. The API server only stores it. A component of the CNI plugin enforces it, so the same object can work in one cluster and have no effect in another. A policy selects pods and a direction, and everything not allowed is then closed. Rules only add allowed paths. Two selectors in one `from` entry mean AND, and two entries mean OR. The policy names the container port, because the Service rewrite happens first.

Key facts:

- The runtime, not the kubelet, calls the CNI plugin.
- `spec.podCIDR`, the cluster IP, the endpoints and the DNS name each have a different owner.
- A successful `kubectl apply` of a NetworkPolicy is not proof of enforcement.

<!-- astrona:playground:destroy -->
