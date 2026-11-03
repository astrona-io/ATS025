---
estimated_duration: 35m
---

# Capstone: Upgrade Readiness And Recovery Review

Graded capstone for the lifecycle section. The starfleet namespace starts with a stale lifecycle-review ConfigMap and the worker is cordoned. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-040/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-040/capstone/labs/lab-01
astrona destroy ats-025-lab-040-capstone-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-record-complete.sh` | The review has all ten keys and no stale value |
| `validate-versions.sh` | apiServerVersion, kubeletVersion, storedVersion and etcdVersion match the cluster |
| `validate-skew-window.sh` | oldestKubelet and nextMinor follow from the API server version |
| `validate-snapshot-file.sh` | A valid snapshot exists at /tmp/lifecycle-snapshot.db in the etcd pod |
| `validate-snapshot-record.sh` | snapshotRevision and snapshotTotalKeys match the snapshot file |
| `validate-worker-returned.sh` | The worker is schedulable and the probe Deployment is fully available |
