---
draft: true
exam_objectives:
- Create and manage Kubernetes clusters using kubeadm
---
# Overview: PKI Files, Bootstrap Tokens And Joining Nodes (Playground)

This is a playground, not a lab. It starts a cluster that kubeadm created and then waits. There is no task, no `astrona submit` and no pass or fail. Read, change, break and start over.

## What is in the box

A `kind` cluster that runs Kubernetes 1.35 with one control-plane node and one worker node. `kubectl` already points at it, as the cluster administrator. The nodes are containers named `astro-ats-025-playground-030-03-control-plane` and `astro-ats-025-playground-030-03-worker`.

| Item | What is in it |
| --- | --- |
| `kube-system` | Static pods of the control plane, the CNI add-on, kube-proxy and CoreDNS |
| `kube-public` | The `cluster-info` ConfigMap that joining nodes read |
| `starfleet` | A `probe` Deployment |
| every namespace | A `kube-root-ca.crt` ConfigMap that holds the cluster CA certificate |

## Helpers

Paste these once in each new terminal. `node_exec` runs a command inside the control-plane node container. With Podman, replace `docker` with `podman`.

```sh
node_exec() {
  docker exec astro-ats-025-playground-030-03-control-plane "$@"
}
ca_hash() {
  kubectl -n kube-system get configmap kube-root-ca.crt -o jsonpath='{.data.ca\.crt}' \
    | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -hex
}
```

## Practice tasks

- Run `node_exec ls -l /etc/kubernetes/pki /etc/kubernetes/pki/etcd` and match each file to a flag on a control plane pod.
- Run `node_exec kubeadm certs check-expiration` and find the certificate with the smallest residual time.
- Run `ca_hash` and compare it with the hash in the output of `node_exec kubeadm token create --print-join-command`.
- Run `node_exec kubeadm token list`, then delete the token you created with `node_exec kubeadm token delete <TOKEN-ID>`.
- Read the Secrets of type `bootstrap.kubernetes.io/token` in `kube-system` and decode the `expiration` field with `base64 -d`.
- Read the `jws-kubeconfig-...` keys of the `cluster-info` ConfigMap and explain what each one signs.
- Read the ClusterRoleBinding `kubeadm:node-autoapprove-bootstrap` and name the group it serves.
- Read the `Ready` condition of each node and the CNI DaemonSet pods in `kube-system`.
