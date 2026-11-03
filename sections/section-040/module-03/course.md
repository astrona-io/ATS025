---
draft: true
exam_objectives:
- Manage the lifecycle of Kubernetes clusters
---
# etcd Restore And Recovery

Every object in a Kubernetes cluster lives in etcd. If the control plane node loses its disk, or someone deletes a Namespace by mistake, a snapshot of etcd is the only way back to an earlier state. A snapshot that nobody has checked, or a restore that nobody has practised, gives false safety. This module teaches how to take a snapshot, how to prove that it is good and how a restore changes the node.

Keep one sentence in mind: **a restore does not repair the running etcd, it creates a new data directory from the snapshot, and the etcd static pod must be pointed at that directory.** You will read how kubeadm starts etcd, take a real snapshot, inspect it and restore it into a separate directory without touching the live cluster.

The module has two parts. **Taking And Checking An etcd Snapshot** explains how kubeadm runs etcd, which certificates and endpoints `etcdctl` needs and what `etcdutl snapshot status` proves. **Restoring A Snapshot And Recovering The Control Plane** explains what `etcdutl snapshot restore` creates, how the static pod manifest points to the new directory and how to check the cluster afterwards.

## Learning objectives

After this module you can:

- Read the etcd flags, certificate paths and data directory from the etcd static pod.
- Take a snapshot with `etcdctl snapshot save` and the three connection options that it needs.
- Check a snapshot with `etcdutl snapshot status` and say what the revision and key count mean.
- Explain what `etcdutl snapshot restore` creates and which manifest field makes etcd use it.
- List the checks to run after a restore, and the changes that a restore does not undo.

## Before you start

You need Kubernetes basics: static pods, namespaces, ConfigMaps and `kubectl exec`. You do not need to restore the playground cluster. The playground cluster runs etcd as a kubeadm static pod, so you can take and check real snapshots and restore one into a scratch directory.

Your playground is a single-node `kind` cluster running Kubernetes 1.35.

| Object | What it is |
| --- | --- |
| Pod `etcd-<node name>` in `kube-system` | The etcd static pod, with `etcdctl` and `etcdutl` inside |
| ConfigMap `etcd-recovery` in `starfleet` | An empty record with the keys you can fill in |
| Deployment `probe` in `starfleet` | A workload that you can delete and compare against a snapshot |

`kubectl` already points at the playground cluster, as the cluster administrator.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
