---
draft: true
exam_objectives:
- Manage role based access control (RBAC)
---
# Grant Cluster-Scoped Read Access With A ClusterRole — Task

The `scout` ServiceAccount in `starfleet` needs to read the nodes and the PersistentVolumes of the cluster, and to read the metrics page of the API server. A leftover binding gives it far more than that. Replace the leftover grant with a minimal one.

## Starting state

The namespace `starfleet`, the ServiceAccount `scout`, the Secret `warp-key` and the PersistentVolumes `pv-starfleet-a` and `pv-starfleet-b` exist. A ClusterRoleBinding named `scout-view` gives `scout` the built-in `view` ClusterRole in every namespace. No other grant for `scout` exists. `kubectl` points at the lab cluster as the cluster administrator.

## Required result

1. Create a ClusterRole named `cluster-inspector` with two rules. The first allows `get`, `list` and `watch` on the core resources `nodes` and `persistentvolumes`. The second allows `get` on the non-resource URL `/metrics`.
2. Bind the ClusterRole to the ServiceAccount `scout` in `starfleet` with a ClusterRoleBinding named `scout-cluster-inspector`.
3. Remove the leftover ClusterRoleBinding `scout-view`.
4. The ServiceAccount `scout` can read nodes, read PersistentVolumes and get `/metrics`. It cannot create, update, patch or delete nodes or PersistentVolumes. It cannot read pods, Secrets or namespaces, and it cannot get any other non-resource path, such as `/logs`.

Do not use a wildcard (`*`) in any rule, do not bind a built-in role such as `view`, `edit` or `cluster-admin`, and do not create a RoleBinding for `scout`.

## Verify the result

Check the access with `kubectl auth can-i` and the flag `--as=system:serviceaccount:starfleet:scout`. For example, `kubectl auth can-i get /metrics --as=system:serviceaccount:starfleet:scout` must answer `yes`. The grader checks the binding, the rules and the effective permissions. Run `astrona submit` when you are ready.
