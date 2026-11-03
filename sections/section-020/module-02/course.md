---
draft: true
exam_objectives:
- Prepare underlying infrastructure for installing a Kubernetes cluster
---
# Kernel Modules, sysctl, Swap And The cgroup Driver

A kubeadm installation can fail on a machine that has the right packages and a working network. The cause is often a kernel setting, a swap area or a control group (cgroup) driver that does not match between two programs on the same host. This module explains each of these host settings, which program reads it and what goes wrong when it is wrong.

Keep one sentence in mind: **the kernel, the container runtime and the kubelet must agree on the same facts, and the cluster stores some of those facts where you can read them without logging in to the host.** You will read the kubelet configuration that kubeadm stored in the cluster, read the version and operating system facts that the kubelet reports for its node, and write them into a record that you can compare with the host's real state.

The module has two parts. **Kernel Modules, sysctl And Swap** explains the kernel modules and kernel settings that a node needs, how to make them survive a reboot, and why the kubelet refuses to start when swap is on. **The cgroup Driver And kubelet Configuration** explains the two cgroup drivers, the runtime setting that must match the kubelet, and where kubeadm keeps the kubelet configuration.

## Learning objectives

After this module you can:

- Name the kernel modules and sysctl settings that Kubernetes networking can depend on, and make them persistent.
- Explain what swap does to the kubelet and how `failSwapOn` changes that.
- Explain the difference between the `systemd` and `cgroupfs` cgroup drivers and why the kubelet and the runtime must use the same one.
- Read the `KubeletConfiguration` that kubeadm stores in the `kubelet-config` ConfigMap.
- Read the runtime version, kubelet version, kernel version and operating system image from the node status.

## Before you start

You need Kubernetes basics: nodes, namespaces, ConfigMaps, and the commands `kubectl get`, `kubectl apply` and `kubectl describe`. You do not need to install anything on a host.

Your playground is a single-node `kind` cluster running Kubernetes 1.35. The node is built by kubeadm, so it has the same kubelet configuration object that a real cluster has.

| Object | What it is |
| --- | --- |
| Node | One control plane node that reports its kernel, operating system, runtime and kubelet version in its status |
| ConfigMap `kubelet-config` in `kube-system` | The `KubeletConfiguration` that kubeadm uploaded |
| ConfigMap `host-readiness` in `starfleet` | An empty record with the keys you fill in |

`kubectl` already points at the playground cluster, as the cluster administrator.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
