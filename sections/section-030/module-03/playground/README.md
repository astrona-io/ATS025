# PKI Files, Bootstrap Tokens And Joining Nodes - Playground

- **Slug:** ats-025-playground-030-03
- **Type:** Astrona playground - clean environment, no task, no grading

A kind cluster (Kubernetes 1.35, pinned image) with one control-plane node and one worker. Nothing to submit.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c playground
astrona destroy ats-025-playground-030-03
```

`astrona destroy` takes the environment name, not the path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `manifests/starfleet.yaml` | The starfleet namespace and the probe Deployment |
| `docs/overview.md` | What is in the environment and ideas to try |
