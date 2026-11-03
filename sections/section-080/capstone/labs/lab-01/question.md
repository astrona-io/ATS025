---
draft: true
exam_objectives:
- Understand CRDs, install and configure operators
---
# Question

Solve this question on: `terminal`

The starfleet team wants to track missions as a custom type and to run an operator for it. The cluster has the namespaces `starfleet` and `mission-system` and a Deployment `mission-operator` in `mission-system`. The Deployment runs as the `default` ServiceAccount. The type does not exist yet.

Part A: the type.

1. Create the CustomResourceDefinition `missions.training.astrona.io` in the group `training.astrona.io`. Kind `Mission`, plural `missions`, namespaced, one version `v1` that is served and stored.
2. `spec.callSign` (string) and `spec.phase` (string) are required. `phase` must be one of `Planned`, `Active` or `Done`.
3. `spec.crewSize` is an integer from 1 through 20. When it is missing, the API server must set it to 3.
4. `spec.callSign` cannot be changed after an object is created. Use a validation rule in the Common Expression Language.
5. Enable the `status` subresource, and show two printer columns: `Phase` from `.spec.phase` and `Crew` from `.spec.crewSize`.

Part B: the operator.

6. Create the ServiceAccount `mission-operator` in `mission-system` and make the Deployment use it. The Deployment must be available.
7. Create a ClusterRole and a ClusterRoleBinding, both named `mission-operator`. The ServiceAccount must be able to get, list, watch, update and patch `missions` and `missions/status`, manage `leases` in the group `coordination.k8s.io`, and create and patch `events`. It must not use wildcards, and it must not be able to delete missions, read Secrets or delete nodes.

Part C: the first object.

8. Create a `Mission` named `apollo` in `starfleet` with `callSign: apollo-one` and `phase: Planned`. Leave `crewSize` out, so the default applies.

`kubectl` already points at the cluster as the cluster administrator.
