---
draft: true
exam_objectives:
- Understand CRDs, install and configure operators
---
# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You can write a ServiceAccount, a ClusterRole and a ClusterRoleBinding, and you can check permissions with kubectl auth can-i.

The lab starts a kind cluster (Kubernetes 1.35). The commands for the lab are in the README of this folder.
