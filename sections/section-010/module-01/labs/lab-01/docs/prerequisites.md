---
draft: true
exam_objectives:
- Manage role based access control (RBAC)
---
# Prerequisites

Use a host shell with astrona, kubectl and Python 3. Understand the resource fields and diagnostic commands taught before this task.

Use this lab's private kubeconfig. A kubeconfig contains the cluster address and credentials used by kubectl, the Kubernetes command-line tool. The lab has a separate kind cluster from the module playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-025-lab-010-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-025-lab-010-01-01" || exit 1
```

Keep this connection selected for every command below.
