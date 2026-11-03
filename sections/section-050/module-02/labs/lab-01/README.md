---
estimated_duration: 25m
---

# Lab: Record The Control Plane Topology And Check A Quorum Proposal

Graded lab for the control plane topology module. The learner reads the topology from the cluster and judges a four-member etcd proposal. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-050/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-050/module-02/labs/lab-01
astrona destroy ats-025-lab-050-02-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-record-complete.sh` | The record topology-review has all ten keys and no placeholder value |
| `validate-endpoint-topology.sh` | controlPlaneEndpoint and etcdTopology match the kubeadm ClusterConfiguration |
| `validate-live-counts.sh` | controlPlaneNodes, etcdMembers and etcdClientUrl match the running cluster |
| `validate-live-quorum.sh` | quorum and faultTolerance follow from the live member count |
| `validate-proposal.sh` | The four-member proposal is judged correctly |
| `validate-cluster-intact.sh` | The cluster is ready and the source objects are unchanged |
