---
draft: true
exam_objectives:
- Implement and configure a highly-available control plane
---
# Summary

Resilient management needs an available API path, working control-plane responsibilities and a datastore majority under the intended failure scenario. Replicating one process does not remove every shared dependency.

Topology determines whether one machine loss removes several responsibilities at once. Application availability remains a separate design involving usable replicas, dependencies and data recovery.

Frontend redundancy and datastore consensus protect different dependencies in one useful API operation.
