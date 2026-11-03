---
draft: true
exam_objectives:
- Understand CRDs, install and configure operators
---
# Configuring, Status, Finalizers And Removal

An installed operator is configured in two places: the settings of the operator itself, such as flags and environment variables on its Deployment, and the custom resources that users create for it. After the install, an administrator reads status to see whether the operator accepted a resource, and later upgrades or removes the operator. Removal is where most damage happens, because deleting the wrong object also deletes the data that custom resources hold. This part covers each of these.

## Two layers of configuration

The settings of the operator program belong on its Deployment: container arguments, environment variables, resource requests, the number of replicas and the image tag. Changing them restarts the pods through a normal rollout.

```sh
kubectl -n beacon-system set env deployment/beacon-operator WATCH_NAMESPACE=starfleet
kubectl -n beacon-system rollout status deployment/beacon-operator --timeout=120s
```

<!-- astrona:playground:renew -->

The first command adds an environment variable to the pod template, which creates a new ReplicaSet. The second waits for the new pod to become available. Some operators take their settings from a ConfigMap or from a custom resource of their own instead. The documentation of each operator names the place.

The behavior for one workload belongs in a custom resource. A user creates a `Beacon` in `starfleet` and the operator reads its `spec`. This split lets cluster administrators control the operator while application teams control their own resources through the custom type.

## Replicas and leader election

An operator with more than one replica runs a leader election. All replicas watch and cache objects, but only the one that holds a Lease acts. The Lease is a normal object in the `coordination.k8s.io` group:

```sh
kubectl -n beacon-system get lease
```

The `HOLDER` column shows the pod that is currently the leader. If the leader pod stops, the Lease expires after its duration, and another replica takes over. This is why the role needs permissions for `leases`. A second replica only adds availability; it does not add throughput, because one leader does the work.

## Reading status and conditions

A controller reports what it did in the `status` of the object. The convention is a list named `conditions`. Each condition has a `type` such as `Ready`, a `status` of `True`, `False` or `Unknown`, a `reason` in a single word, a human `message` and a `lastTransitionTime`. Many controllers also set `observedGeneration`, the value of `metadata.generation` that the controller last handled.

```sh
kubectl -n starfleet get beacon first-beacon -o jsonpath='{.metadata.generation}{"\n"}{.status}{"\n"}'
```

If `observedGeneration` is lower than `metadata.generation`, the controller has not yet seen the latest change to `spec`. If the object has no `status` at all, either the controller is not running, it cannot read the object, or it has no permission to write `status`. This is the first check when a custom resource seems to be ignored. After it, read the events and the controller log:

```sh
kubectl -n starfleet describe beacon first-beacon
kubectl -n beacon-system logs deployment/beacon-operator --tail=20
```

The stand-in operator in this module writes no status, so the first command shows no conditions. A real operator would show them.

## Finalizers

A finalizer is a string in `metadata.finalizers`. While the list is not empty, the API server does not remove the object when a user deletes it. Instead it sets `metadata.deletionTimestamp` and leaves the object in place. The controller sees the timestamp, cleans up whatever it created outside the object, removes its finalizer from the list, and only then does the API server delete the object.

This protects external resources, such as a cloud disk or a DNS record, from being forgotten. It also has a failure case. If the operator is removed while custom resources with its finalizer still exist, no controller is left to remove the finalizer, and the objects stay in the `Terminating` state forever.

Show it with the stand-in operator. Create an object that has a finalizer, then delete it:

```sh
kubectl apply -f - <<'BEACON'
apiVersion: training.astrona.io/v1
kind: Beacon
metadata:
  name: guarded-beacon
  namespace: starfleet
  finalizers:
    - training.astrona.io/cleanup
spec:
  channel: beta
BEACON
kubectl -n starfleet delete beacon guarded-beacon --wait=false
kubectl -n starfleet get beacon guarded-beacon -o jsonpath='{.metadata.deletionTimestamp}'
```

The last command prints a timestamp, and the object is still there. The stand-in controller does not remove the finalizer, so you do it by hand:

```sh
kubectl -n starfleet patch beacon guarded-beacon --type=merge -p '{"metadata":{"finalizers":null}}'
```

Removing a finalizer by hand skips the cleanup that the controller would do. It is the last step of a manual recovery, not a normal action.

## Upgrading an operator

An upgrade has two kinds of change. A new Deployment image replaces the controller code through a normal rollout. A new CRD changes the schema, and the CRD must be updated first so the new controller finds the fields it expects. Because older custom resources stay valid only if the schema stays compatible, a careful upgrade reads the release notes for removed fields and new versions, applies the CRD, and then rolls the Deployment. Helm does not update files in the chart `crds/` directory, so an administrator applies them with `kubectl apply` first.

## Removal and what it deletes

Order of removal matters:

1. Delete the custom resources, and wait until the controller has removed its finalizers.
2. Delete the Deployment, the bindings and the ServiceAccount.
3. Only if the data is no longer needed, delete the CRD.

Deleting a CRD deletes every custom object of that type in every namespace, because the objects have no existence without their type. Before you delete a CRD, list what it holds:

```sh
kubectl get beacons --all-namespaces
```

An empty result means the CRD is safe to remove. A non-empty result means the delete would also destroy those objects.

## Common pitfalls

> [!WARNING]
> Do not delete a CRD before you list its custom resources; they all go with it. Do not remove an operator that holds finalizers while resources still exist; they stay in Terminating. Do not patch finalizers away as a first step; it skips the cleanup. Do not assume a second replica doubles the work; only the leader acts. Do not upgrade the Deployment before the CRD when the new controller expects new fields.
