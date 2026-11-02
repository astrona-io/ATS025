---
draft: true
exam_objectives:
- Create and manage Kubernetes clusters using kubeadm
---
# Prepare Short-Lived Node Discovery Credentials

Create short-lived bootstrap discovery credentials and record the trusted CA public-key hash.

## Starting state

The isolated environment has two healthy probe replicas, an internal Service and two client Pods. The required result has not been configured.

Use a host shell with the private kubeconfig for this independent kind environment. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-025-lab-030-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-025-lab-030-01-01" || exit 1
node_name="astro-ats-025-lab-030-01-01-control-plane"
worker_name="astro-ats-025-lab-030-01-01-worker"
```

Keep this connection selected. Host-level commands name only this environment's node containers. They do not operate on the host operating system.

## Required result

Create a kubeadm bootstrap token with a ten-minute lifetime in this lab. Record only its six-character tokenID and the sha256 CA public-key hash in ConfigMap join-review, together with the node name. Keep the credential Secret intact for grading. Never put the full token in the ConfigMap. This practices discovery preparation on an existing cluster; it does not claim a fresh control-plane initialization or node join.

## Verify The Result

The grader checks the required object fields and actual observations. Wait for controller convergence before submitting. Preserve the task's namespace, workload names and unrelated components.
