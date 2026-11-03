---
estimated_duration: 45m
---

# Capstone: Adopt, Release And Customize A Cluster Component

Capstone for the Helm and Kustomize section. A component was applied by hand; the learner brings it under a Helm release without recreating it, then renders the same chart with helm template and customizes it with Kustomize in another namespace. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-060/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-060/capstone/labs/lab-01
astrona destroy ats-025-lab-060-capstone-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-uids.sh` | The relay Deployment and Service keep the UIDs they had at the start |
| `validate-release.sh` | Release relay in starfleet is deployed from chart relay-chart 0.1.0 and records replicaCount 2 and logLevel debug |
| `validate-owned.sh` | The relay Deployment has 2 available replicas, LOG_LEVEL debug and Helm ownership annotations |
| `validate-outpost.sh` | Deployment relay-outpost in outpost has 4 available replicas and is not owned by Helm |
| `validate-patches.sh` | relay-outpost has the label tier: outpost on its pods and the memory limit 64Mi, and its Service has endpoints |
| `validate-separation.sh` | No release named relay-outpost exists and the bridge Deployment is unchanged |
