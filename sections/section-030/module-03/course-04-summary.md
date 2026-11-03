---
draft: true
exam_objectives:
- Create and manage Kubernetes clusters using kubeadm
---
# Summary

A kubeadm cluster rests on three certificate authorities: the cluster CA, the etcd CA and the front proxy CA. The CA certificates last ten years by default and the leaf certificates last one year. The files live in `/etc/kubernetes/pki` and the kubeconfig files in `/etc/kubernetes`. `kubeadm certs check-expiration` reports expiry and `kubeadm certs renew` renews the certificates that kubeadm manages. A running control plane component keeps its old certificate until its static pod restarts. The kubelet renews its own client certificate through rotation, so kubeadm does not list it.

A new node trusts the cluster through two values that the join command carries. The bootstrap token is stored as a Secret of type `bootstrap.kubernetes.io/token` in `kube-system`, and it lets the node read the `cluster-info` ConfigMap and request a certificate. The CA public-key hash pins the public key of the cluster CA, so a node that reaches a fake API server detects it. The signature on `cluster-info` proves only that the author holds the token.

After discovery, the kubelet uses the token once to create a certificate signing request. The CSR approving controller approves it automatically and the controller manager signs it with the cluster CA. The kubelet then runs as `system:node:<node name>`. The Node object stays `NotReady` until a network add-on writes a CNI configuration file, because the container runtime reports its network as not ready until then.

`kubeadm reset` undoes the local changes of init or join, but it keeps CNI configuration, iptables rules and kubeconfig files. The correct removal order is to drain the node, delete the Node object and then reset the machine.

- Three CAs sign the identities; leaf certificates last one year.
- The token authenticates a join; the hash authenticates the cluster.
- The node client certificate comes from an auto-approved CSR.
- No CNI configuration means a `NotReady` node.

<!-- astrona:playground:destroy -->
