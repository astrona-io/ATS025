# Overview: Cluster-Scoped Access (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with a few identities and cluster-scoped objects, and then waits. There is no task, no `astrona submit` and no pass or fail. Write ClusterRoles and bindings, break them, run `astrona destroy` and start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` already points at it, as the cluster administrator. Check other identities with `--as`.
- The objects:

  | Where | Object | What it is |
  | --- | --- | --- |
  | `starfleet` | ServiceAccount `scout` | An identity with no permissions |
  | `starfleet` | ServiceAccount `rolemaker` | May `get`, `list` and `create` Roles and RoleBindings in `starfleet`, and `get` and `list` ConfigMaps, through the Role `rbac-editor` |
  | `starfleet` | Secret `warp-key` | A Secret that most identities must not read |
  | cluster | PersistentVolumes `pv-starfleet-a` and `pv-starfleet-b` | Cluster-scoped storage objects |
  | `outpost` | Deployment `drifter` | A client pod |

- No ClusterRole or ClusterRoleBinding of the course exists yet.

## Helpers

Paste these once in each new terminal. `can_scout` asks whether the ServiceAccount `scout` may do a verb on a resource or a non-resource path. `can_rolemaker` does the same for `rolemaker`.

```sh
can_scout() {
  kubectl auth can-i "$@" --as=system:serviceaccount:starfleet:scout
}
can_rolemaker() {
  kubectl auth can-i "$@" --as=system:serviceaccount:starfleet:rolemaker
}
```

Use them like this: `can_scout list nodes`, `can_scout get /metrics`, `can_rolemaker create roles -n starfleet`.

## Practice tasks

- List the cluster-scoped resource types with `kubectl api-resources --namespaced=false`. Pick three and decide which need a ClusterRole.
- Give `scout` read access to nodes and PersistentVolumes with a ClusterRole and a ClusterRoleBinding, and prove each verb with `can_scout`.
- Bind the same ClusterRole with a RoleBinding in `starfleet` instead. Check whether `scout` can now list nodes, and explain the answer.
- Create a ClusterRole that allows `get` on the path `/metrics` and check the answer with `can_scout get /metrics`. Then check `can_scout get /healthz` before you add any rule.
- Run `kubectl auth can-i --list` for `scout` before and after each grant, and read which rows are new.
- As `rolemaker`, try to create a Role in `starfleet` that allows reading Secrets, and a Role that allows reading ConfigMaps. Read both answers.
- As `rolemaker`, try to bind the built-in `edit` ClusterRole in `starfleet`, then add the `bind` verb for `edit` only and try again.
