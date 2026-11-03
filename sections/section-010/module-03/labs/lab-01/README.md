---
estimated_duration: 20m
---

# Lab: Grant Cluster-Scoped Read Access With A ClusterRole

Graded lab for the cluster-scoped access module. A ServiceAccount holds a leftover binding to the built-in `view` role. You replace it with a ClusterRole that reads nodes, PersistentVolumes and one non-resource URL, and you prove that nothing else is allowed. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-010/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-010/module-03/labs/lab-01
astrona destroy ats-025-lab-010-03-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-binding-shape.sh` | `scout` is bound by at least one ClusterRoleBinding to a custom ClusterRole; no built-in or `system:` role, no wildcard in the role and no RoleBinding |
| `validate-nodes-and-volumes-readable.sh` | `get`, `list` and `watch` on nodes and PersistentVolumes are allowed for `scout`, with `kubectl auth can-i` and real requests |
| `validate-metrics-path-readable.sh` | `get /metrics` is allowed, also by a real request; `/logs` and `/debug/pprof` are denied |
| `validate-nothing-else-allowed.sh` | Write verbs on nodes and PersistentVolumes, pods in any namespace, Secrets, namespaces and ClusterRoleBinding creation are all denied |

Every check fails on the starting state.
