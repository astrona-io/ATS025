---
draft: true
exam_objectives:
- Create and manage Kubernetes clusters using kubeadm
---
# Prepare Short-Lived Node Discovery Credentials

Create short-lived bootstrap discovery credentials and record the trusted CA public-key hash.

The task and solution use a separate pinned kind cluster. Run `testing/smoke.sh` with its private kubeconfig to verify initial rejection and reference success. Static validation is not live evidence. Runtime verification remains pending.
