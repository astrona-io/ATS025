---
estimated_duration: 20m
---

# Lab: Map Certificates To Control Plane Components

Graded lab for the certificates module. The starfleet namespace starts with a stale pki-map ConfigMap. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c labs/lab-01
astrona destroy ats-025-lab-030-03-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-record-complete.sh` | The map has all eight keys and no stale value |
| `validate-apiserver-certs.sh` | The API server certificate keys match the kube-apiserver flags |
| `validate-service-account-keys.sh` | The service account keys match the API server and controller manager flags |
| `validate-signing-and-etcd.sh` | The cluster signing certificate and the etcd peer certificate match their flags |
| `validate-scheduler-identity.sh` | schedulerKubeconfig matches the kube-scheduler flag |
