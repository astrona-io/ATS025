# Installing And Configuring An Operator - Playground

- **Slug:** ats-025-playground-080-03
- **Type:** Astrona playground - clean environment, no task, no grading

A kind cluster (Kubernetes 1.35, pinned image) with one node, the Beacon CRD and a stand-in operator Deployment. Nothing to submit.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c playground
astrona destroy ats-025-playground-080-03
```

`astrona destroy` takes the environment name, not the path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `manifests/operator.yaml` | The CRD, the namespaces and the stand-in operator |
| `docs/overview.md` | What is in the environment and ideas to try |
