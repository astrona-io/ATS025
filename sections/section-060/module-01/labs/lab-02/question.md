---
draft: true
exam_objectives:
- Use Helm and Kustomize to install cluster components
---
# Apply A Kustomize Base

Compose and apply a self-contained Kustomize base with a declared Pod label. Use the isolated `starfleet` environment to verify the result.

## Objective

Compose and apply a self-contained Kustomize base with a declared Pod label.

## Starting state

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-025-lab-060-01-02)"
test "$(kubectl config current-context)" = "kind-astro-ats-025-lab-060-01-02" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.


## Required result

Create a Kustomize base containing Deployment `probe` with two replicas and template label `environment: base`. Include a `kustomization.yaml` resource list and apply the base. Preserve the application configuration and original Service. The client must still receive version one.

## Verify The Result

The grader checks the stated resource fields and live evidence. Wait for controller convergence before submitting. Inspect actual results rather than relying on a sample transcript.
