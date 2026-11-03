---
draft: true
exam_objectives:
- Understand CRDs, install and configure operators
---
# Installing In Order And Verifying

Applying a bundle in one command usually works, but the order of objects still matters, and the checks after the apply decide whether the install is good. This part installs the operator in a safe order, explains why the CRD comes first, and reads the signals that show a healthy install. It also covers the three common install methods: plain manifests, Helm charts and an operator lifecycle manager.

## Why the CRD comes first

A custom object can only be created after its CRD is established. If a bundle holds both the CRD and a sample custom object, `kubectl apply` can fail with an error that no matches for the kind exist, because the API server has not yet registered the new endpoint when the second document arrives. The fix is to apply the CRD alone, wait for the `Established` condition, and then apply the rest.

```sh
kubectl apply -f crd-beacon.yaml
kubectl wait --for=condition=Established crd/beacons.training.astrona.io --timeout=60s
```

The second command blocks until the API server serves the type, or fails after the timeout. A namespace must also exist before the namespaced objects that use it, and the ServiceAccount and the binding should exist before the Deployment so the first pod already has its permissions. A controller that starts before its permissions exist does not crash in a clean way; it logs forbidden errors and retries.

## An install order that works

1. The CRD, then wait for `Established`.
2. The namespace.
3. The ServiceAccount, the ClusterRole and the ClusterRoleBinding.
4. The Deployment.
5. A first custom resource, to prove the chain works.

Apply the CRD file and the bundle file in that order:

```sh
kubectl apply -f crd-beacon.yaml
kubectl wait --for=condition=Established crd/beacons.training.astrona.io --timeout=60s
kubectl apply -f operator-bundle.yaml
kubectl -n beacon-system rollout status deployment/beacon-operator --timeout=120s
```

<!-- astrona:playground:renew -->

The last command waits until the Deployment reports all replicas available. For a real operator this is the first sign of health: the container started and passed its readiness probe.

## Verify the wiring, not only the pod

A running pod does not prove the controller can work. Check each link:

```sh
kubectl -n beacon-system get deployment beacon-operator -o jsonpath='{.spec.template.spec.serviceAccountName}'
kubectl auth can-i watch beacons.training.astrona.io --as=system:serviceaccount:beacon-system:beacon-operator
kubectl auth can-i update beacons.training.astrona.io/status --as=system:serviceaccount:beacon-system:beacon-operator
kubectl auth can-i delete nodes --as=system:serviceaccount:beacon-system:beacon-operator
```

The first command prints the ServiceAccount name in use. The next two print `yes` when the permissions are present. The last one should print `no`: it proves the role is not wider than it needs to be. An administrator checks both directions, what the identity can do and what it cannot do.

Then read the controller log, because a controller reports permission problems there:

```sh
kubectl -n beacon-system logs deployment/beacon-operator --tail=20
```

A real operator prints lines such as `forbidden` with the resource and the verb that was denied. The stand-in operator in this module prints nothing, so the command returns an empty result.

## The three install methods

Operators come in three common packages. They create the same objects in the end.

- **Plain manifests.** One or more YAML files, applied with `kubectl apply`. Upgrades mean applying a newer file, and removal means deleting the same file. The administrator controls the order.
- **Helm chart.** A chart renders the objects from templates and values. Helm installs files in a chart's `crds/` directory before the templates on install, but it does not upgrade or delete them on later releases. A chart that keeps the CRD in `templates/` lets Helm manage it, with the risk that uninstalling the release deletes the CRD and every custom resource.
- **Operator lifecycle manager.** A tool that runs in the cluster and installs operators from a catalog. It uses its own objects, such as a Subscription that selects an operator and channel and a ClusterServiceVersion that describes one version, and it creates the CRD, RBAC and Deployment itself. The administrator picks the operator and the update approval mode, and the manager creates the rest.

The method does not change what you verify afterwards: the CRD is established, the identity has exactly the permissions needed, and the Deployment is available.

## Prove the chain with a custom resource

Create one object and read it back:

```sh
kubectl apply -f - <<'BEACON'
apiVersion: training.astrona.io/v1
kind: Beacon
metadata:
  name: first-beacon
  namespace: starfleet
spec:
  channel: alpha
BEACON
kubectl -n starfleet get beacon first-beacon -o yaml
```

The API server accepts the object because the CRD exists. With the stand-in operator nothing else happens. With a real operator the controller would notice the new object, act on it and write `status`.

## Common pitfalls

> [!WARNING]
> Do not apply a custom resource in the same file as its CRD without waiting for `Established`. Do not treat a running pod as proof of working permissions; check with `kubectl auth can-i --as`. Do not use a Helm chart that keeps the CRD in `templates/` without knowing that uninstall deletes it. Do not grant a controller more verbs than its loop needs. Do not skip the `no` checks; they show that the role is not too wide.
