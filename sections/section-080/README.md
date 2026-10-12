---
draft: true
exam_objectives:
- Understand CRDs, install and configure operators
---
# Understand CRDs, install and configure operators

The custom `ProbeSetting` requests one message, but its status has not yet observed the latest generation. A status value must be interpreted through the installed controller contract. Merely seeing a field named ready does not make it control Service traffic.

The explanations identify the responsible components, compare intended and observed state, and work through the decisions needed to preserve the requirement. Read the worked examples as reasoning about a proposed system; no environment is started by this section.

Each module begins with its goals and ends with a summary. Reusable YAML knowledge checks follow the section summary and are registered separately for future presentation.

## Learning Outcomes

- Explain custom schema registration and discovery.
- Distinguish controller installation from desired-instance acceptance.
- Evaluate controller permissions and dependencies.
- Interpret status, versions and cleanup contracts.
