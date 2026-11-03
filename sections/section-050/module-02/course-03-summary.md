---
draft: true
exam_objectives:
- Implement and configure a highly-available control plane
---
# Summary

A kubeadm control plane runs four programs: the API server, etcd, the scheduler and the controller manager. kubeadm starts them as static pods, and the kubelet shows each one as a mirror pod. One control-plane node is a single point of failure, so a highly available cluster adds nodes and etcd members.

In the stacked topology, every control-plane node also runs an etcd member. It needs few machines, but one node failure removes an API server and an etcd member together. In the external topology, etcd runs on separate machines that kubeadm does not manage. It separates the two failure groups and costs more machines. The `ClusterConfiguration` records the choice in the block `etcd.local` or `etcd.external`, and kubeadm keeps it in the ConfigMap `kubeadm-config`.

The control plane endpoint is the single stable address that all clients use. It points at a load balancer in front of the API servers. kubeadm needs it at the start, because the kubeconfig files and the API server certificate contain it, and a cluster that began without it cannot be converted into a highly available cluster.

etcd needs a majority of members, called the quorum, to elect a leader and commit writes. The quorum is the number of members divided by two, rounded down, plus one. Three members tolerate one failure, five tolerate two, and two or four members add no tolerance over one or three. When the quorum is lost, the API servers cannot store state, and running pods continue while all changes stop.

Joining a control-plane node uses the kubeadm join command in control-plane mode with a certificate key, and kubeadm creates the new etcd member. Removing a node needs the matching etcd member removed, with the kubeadm reset command for a healthy node or the etcdctl member remove command for a dead one. Members change one at a time, and each change is checked before the next.

Key facts:

- Quorum is the member count divided by two, rounded down, plus 1.
- Fault tolerance is the member count minus the quorum.
- Use an odd number of members.
- Set the control plane endpoint when the first node is created.

<!-- astrona:playground:destroy -->
