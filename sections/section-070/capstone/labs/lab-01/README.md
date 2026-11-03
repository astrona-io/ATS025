---
estimated_duration: 45m
---

# Capstone: Secure And Persist The Probe Workload

Capstone for the extension interfaces section. The probe workload has no network restriction and no storage. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c capstone/labs/lab-01
astrona destroy ats-025-lab-070-capstone-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-report.sh` | ConfigMap platform-report records the pod range, Service address, default class and runtime facts |
| `validate-default-deny.sh` | default-deny-ingress denies all ingress in starfleet |
| `validate-allow-shuttle.sh` | probe-from-shuttle allows only the shuttle pods on TCP 8080 |
| `validate-allow-outpost.sh` | probe-from-outpost allows only the drifter pods in outpost on TCP 8080 |
| `validate-storage-objects.sh` | StorageClass starfleet-data and CSIDriver data.csi.astrona.io have the requested fields |
| `validate-claim-and-pod.sh` | Claim probe-data exists and pod recorder mounts it at /data |
