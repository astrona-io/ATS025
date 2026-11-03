# Packages, Ports And kubeadm Preflight Checks - Playground

- **Slug:** ats-025-playground-020-03
- **Type:** Astrona playground - clean environment, no task, no grading

A single-node kind cluster (Kubernetes 1.35, pinned `kindest/node` image) with an empty `control-plane-ports` record in `starfleet`. Nothing to submit.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-020/module-03/playground
astrona destroy ats-025-playground-020-03
```

`astrona destroy` takes the environment name, not the path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `manifests/start.yaml` | Namespace `starfleet` and the `control-plane-ports` ConfigMap |
| `docs/overview.md` | What the environment contains and ideas to try |
