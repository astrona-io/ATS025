---
estimated_duration: 20m
---

# Lab: kubeadm Configuration Files And Init Phases

Graded lab for the kubeadm configuration module. The cluster starts with a draft kubeadm file that has mistakes. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-030/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-030/module-02/labs/lab-01
astrona destroy ats-025-lab-030-02-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-cluster-review.sh` | `cluster-review` holds the version, name, `podSubnet` and `serviceSubnet` recomputed from `kubeadm-config` |
| `validate-plan-api-version.sh` | Both documents exist at `kubeadm.k8s.io/v1beta4`; no `v1beta3` is left |
| `validate-plan-cluster-fields.sh` | `clusterName`, `kubernetesVersion` (equal to the running cluster) and `controlPlaneEndpoint` |
| `validate-plan-networking.sh` | Subnets are under `networking` with the required values; a top-level `podSubnet` fails |
| `validate-plan-init-node.sh` | `nodeRegistration.name` is `outpost-cp-1` and `kubeadm-config` is unchanged |
