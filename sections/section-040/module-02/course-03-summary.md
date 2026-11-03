---
draft: true
exam_objectives:
- Manage the lifecycle of Kubernetes clusters
---
# Summary

A kubeadm cluster upgrade is a fixed procedure, not a single command. kubeadm moves the control plane one minor version at a time, and patch versions of the same minor can be skipped. Each minor release migrates data and configuration only from the minor release before it, so a jump over a minor version is not supported.

`kubeadm upgrade plan` only reads the cluster and prints what would change. `kubeadm upgrade apply` runs on the first control plane node. It backs up the static pod manifests and the etcd data, writes new manifests for the control plane components, updates the stored configuration and upgrades the CoreDNS and kube-proxy add-ons. `kubeadm upgrade node` runs on every other node and uses the configuration that the first node stored.

kubeadm does not upgrade the kubelet. The kubelet is a system service from a package. You drain the node, upgrade the package, restart the service and uncordon the node. The node status shows the new kubelet version only after the restart.

The version skew policy sets the limit for the time between steps. The API server is the reference and nothing except kubectl may be newer than it. The controller manager and the scheduler may be one minor version behind. The kubelet and kube-proxy may be three minor versions behind. kubectl may be one minor version newer or older. Instances of a highly available API server may differ by one minor version.

You can read every version from the API: the image tag of a control plane static pod, the image of the kube-proxy DaemonSet, the kubelet version in the node status, and the `kubernetesVersion` field in the stored `ClusterConfiguration`.

The key facts to remember are these:

- Upgrade one minor version at a time, control plane first, then each node.
- Run `kubeadm upgrade apply` once, and `kubeadm upgrade node` everywhere else.
- Upgrading the control plane moves the supported kubelet range up, so old workers have a deadline.
- Count the skew in minor versions, never in patch versions.

<!-- astrona:playground:destroy -->
