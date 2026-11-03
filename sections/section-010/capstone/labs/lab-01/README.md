---
estimated_duration: 40m
---

# Capstone Lab: Rebuild Access For Three Identities With RBAC

Graded capstone for the RBAC section. One cluster holds three access problems: a ServiceAccount with a forgotten cluster administrator binding, a ServiceAccount that needs a cluster-scoped read and a new reviewer without a certificate. You replace the leftover grant with a Role, grant node reads with a ClusterRole, issue a client certificate through a `CertificateSigningRequest` and bind a group to the built-in `view` role in one namespace. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-010/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-010/capstone/labs/lab-01
astrona destroy ats-025-lab-010-capstone-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-shuttle-pod-reader-only.sh` | RoleBinding `shuttle-pod-reader` references `Role/pod-reader`; no ClusterRoleBinding names `shuttle`; pod reads in `starfleet` are allowed and writes, Secrets, `outpost` and nodes are denied |
| `validate-scout-reads-nodes-only.sh` | `scout` is bound by a ClusterRoleBinding to a custom ClusterRole without wildcard; node reads are allowed (also a real request); writes, volumes, pods, Secrets and namespaces are denied |
| `validate-csr-approved-and-issued.sh` | `CertificateSigningRequest` `jane` uses the signer `kubernetes.io/kube-apiserver-client`, has `client auth`, is approved and holds a certificate |
| `validate-certificate-subject-and-ca.sh` | The certificate has `CN=jane` and `O=reviewers`, verifies against the cluster CA and has not expired |
| `validate-reviewers-view-binding.sh` | A RoleBinding in `starfleet` binds the group `reviewers` to `ClusterRole/view`; no ClusterRoleBinding and no other namespace names `reviewers` or `jane` |
| `validate-jane-effective-access.sh` | With `--as=jane --as-group=reviewers`: reads of pods and Deployments in `starfleet` are allowed; writes, Secrets, `outpost` and nodes are denied |

Every check fails on the starting state.
