---
draft: true
exam_objectives:
- Manage role based access control (RBAC)
---
# Cluster-Scoped Access: ClusterRoles, Non-Resource URLs And Escalation Prevention

A Role works only inside one namespace. Some things the cluster stores do not live in a namespace at all: nodes, PersistentVolumes, namespaces themselves. Other requests do not touch a stored object, for example a request for the `/metrics` page of the API server. A Role cannot grant any of these. This module covers the objects that can: ClusterRoles and ClusterRoleBindings.

Keep one sentence in mind: **a ClusterRole is a list of rules, and the kind of binding decides where those rules apply.** You will give a ServiceAccount read access to nodes and PersistentVolumes, find out why a namespaced binding cannot do that, allow a single non-resource URL, read the built-in roles and see how the API server stops a user from handing out permissions that the user does not hold.

## Learning objectives

After this module you can:

- List the cluster-scoped resource types and say which of them need a ClusterRole.
- Create a ClusterRole and a ClusterRoleBinding, with `kubectl create` and from YAML, for cluster-scoped resources.
- Explain what a RoleBinding that points at a ClusterRole grants and what it cannot grant.
- Allow a non-resource URL with `nonResourceURLs` and check it with `kubectl auth can-i`.
- Read `kubectl auth can-i --list` and name the built-in roles `cluster-admin`, `admin`, `edit` and `view`.
- Explain the verbs `escalate`, `bind` and `impersonate` and the rule that stops a user from granting more than the user holds.

## Before you start

You need Kubernetes basics: namespaces, ServiceAccounts, Roles and RoleBindings, and the commands `kubectl get`, `kubectl apply` and `kubectl auth can-i`. You know that a Role and a RoleBinding work inside one namespace.

Your playground is a single-node `kind` cluster running Kubernetes 1.35:

| Where | What is in it |
| --- | --- |
| `starfleet` | ServiceAccount `scout` with no permissions, ServiceAccount `rolemaker` that may create Roles and RoleBindings in this namespace, and a Secret `warp-key` |
| cluster | Two PersistentVolumes, `pv-starfleet-a` and `pv-starfleet-b`, and the node |
| `outpost` | The `drifter` client |

No ClusterRole or ClusterRoleBinding of the course exists yet. `kubectl` already points at the playground cluster, as the cluster administrator.

The module has three parts. The first creates cluster-scoped grants. The second covers non-resource URLs and the built-in roles. The third covers the rules that limit who may create and bind roles.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
