---
draft: true
exam_objectives:
- Manage the lifecycle of Kubernetes clusters
---
# Question

Solve this question on: `terminal`

The starfleet platform team prepares the cluster for an upgrade and for a possible recovery. The cluster has a control plane node and one worker. An earlier maintenance left the worker cordoned, and left a stale ConfigMap `lifecycle-review` in the `starfleet` namespace. The Deployment `probe` in `starfleet` has pods waiting for a node. Take every value from the Kubernetes API or from the etcd pod.

1. Take a snapshot of the live etcd with `etcdctl` and save it as `/tmp/lifecycle-snapshot.db` inside the etcd pod in `kube-system`. Use the endpoint `https://127.0.0.1:2379` and the kubeadm health check client certificate. Check it with `etcdutl snapshot status`.

2. Make the worker schedulable again, and wait until the `probe` Deployment has both replicas available.

3. Fill the ConfigMap `lifecycle-review` with these ten keys:
   - `apiServerVersion`: the image tag of the kube-apiserver static pod, with the leading `v`.
   - `kubeletVersion`: the kubelet version in the node status.
   - `storedVersion`: `kubernetesVersion` in the `ClusterConfiguration` of the ConfigMap `kubeadm-config`.
   - `etcdVersion`: the image tag of the etcd static pod.
   - `oldestKubelet` and `nextMinor`: the oldest kubelet minor that the API server allows, and the minor kubeadm upgrades to next, written as `1.NN`.
   - `snapshotPath`, `snapshotRevision` and `snapshotTotalKeys`: the path of the snapshot and the revision and key count that `etcdutl` reports.
   - `workerName`: the name of the worker node.

4. Keep the ConfigMap name and namespace. Do not restore over the live etcd data and do not edit `kubeadm-config`.

Check your work with `kubectl -n starfleet get configmap lifecycle-review -o yaml`. `kubectl` already points at the cluster as the cluster administrator.
