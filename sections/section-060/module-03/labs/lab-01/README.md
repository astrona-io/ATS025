---
estimated_duration: 30m
---

# Lab: Build A Kustomize Overlay

Graded lab for the Kustomize module. The learner saves a base, writes an overlay for the outpost namespace and applies it with kubectl apply -k. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-060/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-060/module-03/labs/lab-01
astrona destroy ats-025-lab-060-03-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-names.sh` | Deployment and Service outpost-shuttle exist in outpost and nothing named shuttle exists in default |
| `validate-workload.sh` | The Deployment has 3 available replicas and runs docker.io/library/busybox:1.37.0 |
| `validate-labels.sh` | Deployment, pods and Service selector carry environment: outpost and the Service has endpoints |
| `validate-limits.sh` | The container has the memory limit 64Mi and the cpu limit 100m |
| `validate-service-port.sh` | The Service listens on port 8080 and still targets the container port |
| `validate-config.sh` | A ConfigMap with a hash suffix holds MODE=patrol and the Deployment refers to exactly that name |
