---
estimated_duration: 25m
---

# Lab: Tighten A CustomResourceDefinition Schema

Graded lab for the CRD schema module. The cluster starts with a Beacon CRD that accepts any content. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c labs/lab-01
astrona destroy ats-025-lab-080-02-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-crd-established.sh` | The Beacon CRD is established and serves version v1 as the storage version |
| `validate-schema.sh` | The API server rejects a bad channel and a missing channel, and accepts a valid object |
| `validate-interval.sh` | interval is limited to 5 through 3600 and defaults to 60 |
| `validate-immutable.sh` | channel cannot be changed after creation, interval can |
| `validate-columns.sh` | kubectl get shows the Channel and Interval columns |
| `validate-status.sh` | The status subresource is enabled |
