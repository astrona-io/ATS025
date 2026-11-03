# Overview: Packages, Ports And kubeadm Preflight Checks (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Read, change, break, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35, built by kubeadm. `kubectl` is already pointed at it, as the cluster administrator.

  | Object | What is in it |
  | --- | --- |
  | Static pods in `kube-system` | `kube-apiserver`, `etcd`, `kube-scheduler` and `kube-controller-manager`, each named with the node name as suffix and labelled `component` and `tier=control-plane` |
  | Node | One control plane node. Its status holds `daemonEndpoints`, `systemUUID` and `machineID` |
  | ConfigMap `control-plane-ports` in `starfleet` | Six keys, each set to `unset` |

## Helpers

Paste these once in each new terminal. `component_args` prints the command line of a control plane component, one argument per line. `probe_port` prints the liveness probe port of a component.

```sh
component_args() {
  kubectl -n kube-system get pod -l "component=$1" -o jsonpath='{range .items[0].spec.containers[0].command[*]}{@}{"\n"}{end}'
}
probe_port() {
  kubectl -n kube-system get pod -l "component=$1" -o jsonpath='{.items[0].spec.containers[0].livenessProbe.httpGet.port}{"\n"}'
}
```

Use them like this: `component_args kube-apiserver`, `probe_port kube-scheduler`.

## Practice tasks

- Print the arguments of all four control plane components and list every flag that names an address or a port.
- Find the flag that sets the service address range of the API server and the flag that sets the pod address range of the controller manager.
- Fill `control-plane-ports` with the six ports and compare them with the documented defaults.
- Check whether the API server sets `--service-node-port-range`. If it does not, say which range applies.
- Read the `systemUUID` and `machineID` of the node and say what you would compare on a cluster with more nodes.
