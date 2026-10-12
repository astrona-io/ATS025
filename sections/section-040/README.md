---
draft: true
exam_objectives:
- Manage the lifecycle of Kubernetes clusters
---
# Manage the lifecycle of Kubernetes clusters

A node upgrade removes its ready application replicas, but the remaining nodes cannot host replacements. Version compatibility and maintenance availability are separate planning requirements.

The explanations identify the responsible components, compare intended and observed state, and work through the decisions needed to preserve the requirement. Read the worked examples as reasoning about a proposed system; no environment is started by this section.

Each module begins with its goals and ends with a summary. Reusable YAML knowledge checks follow the section summary and are registered separately for future presentation.

## Learning Outcomes

- Explain supported component-version and upgrade order.
- Distinguish cordon, drain and disruption policy.
- Evaluate datastore snapshot scope and restore prerequisites.
- Verify component and application recovery after lifecycle changes.
