---
estimated_duration: 25m
---

# Lab: Snapshot etcd And Record The Restore Facts

Graded lab for the etcd module. The starfleet namespace starts with a stale etcd-recovery ConfigMap. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-040/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-040/module-03/labs/lab-01
astrona destroy ats-025-lab-040-03-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-record-complete.sh` | The record has all eight keys and no stale value |
| `validate-etcd-flags.sh` | dataDir, memberName, trustedCaFile and peerUrl match the etcd pod flags |
| `validate-etcd-volumes.sh` | dataHostPath and certHostPath match the hostPath volumes of the etcd pod |
| `validate-snapshot-file.sh` | A valid snapshot exists at /tmp/recovery-snapshot.db in the etcd pod |
| `validate-snapshot-record.sh` | snapshotRevision and snapshotTotalKeys match the snapshot file |
| `validate-cluster-healthy.sh` | The API server is ready and the live etcd data directory is unchanged |
