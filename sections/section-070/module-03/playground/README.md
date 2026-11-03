# Storage Through CSI - Playground

- **Slug:** ats-025-playground-070-03
- **Type:** Astrona playground - clean environment, no task, no grading

A kind cluster (Kubernetes 1.35, pinned image) with one node and an empty starfleet namespace. Only the default StorageClass of kind exists. Nothing to submit.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c module-03/playground
astrona destroy ats-025-playground-070-03
```

`astrona destroy` takes the environment name, not the path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `manifests/starfleet.yaml` | The empty starfleet namespace |
| `docs/overview.md` | What is in the environment and ideas to try |
