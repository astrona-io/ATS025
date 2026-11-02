---
draft: true
exam_objectives:
- Use Helm and Kustomize to install cluster components
---
# Starting Environment

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Create a Kustomize base containing Deployment `probe` with two replicas and template label `environment: base`. Include a `kustomization.yaml` resource list and apply the base. Preserve the application configuration and original Service. The client must still receive version one.
