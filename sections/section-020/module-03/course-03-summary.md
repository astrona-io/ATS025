---
draft: true
exam_objectives:
- Prepare underlying infrastructure for installing a Kubernetes cluster
---
# Summary

Before kubeadm can build a cluster, each machine needs the right software, a unique identity and open ports for the components that run on it. Preflight checks test these conditions and stop the installation before it changes the host.

kubeadm creates the cluster, the kubelet runs on every node and starts pods, and kubectl is the client that talks to the API server. The three packages come from a repository for one minor version, and holding them stops a routine system update from moving a node to a version the cluster does not support. The kubelet restarts every few seconds until kubeadm gives it a configuration, and that is normal.

Kubernetes identifies a node by its hostname and uses its MAC address and `product_uuid` as identity values. Machines cloned from one image can share them, and duplicates can make the installation fail.

The control plane listens on the API server port 6443, on the etcd ports 2379 and 2380, on the kubelet port 10250, and on the scheduler and controller manager ports 10259 and 10257. Worker nodes need the kubelet port, the kube-proxy port 10256 and the NodePort range 30000 to 32767. All of these defaults can be changed, and when they are, the new ports must be open instead. The cluster itself declares the ports in the static pod definitions of the control plane components, so you can read the real values.

The preflight phase checks the system state: the operating system, the container runtime endpoint, the user, the hostname, the kubelet version, swap, the ports and the manifests directory. Some checks produce warnings and others errors. The option that downgrades errors to warnings exists for a known and accepted condition, and using `all` hides every problem.

The key facts to remember are these:

- Hold the three packages so updates do not change versions.
- Hostname, MAC address and `product_uuid` must be unique.
- Open the ports the topology needs, not every port.
- Ignore a named preflight error only when you understand it.

<!-- astrona:playground:destroy -->
