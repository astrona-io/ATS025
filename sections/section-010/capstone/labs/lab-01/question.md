---
draft: true
exam_objectives:
- Manage role based access control (RBAC)
---
# Rebuild Access For Three Identities With RBAC — Task

A review of the `starfleet` cluster found three access problems. The `shuttle` ServiceAccount holds a cluster administrator binding that nobody remembers. The `scout` ServiceAccount has no rights, but it must report on the nodes. A new reviewer, `jane`, has no account at all. Fix all three with the smallest grants that work.

## Starting state

The namespaces `starfleet` and `outpost`, the ServiceAccounts `shuttle` and `scout` in `starfleet`, the Secret `warp-key` and a Deployment in each namespace exist. A ClusterRoleBinding named `shuttle-admin` gives `shuttle` the built-in `cluster-admin` ClusterRole. No Role, ClusterRole, user or certificate signing request of this task exists. `kubectl` points at the lab cluster as the cluster administrator. You need `openssl` on your machine.

## Required result

1. Give `shuttle` read access to pods in `starfleet` only. Create a Role `pod-reader` with `get`, `list` and `watch` on core pods, and a RoleBinding `shuttle-pod-reader` in `starfleet`. Remove the ClusterRoleBinding `shuttle-admin`. Afterwards `shuttle` cannot create or delete pods, read Secrets, read anything in `outpost` or read nodes.
2. Give `scout` read access to nodes. Create a ClusterRole `node-reader` with `get`, `list` and `watch` on `nodes`, and a ClusterRoleBinding `scout-node-reader`. Do not use a built-in role or a wildcard. `scout` must not read pods, Secrets, PersistentVolumes or namespaces.
3. Create the identity for `jane`. Make a key and a certificate signing request with the subject `/CN=jane/O=reviewers`. Submit a `CertificateSigningRequest` named `jane` with the signer `kubernetes.io/kube-apiserver-client` and the usage `client auth`, and approve it.
4. Give the group `reviewers` read access to the objects of `starfleet` with the built-in ClusterRole `view`, through a RoleBinding in `starfleet`. Do not use a ClusterRoleBinding. As `jane` in the group `reviewers`, pods and Deployments in `starfleet` can be read. Secrets, anything in `outpost`, nodes and every write cannot.

Leave the namespaces, the Deployments and the ServiceAccounts unchanged.

## Verify the result

Check each identity with `kubectl auth can-i` and the flag `--as=system:serviceaccount:starfleet:shuttle`, `--as=system:serviceaccount:starfleet:scout` or `--as=jane --as-group=reviewers`. Read the subject of the certificate with `openssl x509 -noout -subject`. The grader checks the bindings, the issued certificate and the effective permissions of all three identities. Run `astrona submit` when you are ready.
