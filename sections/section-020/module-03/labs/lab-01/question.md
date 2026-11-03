---
draft: true
exam_objectives:
- Prepare underlying infrastructure for installing a Kubernetes cluster
---
# Question

Solve this question on: `terminal`

The starfleet network team prepares firewall rules for the control plane. The ConfigMap `control-plane-ports` in the `starfleet` namespace holds port numbers copied from an outdated guide, and some of them are wrong for this cluster. The team will open only the ports you record, so every value must come from the cluster itself.

1. Set `apiserver` to the port that the `kube-apiserver` static pod in `kube-system` declares.

2. Set `etcdClient` and `etcdPeer` to the ports in the listen address flags of the `etcd` static pod.

3. Set `scheduler` and `controllerManager` to the ports that the `kube-scheduler` and `kube-controller-manager` static pods declare in their health probes.

4. Set `kubelet` to the kubelet port that the node reports in its status.

Keep the ConfigMap name and namespace, keep all six keys, and write each value as a port number in quotes. Do not change any pod in `kube-system`.

Check your work with `kubectl -n starfleet get configmap control-plane-ports -o yaml` and compare each value with its source. `kubectl` already points at the cluster as the cluster administrator.
