---
estimated_duration: 30m
---

# Capstone: Host Readiness Review Before Installation

Graded capstone for the infrastructure section. The `starfleet` namespace starts with a stale `readiness-review` ConfigMap. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-020/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-020/capstone/labs/lab-01
astrona destroy ats-025-lab-020-capstone-01
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-review-complete.sh` | The ConfigMap has eight keys and none holds a stale value |
| `validate-runtime-identity.sh` | Runtime socket and version equal the node data |
| `validate-cgroup-swap.sh` | `cgroupDriver` and `failSwapOn` equal the stored kubelet configuration |
| `validate-ports.sh` | API server and etcd client ports equal the control plane pods |
| `validate-address-ranges.sh` | Service and pod ranges equal the control plane flags |
| `validate-kubelet-config-untouched.sh` | The `kubelet-config` ConfigMap still matches the checksum taken at the start |
