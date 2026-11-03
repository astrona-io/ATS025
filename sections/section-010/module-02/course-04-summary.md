---
draft: true
exam_objectives:
- Manage role based access control (RBAC)
---
# Summary

Kubernetes has no user database. The API server reads a name and groups from the credential in each request, and role bindings match those strings. For a person the usual credential is a client certificate that the cluster certificate authority signed. The Common Name in the subject becomes the username and each Organization value becomes a group.

A person creates a private key and a certificate signing request, and a `CertificateSigningRequest` object carries the request to the cluster. The signer name `kubernetes.io/kube-apiserver-client` and the usage `client auth` are required. An administrator must approve the request, because the control plane never approves this signer on its own. The signer then writes the certificate into the object status. A certificate cannot be revoked, so short lifetimes and careful approval are the controls.

A kubeconfig joins a cluster entry, a user entry and a context. An authenticated user without a grant receives a `Forbidden` answer, while a bad credential receives `Unauthorized`. Binding the group from the certificate gives access to everyone who holds a certificate with that group, and binding the user name gives it to every certificate with that name.

Workloads use ServiceAccounts. A pod receives a bound, expiring token in a projected volume that the kubelet refreshes. `kubectl create token` requests a separate token with a chosen lifetime, and the server may shorten or lengthen it. Pods that never call the API should not receive a token, and `automountServiceAccountToken: false` on the ServiceAccount or the pod switches the mount off, with the pod setting taking precedence.

- A subject name that does not match exactly never matches anyone.
- A certificate stays valid until it expires.
- A token is a password for its lifetime.

<!-- astrona:playground:destroy -->
