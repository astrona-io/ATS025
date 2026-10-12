---
draft: true
exam_objectives:
- Create and manage Kubernetes clusters using kubeadm
---
# Create and manage Kubernetes clusters using kubeadm

A worker joins using bootstrap discovery, but later cannot report through the API. Joining and continued authenticated operation are different stages of the node lifecycle.

The explanations identify the responsible components, compare intended and observed state, and work through the decisions needed to preserve the requirement. Read the worked examples as reasoning about a proposed system; no environment is started by this section.

Each module begins with its goals and ends with a summary. Reusable YAML knowledge checks follow the section summary and are registered separately for future presentation.

## Learning Outcomes

- Distinguish initialization from worker or control-plane joining.
- Explain static manifests and runtime bootstrap.
- Evaluate discovery trust and temporary credentials.
- Identify the stage that blocks node readiness.
