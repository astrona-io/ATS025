# Overview: Kernel Modules, sysctl, Swap And The cgroup Driver (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Read, change, break, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35, built by kubeadm. `kubectl` is already pointed at it, as the cluster administrator.

  | Object | What is in it |
  | --- | --- |
  | Node | One control plane node. Its `status.nodeInfo` holds the kernel version, operating system image, runtime version and kubelet version |
  | ConfigMap `kubelet-config` in `kube-system` | The `KubeletConfiguration` that kubeadm uploaded |
  | ConfigMap `host-readiness` in `starfleet` | Six keys, each set to `unset` |

## Helpers

Paste these once in each new terminal. `kubelet_setting` prints one field of the stored kubelet configuration. `node_fact` prints one field of `status.nodeInfo` for the first node.

```sh
kubelet_setting() {
  kubectl -n kube-system get configmap kubelet-config -o jsonpath='{.data.kubelet}' | grep -E "^$1:"
}
node_fact() {
  kubectl get nodes -o jsonpath="{.items[0].status.nodeInfo.$1}{\"\n\"}"
}
```

Use them like this: `kubelet_setting cgroupDriver`, `node_fact kernelVersion`.

## Practice tasks

- Print every field of the stored `KubeletConfiguration` that mentions `cgroup` and name what each one controls.
- Print the four node facts and fill `host-readiness` with them.
- Run `sysctl net.ipv4.ip_forward` inside the node container with `docker exec astro-ats-025-playground-020-02-control-plane` (use `podman exec` with Podman) and decide whether kubeadm would accept the value.
- Find out whether the node reports a swap capacity, and say what `failSwapOn` would have to be if it did.
- Change a value in `host-readiness` to a wrong one, then write a command that compares the record with the node and prints the differences.
