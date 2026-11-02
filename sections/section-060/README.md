---
draft: true
exam_objectives:
- Use Helm and Kustomize to install cluster components
---
# Use Helm and Kustomize to install cluster components

Setting `replicaCount: 3` changes an application only if its chart template reads that value. Helm values are chart inputs, not Kubernetes fields. Tracing them into rendered resources prevents a plausible-looking override from being mistaken for an effective change.

The explanations identify the responsible components, compare intended and observed state, and work through the decisions needed to preserve the requirement. Read the worked examples as reasoning about a proposed system; no environment is started by this section.

Each module begins with its goals and ends with a summary. Reusable YAML knowledge checks follow the section summary and are registered separately for future presentation.

## Learning Outcomes

- Explain chart values and rendered installation resources.
- Distinguish package release from application health.
- Review composition, references and resource transformations.
- Evaluate component permissions and version requirements.
