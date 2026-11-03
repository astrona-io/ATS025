---
draft: true
exam_objectives:
- Manage role based access control (RBAC)
---
# Issue A Client Certificate And Grant Pod Read Access — Task

A new colleague, `jane`, joins the reviewers who watch the `scout` backend in `starfleet`. She must authenticate with a client certificate signed by this cluster, and her group must be able to read pods in `starfleet` and nothing else.

## Starting state

The namespaces `starfleet` and `outpost` and the Deployments `scout` and `drifter` exist. No user, certificate signing request, Role or RoleBinding exists. `kubectl` points at the lab cluster as the cluster administrator. You need `openssl` on your machine.

## Required result

1. Create a private key and a certificate signing request with `openssl`. The subject must have the common name `jane` and the organization `reviewers`.
2. Submit a `CertificateSigningRequest` named `jane` that uses the signer `kubernetes.io/kube-apiserver-client` and the usage `client auth`. Approve it so that the cluster issues the certificate.
3. Create a Role `pod-reader` in `starfleet` that allows `get`, `list` and `watch` on core pods and nothing else.
4. Bind the Role to the group `reviewers` with a RoleBinding in `starfleet`. Do not use a ClusterRoleBinding and do not bind a built-in role such as `edit`.
5. With the user `jane` in the group `reviewers`, pods in `starfleet` can be read. Pods in `outpost`, Secrets, Deployments and nodes cannot be read, and no pod can be created or deleted.

Leave the namespaces and the Deployments unchanged.

## Verify the result

Check the request with `kubectl get csr jane`, and read the subject of the issued certificate with `openssl x509 -noout -subject`. Check the access with `kubectl auth can-i` and the flags `--as=jane --as-group=reviewers`. The grader checks the issued certificate, the binding and the effective permissions. Run `astrona submit` when you are ready.
