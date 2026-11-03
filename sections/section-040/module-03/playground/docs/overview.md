# Overview: etcd Restore And Recovery (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Read, change, break, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35, built by kubeadm. `kubectl` is already pointed at it, as the cluster administrator. etcd runs as a static pod, and the pod image holds `etcdctl` and `etcdutl`.

  | Object | What is in it |
  | --- | --- |
  | Pod `etcd-<node name>` in `kube-system` | The etcd static pod, with the flags and volumes that kubeadm sets |
  | ConfigMap `etcd-recovery` in `starfleet` | Eight keys, each set to `unset` |
  | Deployment `probe` in `starfleet` | Two replicas of a small workload that you can delete and compare with a snapshot |

## Helpers

Paste these once in each new terminal. `etcd_pod` prints the name of the etcd pod. `etcd_exec` runs a command in it.

```sh
etcd_pod() {
  kubectl -n kube-system get pod -l component=etcd -o jsonpath='{.items[0].metadata.name}'
}
etcd_exec() {
  kubectl -n kube-system exec "$(etcd_pod)" -- "$@"
}
```

Use them like this: `etcd_exec etcdutl snapshot status /tmp/playground-snapshot.db --write-out=table`.

## Practice tasks

- Take a snapshot with `etcd_exec etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt --key=/etc/kubernetes/pki/etcd/healthcheck-client.key snapshot save /tmp/playground-snapshot.db`, and check it with `etcdutl snapshot status`.
- Run the snapshot command again without the certificate options and read the error.
- Delete the `probe` Deployment, then restore the snapshot into a scratch directory with `etcd_exec etcdutl snapshot restore /tmp/playground-snapshot.db --data-dir /tmp/restored-etcd`. The live cluster does not use that directory, so the Deployment stays deleted. Say what the manifest would have to change for etcd to use it.
- Run the same restore command a second time and explain why it fails.
- Read the flags and volumes of the etcd pod and fill `etcd-recovery`.
- Inside the node container, run `docker exec astro-ats-025-playground-040-03-control-plane ls /etc/kubernetes/manifests` (use `podman exec` with Podman) and name the files that the kubelet watches.
