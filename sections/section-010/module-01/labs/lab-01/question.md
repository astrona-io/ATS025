---
draft: true
exam_objectives:
- Manage role based access control (RBAC)
---
# Grant A ServiceAccount Pod Read Access With A Role — Task

The `shuttle` ServiceAccount in `starfleet` must be able to read the pods of its own namespace, and nothing else. An earlier change also gave it a binding in `outpost`. Give `shuttle` exactly the access it needs.

## Starting state

The namespaces `starfleet` and `outpost`, the ServiceAccount `shuttle` in `starfleet` and the Secret `warp-key` exist. A RoleBinding named `shuttle-helper` in `outpost` gives `shuttle` the built-in `edit` ClusterRole there. No Role exists for this task. `kubectl` points at the lab cluster as the cluster administrator.

## Required result

1. Create a Role named `pod-reader` in `starfleet`. It has one rule that allows `get`, `list` and `watch` on the core resource `pods`.
2. Create a RoleBinding named `shuttle-pod-reader` in `starfleet`. It binds the Role `pod-reader` to the ServiceAccount `shuttle` in `starfleet` and to no other subject.
3. Remove every other grant that gives `shuttle` access.
4. In `starfleet`, `shuttle` can get, list and watch pods. It cannot create, patch or delete pods, cannot read pod logs, cannot read Secrets or ConfigMaps and cannot list Deployments. In `outpost` and at cluster scope it can do nothing.

Do not use a wildcard (`*`) in any rule, do not bind a built-in role, and do not create a ClusterRoleBinding for `shuttle`.

## Verify the result

Check the access with `kubectl auth can-i` and the flag `--as=system:serviceaccount:starfleet:shuttle`. Find the leftover grant with `kubectl get rolebindings -A`. The grader checks the Role, the binding and the effective permissions. Run `astrona submit` when you are ready.
