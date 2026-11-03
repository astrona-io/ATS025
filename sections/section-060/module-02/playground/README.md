# Helm Charts, Values And Releases - Playground

- **Slug:** ats-025-playground-060-02
- **Type:** Astrona playground - clean environment, no task, no grading

A kind cluster (Kubernetes 1.35, pinned image) with one node, an empty starfleet namespace and the busybox image preloaded. You bring your own helm binary and write the chart. Nothing to submit.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-060/module-02/playground
astrona destroy ats-025-playground-060-02
```

`astrona destroy` takes the environment name, not the path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `manifests/starfleet.yaml` | The empty starfleet namespace |
| `docs/overview.md` | What is in the environment and ideas to try |
