---
estimated_duration: 30m
---

# Capstone: Join Review For A kubeadm Cluster

Graded capstone for the kubeadm section. The starfleet namespace starts with a stale init-review ConfigMap. The task is in `question.md`; the walkthrough is in `solution.md`.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c .
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c .
astrona destroy ats-025-lab-030-capstone-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-record-complete.sh` | The review has all eight keys and no stale value |
| `validate-cluster-config.sh` | kubernetesVersion, podSubnet and certificatesDir match the stored ClusterConfiguration |
| `validate-join-endpoint.sh` | apiServerEndpoint equals the server in cluster-info |
| `validate-bootstrap-rbac.sh` | joinGroup and autoApproveRole match the kubeadm bootstrap binding |
| `validate-worker-name.sh` | workerNodeName is the name of the worker node |
| `validate-kubelet-dns.sh` | clusterDNS equals the first address in the stored kubelet configuration |
