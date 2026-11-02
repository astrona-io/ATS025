---
draft: true
exam_objectives:
- Prepare underlying infrastructure for installing a Kubernetes cluster
---
# Prepare underlying infrastructure for installing a Kubernetes cluster

The installer starts, but nodes cannot reach the advertised API endpoint. Installation depends on a supported host, runtime and network contract before application objects can become useful.

The explanations identify the responsible components, compare intended and observed state, and work through the decisions needed to preserve the requirement. Read the worked examples as reasoning about a proposed system; no environment is started by this section.

Each module begins with its goals and ends with a summary. Reusable YAML knowledge checks follow the section summary and are registered separately for future presentation.

## Learning Outcomes

- Identify host identity and capacity prerequisites.
- Explain kubelet runtime compatibility.
- Plan non-overlapping network address ranges.
- Evaluate version, trust and required connectivity.
