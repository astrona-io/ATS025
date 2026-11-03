---
draft: true
exam_objectives:
- Create and manage Kubernetes clusters using kubeadm
---
# Certificates, kubeconfig Files And Joining Nodes

A kubeadm cluster is held together by certificates. The API server proves its identity to the kubelets with one, each kubelet proves its identity to the API server with another, and a joining node decides whether to trust the control plane by checking the public key of the cluster certificate authority. When a certificate expires or a join fails, the cause is almost always in this layer.

Keep one idea in mind for this module: **one certificate authority signs every identity in the cluster, and a new node trusts the cluster only because it knows the hash of that authority's public key.** You will find the authority's certificate in the API, compute its hash with `openssl`, and follow how a token, that hash and a network add-on turn a bare machine into a Ready node.

The module has three parts. The first part lists the files kubeadm writes to `/etc/kubernetes`, explains certificate lifetimes, and shows how to check and renew certificates. The second part explains bootstrap tokens, the discovery ConfigMap and the CA public-key hash. The third part joins a node, installs a network add-on and resets a node.

## Learning objectives

After this module you can:

- Name the main files in `/etc/kubernetes/pki` and `/etc/kubernetes` and say which component uses each.
- Check certificate expiry and say which certificates `kubeadm certs renew` handles and which the kubelet rotates itself.
- Read the cluster certificate authority from the `kube-root-ca.crt` ConfigMap and compute its subject, expiry and public-key hash with `openssl`.
- Explain what a bootstrap token is, how long it lives and why `--discovery-token-unsafe-skip-ca-verification` weakens a join.
- Describe the order of a node join and say why a node stays `NotReady` until a network add-on runs.
- Explain what `kubeadm reset` removes and what it leaves behind.

## Before you start

You need Kubernetes basics: nodes, pods, Secrets, ConfigMaps and `kubectl get`. You also need `openssl` on your own machine, because you compute a hash from a certificate. You do not need to know public-key cryptography beyond this idea: a certificate authority (CA) signs certificates, and clients trust a certificate when it chains to a CA they already trust.

Your playground runs Kubernetes 1.35 with one control-plane node and one worker node:

| Item | What is in it |
| --- | --- |
| `kube-system` | Static pods of the control plane, CoreDNS, kube-proxy and the CNI add-on that kind installs |
| `kube-public` | The `cluster-info` ConfigMap that joining nodes read |
| `starfleet` | A `probe` Deployment and an empty space for your own notes |
| every namespace | A `kube-root-ca.crt` ConfigMap that holds the cluster CA certificate |

`kubectl` already points at the playground cluster, as the cluster administrator.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
