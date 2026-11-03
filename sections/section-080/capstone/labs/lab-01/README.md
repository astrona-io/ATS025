---
estimated_duration: 45m
---

# Capstone: Publish A Custom Type And Install Its Operator

Capstone for the custom resource section. The cluster has no Mission type yet and the operator Deployment has no identity. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c capstone/labs/lab-01
astrona destroy ats-025-lab-080-capstone-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-crd-schema.sh` | The Mission CRD is established and its schema rejects bad phase and crewSize values |
| `validate-defaults-immutable.sh` | crewSize defaults to 3 and callSign cannot change after creation |
| `validate-subresource-columns.sh` | The status subresource and the Phase and Crew columns exist |
| `validate-identity.sh` | The operator Deployment uses the ServiceAccount mission-operator and is available |
| `validate-permissions.sh` | The ServiceAccount has the loop permissions and nothing wider |
| `validate-first-mission.sh` | A Mission named apollo exists in starfleet with phase Planned and the default crew |
