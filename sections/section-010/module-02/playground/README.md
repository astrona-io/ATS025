# Users, Client Certificates And ServiceAccount Tokens — Playground

- **ID:** PLAYGROUND
- **Slug:** ats-025-playground-010-02
- **Type:** Astrona playground — clean environment, no task, no grading

A single-node kind cluster (Kubernetes 1.35) with the Starfleet workloads
(`scout` and `shuttle` in `starfleet`, `drifter` in `outpost`), the ServiceAccounts
`shuttle`, `probe` (token mounting switched off) and `drifter`, and no Role or
RoleBinding. Nothing to submit.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run -c .
astrona destroy ats-025-playground-010-02
```

`astrona destroy` takes the environment name (`metadata.name`), not the config
path. `astrona submit` and `astrona test` do not apply: there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/starfleet.yaml` | Namespaces, ServiceAccounts and the example workloads |
| `docs/overview.md` | What the environment contains and ideas to try |
