---
draft: true
exam_objectives:
- Manage role based access control (RBAC)
---
# Manage role based access control (RBAC)

A RoleBinding grants a reusable ClusterRole only inside the binding's namespace. Its reference to a cluster-scoped role definition does not make the grant cluster-wide. Read the binding scope and subject together.

The explanations identify the responsible components, compare intended and observed state, and work through the decisions needed to preserve the requirement. Read the worked examples as reasoning about a proposed system; no environment is started by this section.

Each module begins with its goals and ends with a summary. Reusable YAML knowledge checks follow the section summary and are registered separately for future presentation.

## Learning Outcomes

- Explain roles, bindings and scope.
- Evaluate additive effective grants.
- Identify indirect privilege through workload creation.
- Choose least privilege for an administrative responsibility.
