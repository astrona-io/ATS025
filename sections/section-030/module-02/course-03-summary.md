---
draft: true
exam_objectives:
- Create and manage Kubernetes clusters using kubeadm
---
# Summary

A kubeadm configuration file holds the choices that would otherwise be a long list of flags. The file is a stream of YAML documents. `InitConfiguration` describes the first node, `ClusterConfiguration` describes the whole cluster, `JoinConfiguration` describes one joining node, and `KubeletConfiguration` describes the kubelet. The API version for Kubernetes 1.35 is `kubeadm.k8s.io/v1beta4`.

The fields that decide how a cluster behaves are `kubernetesVersion`, `clusterName`, `controlPlaneEndpoint` and the `networking` block with `podSubnet`, `serviceSubnet` and `dnsDomain`. Nesting is part of the meaning: a subnet written at the wrong level is an unknown field. The control plane endpoint is the shared address of the cluster, while the advertise address belongs to one API server. Printing the defaults and validating a file show the correct names and catch mistakes before a cluster is built.

`kubeadm init` runs a fixed list of phases. The early phases write certificates, kubeconfig files and static pod manifests on the local disk, and the kubelet starts the control-plane containers from those manifests. Only after the API server answers does kubeadm create objects: the configuration ConfigMaps, the control-plane label and taint, the first bootstrap token with its discovery ConfigMap, and the CoreDNS and kube-proxy add-ons. A failure in an early phase therefore leaves files but no cluster objects.

Kubeadm keeps the cluster-wide settings in the `kubeadm-config` ConfigMap and the kubelet settings in the `kubelet-config` ConfigMap, both in the `kube-system` namespace. Later joins, upgrades and resets read them. They record what kubeadm did and are the right place to read the version and the address ranges of a running cluster. The key facts to remember are these:

- Use one file with `--config` instead of mixing many flags.
- `podSubnet` and `serviceSubnet` belong under `networking`.
- The stored copy of the cluster settings is the ConfigMap `kubeadm-config` in `kube-system`.
- Phases can be listed, skipped and run one at a time.

<!-- astrona:playground:destroy -->
