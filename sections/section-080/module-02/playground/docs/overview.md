---
draft: true
exam_objectives:
- Understand CRDs, install and configure operators
---
# Overview: CRD Schema, Validation And Versions (Playground)

This is a playground, not a lab. It starts a clean cluster and then waits. There is no task, no `astrona submit` and no pass or fail. Read, change, break and start over.

## What is in the box

A `kind` cluster that runs Kubernetes 1.35 with one node. `kubectl` already points at it, as the cluster administrator.

| Item | What is in it |
| --- | --- |
| `starfleet` | An empty namespace for your custom objects |
| cluster scope | No custom resource definitions of your own |

## Practice tasks

- Write a CRD for a `Beacon` type with a `channel` enumeration and an `interval` range, and apply it.
- Run `kubectl api-resources --api-group=training.astrona.io` and read the short name and scope.
- Send an object with a bad channel using `kubectl apply --dry-run=server` and read the error.
- Add a `default` to `interval`, apply the CRD again, and read an old object to see the default appear.
- Add a CEL rule that uses `oldSelf` and try to change the protected field.
- Add a second, deprecated version and read the warning that `kubectl` prints.
- Read `status.storedVersions` of the CRD with `kubectl get crd -o jsonpath`.
- Enable the `status` subresource and try to write `status` through the main endpoint with `kubectl patch`.
- Add `additionalPrinterColumns` and compare the output of `kubectl get` before and after.
