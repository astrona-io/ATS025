---
draft: true
exam_objectives:
- Create and manage Kubernetes clusters using kubeadm
---
# Create and manage Kubernetes clusters using kubeadm

A worker joins using a bootstrap token, but later it cannot report to the API. Joining and continued authenticated operation are different stages of the node lifecycle, and each stage depends on a different file, certificate or configuration object. This section explains how kubeadm builds a control plane and how a node joins it.

The section has three modules. The first explains initialization and node joining as a whole. The second reads the kubeadm configuration kinds, the init phases and the configuration that kubeadm stores in the cluster. The third covers the certificate files, the bootstrap token, the CA public-key hash, the join sequence and `kubeadm reset`. Every module has a playground and a graded lab, and the section closes with a capstone lab and a knowledge check.

## Learning Outcomes

- Distinguish initialization from worker or control-plane joining.
- Name the kubeadm configuration kinds and read the configuration stored in the cluster.
- Explain the init phases and which static pods and files each creates.
- Check certificate expiry and say which certificates the kubelet rotates itself.
- Explain what a bootstrap token, the `cluster-info` ConfigMap and the CA public-key hash each protect.
- Identify the stage that blocks node readiness: discovery, the certificate request or the network add-on.
