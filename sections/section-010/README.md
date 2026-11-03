---
draft: true
exam_objectives:
- Manage role based access control (RBAC)
---
# Manage role based access control (RBAC)

Role-Based Access Control (RBAC) is the part of the Kubernetes API server that decides whether an identity may do an action. By default the API server refuses every request that no rule allows. This section teaches how to write the rules, how to connect them to people and workloads, and how to keep each grant as small as the job.

The section has three modules. Each one has a short landing page, deep-dive reading parts, a playground for free practice, a graded lab and a summary. The section ends with a capstone lab that joins all three modules, and a knowledge check.

## Modules

1. **Roles, RoleBindings And Least Privilege.** Roles, rules, verbs, subjects, RoleBindings, why grants only add up and which grants give indirect access to credentials.
2. **Users, Client Certificates And ServiceAccount Tokens.** Client certificates and the `CertificateSigningRequest` flow, kubeconfig files, granting access to a user group and ServiceAccount tokens.
3. **Cluster-Scoped Access: ClusterRoles, Non-Resource URLs And Escalation Prevention.** ClusterRoles and ClusterRoleBindings, non-resource URLs, the built-in roles and the rules that stop a user from granting more than the user holds.

The capstone lab rebuilds the access of three identities in one cluster. The knowledge check holds twelve single-choice questions that cover all three modules.

## Learning Outcomes

- Write a Role or ClusterRole with the right API group, resource and verbs, and bind it with a RoleBinding or ClusterRoleBinding.
- Explain why a RoleBinding that points at a ClusterRole stays inside one namespace.
- Evaluate the effective permissions of an identity, knowing that grants add up and that RBAC has no deny rule.
- Create a client certificate request, approve it and give the resulting user or group access.
- Control ServiceAccount tokens and the automounting of tokens into pods.
- Grant access to cluster-scoped resources and non-resource URLs.
- Explain escalation prevention and the verbs `escalate`, `bind` and `impersonate`.
- Choose the least privilege for a task and test both the allowed and the denied actions with `kubectl auth can-i`.
