---
draft: true
exam_objectives:
- Use Helm and Kustomize to install cluster components
---
# Helm Charts, Values And Releases

Helm is a package manager for Kubernetes. A package is called a chart: a directory of templates and default values. Helm combines a chart with your values, renders plain Kubernetes YAML and sends it to the API server. The record of one installation is called a release. This module shows what is inside a chart, how values reach the rendered objects, and how Helm installs, upgrades and rolls back a release.

Keep one idea in mind: **Helm is a client-side template engine plus a record keeper.** The `helm` command renders the YAML on your machine and stores a copy of every revision as a Secret in the cluster. No Helm server runs in the cluster, so everything Helm knows about a release is in those Secrets and in the objects it created.

The module has two parts. The first part opens a chart, renders it with `helm template` and follows a value into a field. The second part installs the chart as a release, changes it with values, reads the revision history and rolls back.

## Learning objectives

After this module you can:

- Name the files of a chart and say what each one does.
- Render a chart locally and trace a value from `values.yaml` or `--set` into a rendered field.
- State the order in which value sources override each other.
- Install, upgrade, roll back and uninstall a release, and read its history.
- Find where Helm stores a release and explain why a release can be `deployed` while the application is unhealthy.
- Explain why `helm upgrade` can silently reset values, and how to prevent it.

## Before you start

You need Kubernetes basics: Deployments, Services, namespaces and `kubectl apply`. You also need the `helm` command, version 3 or later, on your machine. Rendering a chart needs no cluster. Installing needs one, and the playground provides it.

Your playground runs Kubernetes 1.35 with one node:

| Item | What is in it |
| --- | --- |
| `starfleet` | An empty namespace for your releases |
| Image | `docker.io/library/busybox:1.37.0` is loaded into the node |

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
