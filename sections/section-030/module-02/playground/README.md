# kubeadm Configuration Files And Init Phases - Playground

- **Slug:** ats-025-playground-030-02
- **Type:** Astrona playground, clean environment, no task, no grading

A kind cluster (Kubernetes 1.35, pinned node image) with one control-plane node and one worker. The ConfigMaps `kubeadm-config` and `kubelet-config` come from kubeadm itself. `starfleet` holds a `probe` Deployment and a draft `kubeadm-plan` ConfigMap.

Status: UNTESTED. Built with static checks only; never run.

## Run it

```sh
astrona run -c .
astrona destroy ats-025-playground-030-02
```

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `manifests/starfleet.yaml` | Namespaces, the `probe` Deployment and the draft `kubeadm-plan` ConfigMap |
| `docs/overview.md` | What is in the environment and ideas to try |
