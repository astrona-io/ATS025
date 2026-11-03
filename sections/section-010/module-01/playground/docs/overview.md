# Overview: Roles, RoleBindings And Least Privilege (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with two ServiceAccounts that have no permissions, and then waits. There is no task, no `astrona submit` and no pass or fail. Write Roles and bindings, break them, run `astrona destroy` and start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` already points at it, as the cluster administrator. Check other identities with `--as`.
- The objects:

  | Namespace | Object | What it is |
  | --- | --- | --- |
  | `starfleet` | ServiceAccount `shuttle` | An identity with no permissions |
  | `starfleet` | ServiceAccount `scout` | A second identity with no permissions |
  | `starfleet` | Secret `warp-key` | A Secret that most identities must not read |
  | `starfleet` | Deployment `scout` | A client pod |
  | `outpost` | Deployment `drifter` | A client pod |

- No Role or RoleBinding of the course exists yet.

## Helpers

Paste these once in each new terminal. `can_shuttle` and `can_scout` ask whether the ServiceAccount may do a verb on a resource.

```sh
can_shuttle() {
  kubectl auth can-i "$@" --as=system:serviceaccount:starfleet:shuttle
}
can_scout() {
  kubectl auth can-i "$@" --as=system:serviceaccount:starfleet:scout
}
```

Use them like this: `can_shuttle list pods -n starfleet`, `can_scout get secrets -n starfleet`.

## Practice tasks

- Create a Role `pod-reader` with `kubectl create role` and bind it to `shuttle` with `kubectl create rolebinding`. Prove each verb with `can_shuttle`, in `starfleet` and in `outpost`.
- Print the same Role with `--dry-run=client -o yaml` and compare it with a Role you write by hand.
- Add `pods/log` to the rules. Check `can_shuttle get pods/log -n starfleet` before and after.
- Write a Role with `resourceNames` for one ConfigMap. Create two ConfigMaps and find out which verbs work for each.
- Bind the built-in `view` ClusterRole to `scout` with a RoleBinding in `starfleet`. Check a list of Deployments in `starfleet` and in `outpost`.
- Give `shuttle` two bindings, run `kubectl auth can-i --list -n starfleet --as=system:serviceaccount:starfleet:shuttle` and read which rows come from which Role.
- Give `scout` a Role that only lists Secrets, then run `kubectl get secrets -n starfleet -o yaml --as=system:serviceaccount:starfleet:scout` and read the result.
- Try to change the `roleRef` of an existing binding with `kubectl edit` and read the error.
