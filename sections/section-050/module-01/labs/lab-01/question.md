---
draft: true
exam_objectives:
- Implement and configure a highly-available control plane
---
# Inspect A Three-Member Control Plane

Relate actual datastore membership to majority requirements and API availability.

## Starting state

The isolated environment has two healthy probe replicas, an internal Service and two client Pods. The required result has not been configured.

Use a host shell with the private kubeconfig for this independent kind environment. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-025-lab-050-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-025-lab-050-01-01" || exit 1
node_name="astro-ats-025-lab-050-01-01-control-plane"
worker_name="astro-ats-025-lab-050-01-01-worker"
```

Keep this connection selected. Host-level commands name only this environment's node containers. They do not operate on the host operating system.

## Required result

Inspect the three-member stacked etcd cluster in this private environment. Record ConfigMap quorum-review with members three and majority two. All three control-plane nodes and their etcd Pods must remain Ready, the member list must contain three members, and the shared API endpoint must be ready. This observes a local high-availability topology; it does not simulate independent physical failure domains.

## Verify The Result

The grader checks the required object fields and actual observations. Wait for controller convergence before submitting. Preserve the task's namespace, workload names and unrelated components.
