---
draft: true
exam_objectives:
- Implement and configure a highly-available control plane
---
# Summary

The API server keeps no state of its own, so every copy is active and any copy can answer any request. High availability for the API server comes from two things: a load balancer that stops sending requests to a failed server, and a name that all clients use to reach the servers.

The API server reports its health on three paths. The liveness path says the process is alive and should not be restarted. The readiness path says the server can handle requests, including the datastore check, and it turns red when the server starts to shut down. The old combined path is deprecated. A load balancer should check readiness, because liveness stays green when the datastore is unreachable, and a plain TCP check cannot see a broken datastore connection. kubeadm sets these probes in the static pod of the API server, and in-cluster clients reach the servers through the Service named kubernetes, whose EndpointSlice lists the live addresses.

The certificate of the API server must contain every name that clients use, so the control plane endpoint name is part of the certificate. A new name needs a new certificate.

The scheduler and the controller manager must have one active copy. Each copy tries to hold a Lease in the namespace kube-system. The holder identity names the leader, the renew time shows that it is alive, and the lease duration, renew deadline and retry period decide how fast another copy takes over. With the defaults, the pause is about 15 seconds plus one retry period. During the pause, existing pods keep running, new pods stay pending and Deployments do not create replacements.

A controller that you run with several replicas uses the same mechanism and needs only get, create and update on Leases in its own namespace. A namespaced Role gives that access without touching the Leases of the control plane. Leader election lowers the chance of two active copies but is not a perfect fence, so controllers still make their actions safe to repeat.

Key facts:

- Use the readiness path for load balancer checks.
- The API server is active on every node. The scheduler and the controller manager are active on one node.
- A failover takes about the lease duration.

<!-- astrona:playground:destroy -->
