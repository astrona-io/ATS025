---
draft: true
exam_objectives:
- Understand CRDs, install and configure operators
---
# Understand CRDs, install and configure operators

The custom `ProbeSetting` requests one message, but its status has not yet observed the latest generation. A status value must be interpreted through the installed controller contract. Merely seeing a field named ready does not make it control Service traffic.

The explanations identify the responsible components, compare intended and observed state, and work through the decisions needed to preserve the requirement. The section has three modules. The first reads a custom resource and the controller contract behind it. The second covers the CustomResourceDefinition itself: schema, defaults, pruning, validation rules, versions, subresources and printer columns. The third installs and configures an operator: its objects, install order, permissions, status, finalizers and removal. Every module has a playground and a graded lab, and the section closes with a capstone lab and a knowledge check.

Each module begins with its goals and ends with a summary.

## Learning Outcomes

- Explain custom schema registration and discovery.
- Distinguish controller installation from desired-instance acceptance.
- Evaluate controller permissions and dependencies.
- Interpret status, versions and cleanup contracts.
- Write a CRD with a structural schema, defaults and validation rules.
- Explain served and storage versions, conversion and stored versions.
- Install an operator in a safe order and bind least-privilege permissions.
- Explain finalizers and what deleting a CRD removes.
