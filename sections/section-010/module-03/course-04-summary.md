---
draft: true
exam_objectives:
- Manage role based access control (RBAC)
---
# Summary

A ClusterRole is a list of rules with no reach of its own. The binding decides the reach. A ClusterRoleBinding applies the rules in the whole cluster, including cluster-scoped resources such as nodes and PersistentVolumes. A RoleBinding that points at a ClusterRole applies the rules only inside its own namespace, and it can never grant a cluster-scoped resource.

Some requests are not about stored objects. A non-resource URL such as `/metrics` is granted with `nonResourceURLs` in a ClusterRole that a ClusterRoleBinding binds. The star works only at the end of a path. Every caller already reads the basic health and version paths through a default role, so a grant for a path must first be checked against what the account already has.

The cluster ships with `cluster-admin`, `admin`, `edit` and `view`. Each name hides exceptions, so read the rules before binding. The prefix `system:` belongs to Kubernetes, and groups under it can carry full control.

The API server stops a user from raising its own access. A user may write a role only with permissions the user holds, and may bind a role only if the user holds its permissions. The verbs `escalate` and `bind` lift those checks, and `impersonate` lets a caller act as another identity. All three need `resourceNames` to stay narrow. Reading Secrets, creating pods, requesting tokens and using wildcards can each reach more than they appear to.

- A binding that names the wrong namespace matches nobody.
- Permissions only add up, and nothing denies.
- Check every grant with a real `can-i` question from the identity.

<!-- astrona:playground:destroy -->
