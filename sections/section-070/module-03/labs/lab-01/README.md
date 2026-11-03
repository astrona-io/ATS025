---
estimated_duration: 30m
---

# Lab: Define A StorageClass, A CSIDriver And A Claim

Graded lab for the CSI module. The cluster starts with the default StorageClass of kind and one old claim. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c module-03/labs/lab-01
astrona destroy ats-025-lab-070-03-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-storageclass.sh` | StorageClass outpost-retain uses the cluster provisioner with Retain, WaitForFirstConsumer and expansion |
| `validate-default-unchanged.sh` | standard stays the only default StorageClass |
| `validate-csidriver.sh` | CSIDriver logbook.csi.astrona.io has the requested fields |
| `validate-claim.sh` | Claim logbook asks for 1Gi ReadWriteOnce from outpost-retain and waits for a consumer |
| `validate-storage-report.sh` | ConfigMap storage-report records the default class facts and the class of legacy-claim |
