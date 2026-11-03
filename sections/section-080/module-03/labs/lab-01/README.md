---
estimated_duration: 25m
---

# Lab: Wire An Operator With Least Privilege

Graded lab for the operator module. The Beacon CRD and an operator Deployment exist, but the Deployment has no identity and no permissions. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c labs/lab-01
astrona destroy ats-025-lab-080-03-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-identity.sh` | The operator Deployment uses the ServiceAccount beacon-operator and is available |
| `validate-permissions.sh` | The ServiceAccount can do what the controller loop needs |
| `validate-least-privilege.sh` | The ServiceAccount cannot delete beacons or nodes, or read secrets |
| `validate-no-wildcards.sh` | The bound ClusterRole has no wildcard rule |
| `validate-watch-namespace.sh` | The Deployment sets WATCH_NAMESPACE to starfleet |
| `validate-first-resource.sh` | A Beacon named first-beacon with channel alpha exists in starfleet |
