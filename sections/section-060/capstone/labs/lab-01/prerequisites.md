---
draft: true
exam_objectives:
- Use Helm and Kustomize to install cluster components
---
# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- `helm` (version 3 or later) and `python3`.
- You can install and upgrade a Helm release, add ownership metadata to an existing object and apply a Kustomize overlay.

The lab starts a kind cluster (Kubernetes 1.35). The commands for the lab are in the README of this folder.
