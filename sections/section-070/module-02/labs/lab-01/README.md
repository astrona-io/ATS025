---
estimated_duration: 30m
---

# Lab: Record The Pod Network And Restrict Access With NetworkPolicy

Graded lab for the CNI module. The cluster starts with a probe workload and no NetworkPolicy. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c module-02/labs/lab-01
astrona destroy ats-025-lab-070-02-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-report-pod-network.sh` | ConfigMap network-report records the node pod range and the shuttle pod address |
| `validate-report-service.sh` | ConfigMap network-report records the probe Service address, ready endpoint count and DNS name |
| `validate-default-deny.sh` | default-deny-ingress selects every pod in starfleet and denies all ingress |
| `validate-allow-shuttle.sh` | probe-ingress allows only the shuttle pods to reach probe on TCP 8080 |
| `validate-probe-untouched.sh` | The probe Deployment still has two ready replicas and no egress policy exists |
