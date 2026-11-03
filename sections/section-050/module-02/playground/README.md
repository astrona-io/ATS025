# Control Plane Topology With kubeadm - Playground

- **Slug:** ats-025-playground-050-02
- **Type:** Astrona playground - clean environment, no task, no grading

A kind cluster (Kubernetes 1.35, pinned image) with one control-plane node and an empty starfleet namespace. The kubeadm objects in kube-system can be read. Nothing to submit.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-050/module-02/playground
astrona destroy ats-025-playground-050-02
```

`astrona destroy` takes the environment name, not the path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `manifests/starfleet.yaml` | The empty starfleet namespace |
| `docs/overview.md` | What is in the environment and ideas to try |
