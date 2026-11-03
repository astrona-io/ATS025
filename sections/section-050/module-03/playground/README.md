# Leader Election, Health Endpoints And Failure Behavior - Playground

- **Slug:** ats-025-playground-050-03
- **Type:** Astrona playground - clean environment, no task, no grading

A kind cluster (Kubernetes 1.35, pinned image) with one control-plane node and an empty starfleet namespace. The control plane Leases in kube-system can be read. Nothing to submit.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-050/module-03/playground
astrona destroy ats-025-playground-050-03
```

`astrona destroy` takes the environment name, not the path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `manifests/starfleet.yaml` | The empty starfleet namespace |
| `docs/overview.md` | What is in the environment and ideas to try |
