---
estimated_duration: 20m
---

# Lab: Issue A Client Certificate And Grant Pod Read Access

Graded lab for the users and certificates module. The cluster starts with two namespaces and no user. You create the key and the signing request for the user `jane`, have the cluster sign it and give her group read access to pods in one namespace. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-010/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-010/module-02/labs/lab-01
astrona destroy ats-025-lab-010-02-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-csr-approved-and-issued.sh` | `CertificateSigningRequest` `jane` uses the signer `kubernetes.io/kube-apiserver-client`, has `client auth`, is approved and holds a certificate |
| `validate-certificate-subject-and-ca.sh` | The certificate has `CN=jane` and `O=reviewers`, verifies against the cluster CA and has not expired |
| `validate-reviewers-binding-in-starfleet.sh` | A `RoleBinding` in `starfleet` names the group `reviewers`; no `ClusterRoleBinding`, no other namespace and no broad role |
| `validate-jane-reads-pods-only.sh` | With `--as=jane --as-group=reviewers`: read verbs on pods in `starfleet` are allowed (also a real request); create, delete, other namespace, Secrets, Deployments and nodes are denied |

Every check fails on the starting state.
