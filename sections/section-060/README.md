---
draft: true
exam_objectives:
- Use Helm and Kustomize to install cluster components
---
# Use Helm and Kustomize to install cluster components

Administrators rarely write every cluster object by hand. They install components from Helm charts and customise plain YAML with Kustomize. This section explains what each tool does underneath: Helm renders templates on the client and keeps a revision record for every release, and Kustomize patches plain YAML and keeps no record. You learn to read what a tool will send to the API server, to change it safely and to undo a change.

## Learning Outcomes

- Name the files of a Helm chart, render it locally and trace a value into a rendered field.
- Install, upgrade, roll back and uninstall a Helm release, and read its history from the cluster.
- Explain why an upgrade can drop earlier values and how to prevent it.
- Build a Kustomize base and overlay, and use transformers, patches and generators.
- Render, compare, apply and delete a kustomization with `kubectl`.
- Adopt an object that exists without Helm into a release, and customise rendered chart output with Kustomize.

## Modules

1. Packaging Cluster Components: charts, values and the rendered application, and composing resources with Kustomize.
2. Helm Charts, Values And Releases: chart anatomy and rendering, values precedence and the release lifecycle.
3. Kustomize Overlays And Patches: bases, overlays and transformers, patches, generators and applying.

The section ends with a capstone lab that combines both tools and a short knowledge check.
