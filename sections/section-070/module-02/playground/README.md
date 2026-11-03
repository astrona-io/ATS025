# Pod Networking Through CNI - Playground

- **Slug:** ats-025-playground-070-02
- **Type:** Astrona playground - clean environment, no task, no grading

A kind cluster (Kubernetes 1.35, pinned image) with one node, a probe workload and client pods in two namespaces. No NetworkPolicy exists yet. Nothing to submit.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c module-02/playground
astrona destroy ats-025-playground-070-02
```

`astrona destroy` takes the environment name, not the path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `manifests/starfleet.yaml` | The starfleet and outpost namespaces, a probe Deployment and Service, and two client pods |
| `docs/overview.md` | What is in the environment and ideas to try |
