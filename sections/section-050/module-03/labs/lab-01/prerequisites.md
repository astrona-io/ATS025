---
draft: true
exam_objectives:
- Implement and configure a highly-available control plane
---
# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You can read Lease objects and API server probes, and write a Role that allows leader election.

The lab starts a kind cluster (Kubernetes 1.35). The commands for the lab are in the README of this folder.
