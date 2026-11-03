---
estimated_duration: 20m
---

# Lab: Grant A ServiceAccount Pod Read Access With A Role

Graded lab for the Roles and RoleBindings module. A ServiceAccount has no Role, and a leftover binding in another namespace gives it write access. You write the Role and the RoleBinding for pod reads in one namespace, remove the leftover grant and prove that nothing else is allowed. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-010/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-010/module-01/labs/lab-01
astrona destroy ats-025-lab-010-01-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-role-pod-reader.sh` | Role `pod-reader` in `starfleet` has one rule with `get`, `list` and `watch` on core `pods`; no wildcard, no `resourceNames` |
| `validate-rolebinding-shuttle.sh` | RoleBinding `shuttle-pod-reader` has `roleRef` `Role/pod-reader` and the ServiceAccount `shuttle` in `starfleet` as its only subject |
| `validate-shuttle-reads-pods.sh` | `get`, `list` and `watch` on pods in `starfleet` are allowed, with `kubectl auth can-i` and a real request |
| `validate-shuttle-nothing-more-in-starfleet.sh` | Write verbs on pods, logs, exec, Secrets, ConfigMaps, Deployments and RoleBindings are denied in `starfleet` |
| `validate-no-other-grants-for-shuttle.sh` | No other RoleBinding or ClusterRoleBinding names `shuttle`; pods, Deployments and Secrets in `outpost`, all pods and nodes are denied |

Every check fails on the starting state.
