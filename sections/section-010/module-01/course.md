---
draft: true
exam_objectives:
- Manage role based access control (RBAC)
---
# Roles, RoleBindings And Least Privilege

By default the API server refuses every request that no rule allows. Role-Based Access Control (RBAC) is the part of Kubernetes that holds those rules. A `Role` lists what may be done to which resources in one namespace. A `RoleBinding` connects that list to the users, groups or ServiceAccounts that may use it. This module shows how each object works, how the API server combines them and how to keep a grant as small as the job.

Keep one sentence in mind: **RBAC only adds permissions, and a request is allowed when at least one rule from at least one binding matches it.** You will write a Role, bind it to a ServiceAccount, check the result with `kubectl auth can-i`, add a second grant to see that grants add up and find a grant that looks harmless but gives access to credentials.

## Learning objectives

After this module you can:

- Write a Role with `apiGroups`, `resources`, `verbs` and `resourceNames`, with `kubectl create role` and from YAML.
- Create a RoleBinding for a ServiceAccount, a user and a group, and explain why the `roleRef` cannot be edited.
- Explain why RBAC has no deny rule and how several bindings add up to the effective permissions.
- Check what an identity may do with `kubectl auth can-i`, with `--list` and with `--as`.
- Name the grants that give indirect access, such as reading Secrets or creating pods, and choose a narrower grant.

## Before you start

You need Kubernetes basics: namespaces, pods, ServiceAccounts and the commands `kubectl get`, `kubectl apply` and `kubectl describe`.

Your playground is a single-node `kind` cluster running Kubernetes 1.35:

| Namespace | What is in it |
| --- | --- |
| `starfleet` | ServiceAccounts `shuttle` and `scout` with no permissions, the `scout` Deployment and a Secret `warp-key` |
| `outpost` | The `drifter` Deployment |

No Role or RoleBinding of the course exists yet. `kubectl` already points at the playground cluster, as the cluster administrator.

The module has three parts. The first writes a Role. The second binds it to identities. The third looks at grants that add up and at grants that give more than they seem to.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
