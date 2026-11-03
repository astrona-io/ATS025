---
draft: true
exam_objectives:
- Use Helm and Kustomize to install cluster components
---
# Overview: Kustomize Overlays And Patches (Playground)

This is a playground, not a lab. It starts a cluster and then waits. There is no task, no `astrona submit` and no pass or fail. Write kustomizations, render them, apply them and start over.

## What is in the box

A `kind` cluster that runs Kubernetes 1.35 with one node. `kubectl` already points at it, as the cluster administrator. Kustomize is built into `kubectl`, so you need no extra tool. The image `docker.io/library/busybox:1.37.0` is loaded into the node.

| Item | What is in it |
| --- | --- |
| `starfleet` | An empty namespace |
| `outpost` | An empty namespace |

## Practice tasks

- Write a base with a Deployment and a Service, then render it with `kubectl kustomize`.
- Add an overlay that sets a namespace and a name prefix, and compare the rendered output with the base.
- Change the replica count with a strategic merge patch, then again with a JSON 6902 patch.
- Add a ConfigMap with `configMapGenerator`, change one literal and watch the name suffix change.
- Run `kubectl diff -k` before `kubectl apply -k` and read what would change.
- Add a label with `includeSelectors: true` after the Deployment exists and read the error.
- Delete the objects with `kubectl delete -k` and check that the generated ConfigMap is gone too.
