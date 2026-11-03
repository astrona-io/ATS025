# Cluster-Scoped Access — Playground

- **ID:** PLAYGROUND
- **Slug:** ats-025-playground-010-03
- **Type:** Astrona playground — clean environment, no task, no grading

A single-node kind cluster (Kubernetes 1.35) with ServiceAccounts `scout` (no
rights) and `rolemaker` (may create Roles and RoleBindings in `starfleet`), a
Secret, two PersistentVolumes and a `drifter` client in `outpost`. Nothing to
submit.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run -c .
astrona destroy ats-025-playground-010-03
```

`astrona destroy` takes the environment name (`metadata.name`), not the config
path. `astrona submit` and `astrona test` do not apply: there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/starfleet.yaml` | Namespaces, ServiceAccounts, Secret, PersistentVolumes and the `rbac-editor` Role |
| `docs/overview.md` | What the environment contains and ideas to try |
