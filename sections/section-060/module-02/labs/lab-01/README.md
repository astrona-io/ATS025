---
estimated_duration: 30m
---

# Lab: Install, Upgrade And Roll Back A Helm Release

Graded lab for the Helm module. The learner installs a chart as release scout, upgrades it and rolls it back. The grader reads the release records that Helm keeps in Secrets. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-060/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-060/module-02/labs/lab-01
astrona destroy ats-025-lab-060-02-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-release.sh` | Release scout exists in starfleet, was installed from chart scout-chart 0.1.0 and its latest revision is deployed |
| `validate-history.sh` | The release has at least three revisions and the latest one is a rollback to revision 1 |
| `validate-values.sh` | Revision 1 recorded replicaCount 2, and revision 2 recorded replicaCount 3 and logLevel debug |
| `validate-workload.sh` | The scout Deployment runs the values of revision 1 again: 2 available replicas and LOG_LEVEL info |
| `validate-ownership.sh` | The Deployment and the Service carry the Helm ownership annotations for release scout |
| `validate-bridge.sh` | The unrelated bridge Deployment is unchanged and not owned by Helm |
