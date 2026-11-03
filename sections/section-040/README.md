---
draft: true
exam_objectives:
- Manage the lifecycle of Kubernetes clusters
---
# Manage the lifecycle of Kubernetes clusters

A node upgrade removes its ready application replicas, but the remaining nodes cannot host replacements. Version compatibility and maintenance availability are separate planning requirements.

The section has three modules. The first covers supported upgrades and node maintenance: cordon, drain and disruption limits. The second covers the kubeadm upgrade workflow and the version skew policy. The third covers etcd snapshots, restore and recovery. Every module has a playground and a graded lab, and the section closes with a capstone lab and a knowledge check.

## Learning Outcomes

- Explain supported component-version and upgrade order.
- Distinguish cordon, drain and disruption policy.
- Evaluate datastore snapshot scope and restore prerequisites.
- Verify component and application recovery after lifecycle changes.
- Describe what `kubeadm upgrade plan`, `apply` and `node` change, and the order of an upgrade.
- Apply the version skew policy to the API server, the control plane components, the kubelet, kube-proxy and kubectl.
- Take an etcd snapshot with `etcdctl`, check it with `etcdutl` and restore it into a new data directory.
- Explain how the etcd static pod uses the restored data and which checks prove a recovery.

## Modules

1. Supported Upgrade And Node Maintenance
2. kubeadm Upgrade Workflow And Version Skew
3. etcd Restore And Recovery
4. Capstone: Upgrade Readiness And Recovery Review
