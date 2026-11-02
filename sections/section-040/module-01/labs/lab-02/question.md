---
draft: true
exam_objectives:
- Manage the lifecycle of Kubernetes clusters
---
# Save And Inspect An Etcd Snapshot

Save a real datastore snapshot and inspect its revision and key count without restoring the live cluster.

## Starting state

The isolated environment has two healthy probe replicas, an internal Service and two client Pods. The required result has not been configured.

Use a host shell with the private kubeconfig for this independent kind environment. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-025-lab-040-01-02)"
test "$(kubectl config current-context)" = "kind-astro-ats-025-lab-040-01-02" || exit 1
node_name="astro-ats-025-lab-040-01-02-control-plane"
worker_name="astro-ats-025-lab-040-01-02-worker"
```

Keep this connection selected. Host-level commands name only this environment's node containers. They do not operate on the host operating system.

## Required result

Save /tmp/training-snapshot.db using authenticated etcdctl from the lab etcd Pod. Use etcdutl snapshot status to validate the saved file. Record ConfigMap snapshot-review with result validated, revision and totalKey matching that inspection. Keep API access available. Do not overwrite live etcd data directories; a restore needs a separate recovery workflow.

## Verify The Result

The grader checks the required object fields and actual observations. Wait for controller convergence before submitting. Preserve the task's namespace, workload names and unrelated components.
