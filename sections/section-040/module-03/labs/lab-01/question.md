---
draft: true
exam_objectives:
- Manage the lifecycle of Kubernetes clusters
---
# Question

Solve this question on: `terminal`

The starfleet platform team prepares a recovery plan for the control plane. An earlier plan left the ConfigMap `etcd-recovery` in the `starfleet` namespace, and its values are stale. Do not log in to the node. Use the Kubernetes API and `kubectl exec` in the etcd pod.

1. Read the flags of the etcd static pod in `kube-system`. Set `dataDir` to `--data-dir`, `memberName` to `--name`, `trustedCaFile` to `--trusted-ca-file` and `peerUrl` to `--initial-advertise-peer-urls`.

2. Read the volumes of the same pod. Set `dataHostPath` to the host path of the volume `etcd-data` and `certHostPath` to the host path of the volume `etcd-certs`.

3. Take a snapshot of the live etcd with `etcdctl` and save it as `/tmp/recovery-snapshot.db` inside the etcd pod. Use the endpoint `https://127.0.0.1:2379` and the kubeadm health check client certificate.

4. Check the snapshot with `etcdutl`. Set `snapshotRevision` and `snapshotTotalKeys` to the revision and the key count that the check reports.

5. Keep the ConfigMap name and namespace, and keep all eight keys. Do not restore over the live data directory and do not change the etcd pod.

Check your work with `kubectl -n starfleet get configmap etcd-recovery -o yaml`. `kubectl` already points at the cluster as the cluster administrator.
