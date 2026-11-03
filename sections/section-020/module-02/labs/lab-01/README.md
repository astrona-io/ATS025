---
estimated_duration: 20m
---

# Lab: Record Host Readiness From The API

Graded lab for the kernel, swap and cgroup module. The `starfleet` namespace starts with a stale `host-readiness` ConfigMap. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-020/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-020/module-02/labs/lab-01
astrona destroy ats-025-lab-020-02-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-record-complete.sh` | The ConfigMap exists with six keys and none holds a stale value |
| `validate-cgroup-driver.sh` | `cgroupDriver` equals the value in the stored kubelet configuration |
| `validate-fail-swap-on.sh` | `failSwapOn` equals the stored value, or `true` when absent |
| `validate-runtime-kubelet.sh` | Runtime and kubelet version equal the node status |
| `validate-kernel-os.sh` | Kernel version and operating system image equal the node status |
| `validate-kubelet-config-untouched.sh` | The `kubelet-config` ConfigMap still matches the checksum taken at the start |
