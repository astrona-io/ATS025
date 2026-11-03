---
draft: true
exam_objectives:
- Implement and configure a highly-available control plane
---
# Guided Practice: Inspect A Three-Member Control Plane

Use a host shell with the private kubeconfig for this module playground. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool.

<!-- astrona:playground:renew -->

```sh
export KUBECONFIG="$(astrona kubeconfig ats-025-playground-050-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-025-playground-050-01" || exit 1
node_name="astro-ats-025-playground-050-01-control-plane"
worker_name="astro-ats-025-playground-050-01-worker"
```

Keep this connection selected. Host-level commands name only this environment's node containers. They do not operate on the host operating system.

## Inspect And Explain

The isolated environment has two healthy probe replicas, an internal Service and two client Pods. The required result has not been configured.

Inspect the current objects before changing them:

```sh
kubectl -n starfleet get pods -o wide
kubectl get nodes -o wide
```

Inspect the three-member stacked etcd cluster in this private environment. Record ConfigMap quorum-review with members three and majority two. All three control-plane nodes and their etcd Pods must remain Ready, the member list must contain three members, and the shared API endpoint must be ready. This observes a local high-availability topology; it does not simulate independent physical failure domains.

Save this as `configmap-quorum-review.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: quorum-review
  namespace: starfleet
data:
  members: '3'
  majority: '2'
```

Apply the scoped correction:

```sh
kubectl apply -f configmap-quorum-review.yaml
```

## Verify The Result

Observe the actual result. A denied request returns a nonzero status when the denial works, so run it separately from a shell sequence that stops on error. Status convergence and a successful request establish different parts of the result.

```sh
kubectl get --raw=/readyz
```

Relate actual datastore membership to majority requirements and API availability. The commands above deliberately target one environment. Keep its remaining components available so an unrelated failure cannot stand in for the required denial or correction. No example command output is presented as evidence of a completed run. A matching field alone does not establish that a process used it or that a controller reconciled it.


## Compare The Control Plane With Your Notes

Repeat the reads and compare them with what you wrote down. Each command only reads state.

```sh
kubectl get nodes -l node-role.kubernetes.io/control-plane -o wide
kubectl -n kube-system get pods -o wide
kubectl -n kube-system get configmap kubeadm-config -o yaml
```

The node list shows which hosts carry the control plane role. The kube-system list shows the static Pods that run on them. The kubeadm configuration map holds the cluster configuration that was used at setup, so it is the place to confirm the endpoint and the datastore layout. If your notes and the cluster disagree, trust the cluster and correct the notes.

## Check The Health Endpoints

The API server reports its own health, and the report names each internal check.

```sh
kubectl get --raw='/livez?verbose'
kubectl get --raw='/readyz?verbose'
kubectl get --raw='/readyz?verbose' | grep -i etcd
```

The liveness endpoint says whether the process is alive. The readiness endpoint says whether it can serve requests, and the verbose form lists every check by name. The last command narrows the list to the datastore check. A failing datastore check means the API server cannot reach its storage, which is the first place to look when requests fail.

## Common pitfalls

> [!WARNING]
> Confirm the private context and exact node names before a change. Check the stated scope and live result. Do not change unrelated components to hide the original fault.
