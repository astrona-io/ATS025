# Overview: Users, Client Certificates And ServiceAccount Tokens (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and waits. There is no task, no `astrona submit` and no pass or fail. Create keys and certificate signing requests, approve them, break them, run `astrona destroy` and start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` already points at it, as the cluster administrator. The commands in the lessons that create keys and requests use `openssl`, which must be installed on your machine.
- The example workloads and identities:

  | Namespace | Object | What it is |
  | --- | --- | --- |
  | `starfleet` | Deployment `scout` | The example backend, running `podinfo` on port 9898 |
  | `starfleet` | Deployment `shuttle` | A client pod with `curl`, running as ServiceAccount `shuttle` |
  | `starfleet` | ServiceAccount `probe` | Has `automountServiceAccountToken: false`, so its pods get no token |
  | `outpost` | Deployment `drifter` | A client pod with `curl`, running as ServiceAccount `drifter` |

- No user exists. Kubernetes has no User object: a user is whatever name a certificate or token carries.
- No Role or RoleBinding exists yet in `starfleet` or `outpost`.

## Helpers

Paste these once in each new terminal. `can_user` asks whether a user in a group may do one verb on one resource. `show_certificate` prints the subject, the issuer and the validity dates of a certificate file.

```sh
can_user() {
  kubectl auth can-i "$3" "$4" -n "${5:-starfleet}" --as="$1" --as-group="$2"
}
show_certificate() {
  openssl x509 -in "$1" -noout -subject -issuer -dates
}
```

Use them like this: `can_user jane reviewers list pods`, `can_user jane reviewers list pods outpost`, `show_certificate jane.crt`.

## Practice tasks

- Create a private key and a signing request for a user named `jane` in the group `reviewers`. Submit it as a `CertificateSigningRequest`, approve it and read the issued certificate. Check that the subject holds the name and the group you asked for.
- Add `jane` to your kubeconfig with `kubectl config set-credentials` and a context that uses it. Run `kubectl get pods -n starfleet` with that context and read the `Forbidden` error before you grant anything.
- Give the group `reviewers` read access to pods in `starfleet` only. Then try `outpost` and `get secrets` as `jane` and confirm both are denied.
- Request a token for the ServiceAccount `shuttle` with `kubectl create token`, ask for a lifetime of ten minutes and compare it with the token mounted in the `shuttle` pod.
- Create a pod that uses ServiceAccount `probe` and check whether the token directory exists inside it. Then set `automountServiceAccountToken: true` on the pod and check again.
- Create a second `CertificateSigningRequest` with the wrong `signerName` and with a missing `client auth` usage, and read how the API server answers each one.
