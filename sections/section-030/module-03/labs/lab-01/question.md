---
draft: true
exam_objectives:
- Create and manage Kubernetes clusters using kubeadm
---
# Question

Solve this question on: `terminal`

The starfleet platform team documents which certificate and key files each control plane component uses. The ConfigMap `pki-map` in the `starfleet` namespace holds an out-of-date list. Nobody may log in to the node, so you must take every path from the static pods of the control plane in the `kube-system` namespace.

Set these eight keys in `pki-map` to the file path that the pod declares in its command line:

1. `apiserverServingCert`: the `--tls-cert-file` flag of the `kube-apiserver` pod.
2. `apiserverKubeletClientCert`: the `--kubelet-client-certificate` flag of the `kube-apiserver` pod.
3. `apiserverEtcdClientCert`: the `--etcd-certfile` flag of the `kube-apiserver` pod.
4. `saPublicKey`: the `--service-account-key-file` flag of the `kube-apiserver` pod.
5. `saSigningKey`: the `--service-account-private-key-file` flag of the `kube-controller-manager` pod.
6. `clusterSigningCert`: the `--cluster-signing-cert-file` flag of the `kube-controller-manager` pod.
7. `etcdPeerCert`: the `--peer-cert-file` flag of the `etcd` pod.
8. `schedulerKubeconfig`: the `--kubeconfig` flag of the `kube-scheduler` pod.

Keep the ConfigMap name and namespace. Do not edit any pod or other object in `kube-system`. `kubectl` already points at the cluster as the cluster administrator.
