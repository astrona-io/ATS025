---
estimated_duration: 40m
---

# Capstone: Review A Control Plane For High Availability

Capstone for the highly available control plane section. The learner reviews the live control plane, judges a proposal and fixes lease access. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-050/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-050/capstone/labs/lab-01
astrona destroy ats-025-lab-050-capstone-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-report-complete.sh` | The record ha-report has all eleven keys and no placeholder value |
| `validate-topology.sh` | Endpoint, topology, member count, quorum and fault tolerance match the live cluster |
| `validate-leaders.sh` | The scheduler and controller manager leaders equal the current Lease holders |
| `validate-proposal.sh` | The six-member proposal is judged correctly |
| `validate-leader-rbac.sh` | mission-controller can manage leases in mission-system and nothing broader |
| `validate-verdict.sh` | The verdict follows from the fault tolerance and the cluster is untouched |
