---
estimated_duration: 20m
---

# Lab: Audit Component Versions Before An Upgrade

Graded lab for the upgrade module. The starfleet namespace starts with a stale upgrade-review ConfigMap. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-040/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-040/module-02/labs/lab-01
astrona destroy ats-025-lab-040-02-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-record-complete.sh` | The review has all nine keys and no stale value |
| `validate-control-plane-versions.sh` | The API server, controller manager and scheduler versions match their pod images |
| `validate-proxy-and-kubelet.sh` | kubeProxyVersion and kubeletVersion match the cluster |
| `validate-stored-version.sh` | storedVersion matches the ClusterConfiguration in kubeadm-config |
| `validate-skew-window.sh` | oldestKubelet and nextMinor follow from the API server version |
| `validate-kubeadm-config-untouched.sh` | The kubeadm-config ConfigMap was not edited to fit the record |
