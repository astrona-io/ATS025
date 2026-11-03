---
draft: true
exam_objectives:
- Create and manage Kubernetes clusters using kubeadm
---
# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You know the four kubeadm configuration kinds and where kubeadm stores the cluster configuration.

The lab starts a kind cluster (Kubernetes 1.35) with one control-plane node and one worker node. The commands for the lab are in the README of this folder.
