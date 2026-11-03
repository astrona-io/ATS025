---
draft: true
exam_objectives:
- Prepare underlying infrastructure for installing a Kubernetes cluster
---
# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You know where kubeadm stores the kubelet configuration and which node status fields hold the runtime, kubelet, kernel and operating system facts.

The lab starts a single-node kind cluster (Kubernetes 1.35). The commands for the lab are in the README of this folder.
