---
draft: true
exam_objectives:
- Implement and configure a highly-available control plane
---
# Inspect A Three-Member Control Plane Solution

Use a host shell with the private kubeconfig for this independent kind environment. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-025-lab-050-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-025-lab-050-01-01" || exit 1
node_name="astro-ats-025-lab-050-01-01-control-plane"
worker_name="astro-ats-025-lab-050-01-01-worker"
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

After recording your result, remove the independent lab with `astrona destroy ats-025-lab-050-01-01`.

## Common pitfalls

> [!WARNING]
> Confirm the private context and exact node names before a change. Check the stated scope and live result. Do not change unrelated components to hide the original fault.
