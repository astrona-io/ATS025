---
draft: true
exam_objectives:
- Use Helm and Kustomize to install cluster components
---
# Kustomize Overlays And Patches

Kustomize customises plain Kubernetes YAML without templates. You keep a base set of manifests and describe the differences for each environment in a `kustomization.yaml` file. The tool reads the base, applies the changes and prints complete YAML. Kustomize is built into `kubectl`, so you can use it on any cluster with no extra install.

Keep one idea in mind: **Kustomize never edits your base files. It reads them, applies named transformations in memory and prints the result.** The base stays valid YAML that you can apply on its own, and every environment is a small directory that points at it.

The module has two parts. The first part builds a base and an overlay, and uses the transformers that set the namespace, names, labels, images and replica counts. The second part changes any field with patches, generates ConfigMaps with a content hash, and applies, compares and deletes the result with `kubectl`.

## Learning objectives

After this module you can:

- Describe a base and an overlay and the files in each directory.
- Render a kustomization with `kubectl kustomize` and apply it with `kubectl apply -k`.
- Use the namespace, name prefix, label, image and replica transformers.
- Choose between a strategic merge patch and a JSON 6902 patch, and write both.
- Generate a ConfigMap, and explain the hash suffix and how references are rewritten.
- Compare Kustomize with Helm: no templates, no release record, no revision history.

## Before you start

You need Kubernetes basics: Deployments, Services, labels and selectors, and `kubectl apply`. You need no extra tool, because `kubectl` contains Kustomize. The version inside `kubectl` can differ from the stand-alone `kustomize` command, so the examples use only features that both support.

Your playground runs Kubernetes 1.35 with one node:

| Item | What is in it |
| --- | --- |
| `starfleet` | An empty namespace |
| `outpost` | An empty namespace |
| Image | `docker.io/library/busybox:1.37.0` is loaded into the node |

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
