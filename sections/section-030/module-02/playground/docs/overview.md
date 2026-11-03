---
draft: true
exam_objectives:
- Create and manage Kubernetes clusters using kubeadm
---
# Overview: kubeadm Configuration Files And Init Phases (Playground)

This is a playground, not a lab. It starts a cluster that kubeadm created and then waits. There is no task, no `astrona submit` and no pass or fail. Read, change, break and start over.

## What is in the box

A `kind` cluster that runs Kubernetes 1.35 with one control-plane node and one worker node. `kubectl` already points at it, as the cluster administrator. The nodes are containers named `astro-ats-025-playground-030-02-control-plane` and `astro-ats-025-playground-030-02-worker`.

| Item | What is in it |
| --- | --- |
| `kube-system` | The ConfigMaps `kubeadm-config` and `kubelet-config` that kubeadm wrote |
| `kube-public` | The ConfigMap `cluster-info` that joining nodes read |
| `starfleet` | A `probe` Deployment and the ConfigMap `kubeadm-plan`, which holds a draft kubeadm file with mistakes |
| `outpost` | An empty namespace |

## Helpers

Paste these once in each new terminal. `node_exec` runs a command inside the control-plane node container. With Podman, replace `docker` with `podman`.

```sh
node_exec() {
  docker exec astro-ats-025-playground-030-02-control-plane "$@"
}
cluster_config() {
  kubectl -n kube-system get configmap kubeadm-config -o jsonpath='{.data.ClusterConfiguration}'
}
```

## Practice tasks

- Run `node_exec kubeadm config print init-defaults` and find the fields `bootstrapTokens`, `localAPIEndpoint` and `networking`.
- Run `cluster_config` and write down `kubernetesVersion`, `clusterName`, `podSubnet` and `serviceSubnet`.
- Compare the output of `cluster_config` with the draft file in the `kubeadm-plan` ConfigMap. List every mistake you find in the draft.
- Run `node_exec ls /etc/kubernetes/manifests` and match each file to a pod in `kube-system`.
- Print the `kubelet-config` ConfigMap and find `clusterDNS` and `cgroupDriver`.
- Read `cluster-info` in `kube-public` and find the `server:` line.
