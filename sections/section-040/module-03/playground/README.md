# etcd Restore And Recovery - Playground

- **Slug:** ats-025-playground-040-03
- **Type:** Astrona playground - clean environment, no task, no grading

A kind cluster (Kubernetes 1.35, pinned image) with one control-plane node and the etcd static pod. Nothing to submit.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-040/module-03/playground
astrona destroy ats-025-playground-040-03
```

`astrona destroy` takes the environment name, not the path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `manifests/start.yaml` | The starfleet namespace, an empty etcd-recovery record and the probe Deployment |
| `docs/overview.md` | What is in the environment and ideas to try |
