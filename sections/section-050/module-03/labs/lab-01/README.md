---
estimated_duration: 25m
---

# Lab: Record Leader Election Facts And Grant Least-Privilege Lease Access

Graded lab for the leader election and health module. The learner records live facts and replaces a broad RoleBinding with lease-only access. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-050/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-050/module-03/labs/lab-01
astrona destroy ats-025-lab-050-03-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-record-complete.sh` | The record control-plane-health has all seven keys and no placeholder value |
| `validate-leaders.sh` | schedulerLeader and controllerManagerLeader equal the current Lease holders |
| `validate-lease-flag.sh` | leaseDurationSeconds and leaderElectFlag match the scheduler |
| `validate-probe-paths.sh` | apiServerLivenessPath and apiServerReadinessPath match the API server pod |
| `validate-leader-rbac.sh` | scout-controller can get, create and update leases in starfleet and nothing broader |
| `validate-cluster-intact.sh` | The cluster is ready and the control plane Leases still exist |
