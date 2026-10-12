---
draft: true
exam_objectives:
- Implement and configure a highly-available control plane
---
# Implement and configure a highly-available control plane

Two datastore members in a three-member cluster can maintain quorum, but one cannot. Adding an API load balancer does not change that consensus requirement.

The explanations identify the responsible components, compare intended and observed state, and work through the decisions needed to preserve the requirement. Read the worked examples as reasoning about a proposed system; no environment is started by this section.

Each module begins with its goals and ends with a summary. Reusable YAML knowledge checks follow the section summary and are registered separately for future presentation.

## Learning Outcomes

- Explain stable API access and backend health.
- Compare stacked and external datastore topology.
- Calculate majority quorum and failure tolerance.
- Distinguish management-plane from application availability.
