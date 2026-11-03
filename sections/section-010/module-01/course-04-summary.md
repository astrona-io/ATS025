---
draft: true
exam_objectives:
- Manage role based access control (RBAC)
---
# Summary

The API server refuses every request that no rule allows. A Role is a list of rules for one namespace. Each rule holds three lists that must all match the request: the API group, the resource and the verb. The core group is written as an empty string. A subresource such as `pods/log` is a separate resource, and the optional `resourceNames` list limits a rule to named objects only for the verbs that carry a name.

A RoleBinding connects one role to a list of subjects and applies the rules in its own namespace. A subject is a ServiceAccount, a user or a group. A ServiceAccount subject needs its namespace. The reference to the role cannot be changed after creation, so a new target needs a new binding. A RoleBinding can point at a ClusterRole to reuse one definition, and the grant still stays in the namespace of the binding.

RBAC has no deny rule. The effective permissions of an identity are the union of every rule in every binding that names its user, its groups or its ServiceAccount, including bindings that built-in groups bring. Removing a permission means removing every grant that gives it.

Some verbs reach further than they say. Reading or listing Secrets returns their data. Creating pods lets the caller choose what the pod mounts and which ServiceAccount it uses. Running commands in a container can reach the tokens mounted there. Least privilege chooses exact verbs, exact resources and the smallest namespace, and it tests the denied actions as well as the allowed ones.

- A Role grants nothing until a binding names it.
- A binding applies only in its own namespace.
- Grants only add up; they never cancel each other.

<!-- astrona:playground:destroy -->
