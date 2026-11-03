---
estimated_duration: 20m
---

# Lab: Record Control Plane Ports From Static Pods

Graded lab for the packages, ports and preflight module. The `starfleet` namespace starts with a `control-plane-ports` ConfigMap copied from an outdated guide. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-020/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-020/module-03/labs/lab-01
astrona destroy ats-025-lab-020-03-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-record-complete.sh` | Six numeric keys, none from the outdated record |
| `validate-apiserver-port.sh` | `apiserver` equals the port the kube-apiserver pod declares |
| `validate-etcd-ports.sh` | `etcdClient` and `etcdPeer` equal the etcd listen URL ports |
| `validate-scheduler-controller-manager-ports.sh` | Both equal the probe ports of their pods; the old 10251 and 10252 fail |
| `validate-kubelet-port.sh` | `kubelet` equals the node status port |
