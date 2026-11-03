# kubeadm Upgrade Workflow And Version Skew - Playground

- **Slug:** ats-025-playground-040-02
- **Type:** Astrona playground - clean environment, no task, no grading

A kind cluster (Kubernetes 1.35, pinned image) with one control-plane node. Nothing to submit.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-040/module-02/playground
astrona destroy ats-025-playground-040-02
```

`astrona destroy` takes the environment name, not the path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `manifests/start.yaml` | The starfleet namespace and an empty upgrade-review record |
| `docs/overview.md` | What is in the environment and ideas to try |
