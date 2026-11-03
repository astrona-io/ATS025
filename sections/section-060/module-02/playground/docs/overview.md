---
draft: true
exam_objectives:
- Use Helm and Kustomize to install cluster components
---
# Overview: Helm Charts, Values And Releases (Playground)

This is a playground, not a lab. It starts a cluster and then waits. There is no task, no `astrona submit` and no pass or fail. Write charts, break them, install them and start over.

## What is in the box

A `kind` cluster that runs Kubernetes 1.35 with one node. `kubectl` already points at it, as the cluster administrator. The image `docker.io/library/busybox:1.37.0` is loaded into the node, so a chart that uses it starts without a registry. The `helm` command runs on your own machine and uses the same kubeconfig as `kubectl`.

| Item | What is in it |
| --- | --- |
| `starfleet` | An empty namespace for your releases |
| Helm releases | None. Helm keeps each release as Secrets in the release namespace |

## Practice tasks

- Run `helm create shuttle` and read every generated file. Remove what you do not need.
- Render a chart with `helm template` and change one value with `--set`. Find the changed field in the output.
- Install a release, then list the Secrets with the label `owner=helm` in the namespace of the release.
- Upgrade a release without `--reuse-values` and watch a value return to the chart default.
- Run `helm get values`, `helm get manifest` and `helm history` and say what each one reads.
- Roll back to revision 1 and read the description of the new revision.
- Break a template on purpose (a missing `end`) and read the error from `helm lint`.
- Apply a Deployment with `kubectl`, then try to install a chart that creates the same name and read the ownership error.
- Uninstall a release and confirm that its Secrets and objects are gone.
