---
draft: true
exam_objectives:
- Manage role based access control (RBAC)
---
# Users, Client Certificates And ServiceAccount Tokens

A role binding names a subject, but Kubernetes never stores that subject. There is no User object and no command that creates one. The API server learns who is calling from the credential in each request: a client certificate, a bearer token or another authentication method. This module shows how a person gets a credential that the API server accepts, and how a workload gets a token for its ServiceAccount.

Keep one sentence in mind: **authentication turns a credential into a username and groups, and only then does RBAC decide what that name may do.** You will build a private key and a certificate signing request, have the cluster sign it, put the result into a kubeconfig and grant the new user read access to pods in one namespace. Then you will request tokens for a ServiceAccount, read what a pod receives and switch the token off when a workload does not need one.

## Learning objectives

After this module you can:

- Create a private key and a certificate signing request with `openssl`, with a common name for the user and an organization for the group.
- Submit a `CertificateSigningRequest` for the `kubernetes.io/kube-apiserver-client` signer, approve it and read the issued certificate.
- Add the user to a kubeconfig with `kubectl config set-credentials` and `kubectl config set-context`.
- Bind a role to the user or to the group from the certificate and prove the result with `kubectl auth can-i`.
- Request a ServiceAccount token with `kubectl create token` and explain how it differs from a mounted pod token.
- Switch off automatic token mounting with `automountServiceAccountToken` on a ServiceAccount or a pod and say which setting wins.

## Before you start

You need Kubernetes basics: namespaces, pods, ServiceAccounts, and the commands `kubectl get`, `kubectl apply` and `kubectl auth can-i`. You need `openssl` on your machine. You know that a Role and a RoleBinding give permissions inside one namespace.

Your playground is a single-node `kind` cluster running Kubernetes 1.35:

| Namespace | What is in it |
| --- | --- |
| `starfleet` | The `scout` backend, a `shuttle` client that runs as ServiceAccount `shuttle`, and a ServiceAccount `probe` that has token mounting switched off |
| `outpost` | The `drifter` client that runs as ServiceAccount `drifter` |

No user, Role or RoleBinding exists yet. `kubectl` already points at the playground cluster, as the cluster administrator.

The module has three parts. The first creates a key and a request and gets a signed certificate. The second puts that certificate into a kubeconfig and grants the user access. The third covers ServiceAccount tokens.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
