# Kustomize Overlays And Patches - Playground

- **Slug:** ats-025-playground-060-03
- **Type:** Astrona playground - clean environment, no task, no grading

A kind cluster (Kubernetes 1.35, pinned image) with one node, empty starfleet and outpost namespaces and the busybox image preloaded. kubectl already contains Kustomize. Nothing to submit.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-060/module-03/playground
astrona destroy ats-025-playground-060-03
```

`astrona destroy` takes the environment name, not the path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `manifests/namespaces.yaml` | The empty starfleet and outpost namespaces |
| `docs/overview.md` | What is in the environment and ideas to try |
