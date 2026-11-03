---
draft: true
exam_objectives:
- Understand CRDs, install and configure operators
---
# Question

Solve this question on: `terminal`

The starfleet platform team runs a custom type `Beacon` in the group `training.astrona.io`. The CustomResourceDefinition `beacons.training.astrona.io` accepts any content, so bad data reaches etcd. One object, `legacy-beacon`, is already stored in the `starfleet` namespace.

Change the CRD so that the API server enforces these rules for version `v1`, which must stay the served and storage version:

1. `spec.channel` is required and is a string that must be one of `alpha`, `beta` or `gamma`.
2. `spec.interval` is an integer from 5 through 3600. When it is missing, the API server must set it to 60.
3. `spec.channel` cannot be changed after an object is created. `spec.interval` can be changed. Use a validation rule written in the Common Expression Language.
4. `kubectl get beacons` shows two additional columns that read `.spec.channel` and `.spec.interval`.
5. The `status` subresource is enabled for `v1`.

Keep the name of the CRD, its group, kind, plural and scope. Do not delete the CRD, because that would delete `legacy-beacon`. `kubectl` already points at the cluster as the cluster administrator.
