---
draft: true
exam_objectives:
- Understand CRDs, install and configure operators
---
# Question

Solve this question on: `terminal`

The starfleet team installed the CRD `beacons.training.astrona.io` and a Deployment `beacon-operator` in the namespace `beacon-system`. The Deployment still runs as the `default` ServiceAccount, so the operator has no identity of its own and no permissions. Finish the install with the least privilege that the controller needs.

1. Create the ServiceAccount `beacon-operator` in `beacon-system`, and make the Deployment `beacon-operator` use it. The Deployment must be available after the change.
2. Create a ClusterRole `beacon-operator` and a ClusterRoleBinding `beacon-operator` that bind it to the ServiceAccount. The ServiceAccount must be able to:
   - get, list, watch, update and patch `beacons` in the group `training.astrona.io`;
   - get, update and patch the `status` of `beacons`;
   - get, list, watch, create, update and patch `leases` in the group `coordination.k8s.io`;
   - create and patch `events`.
3. The role must not use any wildcard. The ServiceAccount must not be able to delete beacons, delete nodes, read Secrets or create Deployments.
4. Set the environment variable `WATCH_NAMESPACE` to `starfleet` on the operator container.
5. Create a `Beacon` named `first-beacon` in the namespace `starfleet` with `spec.channel` set to `alpha`.

Do not change the CRD. `kubectl` already points at the cluster as the cluster administrator.
