# Overview: kubeadm Upgrade Workflow And Version Skew (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Read, change, break, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35, built by kubeadm. `kubectl` is already pointed at it, as the cluster administrator. The node is a container, so you cannot run `kubeadm upgrade` here, but you can read everything an upgrade starts from.

  | Object | What is in it |
  | --- | --- |
  | Static pods in `kube-system` | `kube-apiserver`, `kube-controller-manager`, `kube-scheduler` and `etcd`, each with its version in the image tag |
  | DaemonSet `kube-proxy` in `kube-system` | The kube-proxy that runs on every node |
  | ConfigMap `kubeadm-config` in `kube-system` | The stored `ClusterConfiguration`, with `kubernetesVersion` |
  | ConfigMap `upgrade-review` in `starfleet` | Nine keys, each set to `unset` |

## Helpers

Paste these once in each new terminal. `image_tag` prints the version tag of a control plane static pod. `minor_of` prints the minor number of a version.

```sh
image_tag() {
  kubectl -n kube-system get pod -l "component=$1" -o jsonpath='{.items[0].spec.containers[0].image}' | sed 's/@.*//; s/.*://'
}
minor_of() {
  printf '%s\n' "$1" | sed -n 's/^v\{0,1\}1\.\([0-9][0-9]*\).*/\1/p'
}
```

Use them like this: `image_tag kube-apiserver`, `minor_of "$(image_tag kube-scheduler)"`.

## Practice tasks

- Print the version of each control plane component and of the kube-proxy, and say whether all are the same.
- Compute the oldest supported kubelet minor and the next upgrade minor for this cluster, and fill them into `upgrade-review`.
- Decide whether a kubelet at `v1.31.4`, one at `v1.33.0` and one at `v1.36.0` is supported with this API server.
- Find which pods in `kube-system` are static pods by reading the annotation `kubernetes.io/config.source`.
- Read the node labels and say which node would get `kubeadm upgrade apply` and which would get `kubeadm upgrade node`.
- Print `kubectl version` and say what the client and server minors tell you about kubectl skew.
