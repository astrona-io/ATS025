---
draft: true
exam_objectives:
- Prepare underlying infrastructure for installing a Kubernetes cluster
---
# Summary

A node needs more than packages before kubeadm can build a cluster. The kernel must allow the traffic the cluster network sends, the memory must be arranged the way the kubelet expects, and two programs that manage control groups must use the same driver.

Kernel modules and kernel settings change only the running system until you write them to files that the system reads at boot. The `overlay` module supports the layered file system that container images use. The `br_netfilter` module and the bridge settings make traffic that crosses a Linux bridge visible to the packet filter. The `net.ipv4.ip_forward` setting lets the kernel route packets between interfaces, and kubeadm checks it before it starts.

By default the kubelet does not start when swap is on, because memory limits are hard to enforce with swap. You either turn swap off or set `failSwapOn: false` and keep the default `NoSwap` behavior, which keeps pods away from swap.

Control groups limit and count the resources of a process. The kubelet and the container runtime each create them, through either the `systemd` driver or the `cgroupfs` driver, and the two must use the same one. On a host that runs systemd and cgroup version 2, the `systemd` driver is the recommended choice. In containerd, the matching setting is `SystemdCgroup = true`.

kubeadm stores the kubelet configuration in the `kubelet-config` ConfigMap in the `kube-system` namespace and writes it to a file on each node. The node object reports the runtime version, kubelet version, kernel version and operating system image, so you can verify a host from the API.

The key facts to remember are these:

- Persist kernel modules and sysctl values in files, or they vanish at reboot.
- `failSwapOn` defaults to true, so swap stops the kubelet.
- The kubelet and the runtime need the same cgroup driver.
- The `kubelet-config` ConfigMap and the node status are the places to read host facts from the API.

<!-- astrona:playground:destroy -->
