# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`, `jq` and `openssl`.
- You know how a `Role` and a `RoleBinding` work, and how to check an identity with `kubectl auth can-i --as`.

The lab starts a single-node kind cluster (Kubernetes 1.35) with the example workloads in `starfleet` and `outpost`. The commands for the lab are in the README of this folder.
