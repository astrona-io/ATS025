---
draft: true
exam_objectives:
- Understand CRDs, install and configure operators
---
# Versions, Subresources And Printer Columns

A custom resource type changes over time. Fields are renamed, new fields appear and old ones go away. The API server supports this with several versions of one type, one storage version in etcd, and conversion between versions. Two more features make a custom resource behave like a built-in object: subresources, which add separate endpoints for status and scale, and printer columns, which control what `kubectl get` shows.

## Several versions of one type

The list `spec.versions` of a CRD can hold more than one entry. Each entry has these flags:

| Field | Meaning |
| --- | --- |
| `served` | When true, the API server answers requests for this version. When false, the version is hidden but still known |
| `storage` | When true, objects are written to etcd in this version. Exactly one version must have `storage: true` |
| `deprecated` | When true, the API server adds a warning header to responses for this version |
| `deprecationWarning` | The text of the warning. If it is missing, a default text is used |

Each version has its own schema. A client that asks for `training.astrona.io/v1alpha1` gets objects shaped by the `v1alpha1` schema, and a client that asks for `v1` gets the `v1` shape. The stored bytes are in the storage version only.

## Conversion between versions

When the requested version differs from the stored version, the API server converts the object. The CRD field `spec.conversion.strategy` selects how:

- `None` is the default. The API server changes only the `apiVersion` field and keeps every other field as it is. This is correct only when the schemas of the versions are the same shape.
- `Webhook` sends the object to an HTTPS endpoint that the CRD names in `spec.conversion.webhook`. The endpoint returns the object in the requested version. Operators that rename or restructure fields use this strategy.

With the `None` strategy, a field that exists only in one version is kept only if the other schema also declares it, otherwise pruning removes it. This is why renaming a field needs a webhook.

### A two-version CRD

Save this as `crd-beacon-versions.yaml`. It keeps `v1` as the storage version and serves an older `v1beta1` that is marked as deprecated:

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: beacons.training.astrona.io
spec:
  group: training.astrona.io
  scope: Namespaced
  names:
    kind: Beacon
    plural: beacons
    singular: beacon
    shortNames:
      - bcn
  versions:
    - name: v1beta1
      served: true
      storage: false
      deprecated: true
      deprecationWarning: "training.astrona.io/v1beta1 Beacon is deprecated; use v1"
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                channel:
                  type: string
                interval:
                  type: integer
    - name: v1
      served: true
      storage: true
      subresources:
        status: {}
      additionalPrinterColumns:
        - name: Channel
          type: string
          jsonPath: .spec.channel
        - name: Interval
          type: integer
          jsonPath: .spec.interval
        - name: Age
          type: date
          jsonPath: .metadata.creationTimestamp
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                channel:
                  type: string
                interval:
                  type: integer
                  default: 60
            status:
              type: object
              properties:
                lastSent:
                  type: string
```

<!-- astrona:playground:renew -->

Apply it:

```sh
kubectl apply -f crd-beacon-versions.yaml
```

Then check the result:

```sh
kubectl get crd beacons.training.astrona.io -o jsonpath='{.status.storedVersions}'
kubectl api-versions | grep training.astrona.io
```

The first command prints the list of versions that may exist in etcd. The second shows both `training.astrona.io/v1` and `training.astrona.io/v1beta1`. A request that uses the deprecated version prints a warning line from `kubectl`.

### Why storedVersions matters

The CRD status field `storedVersions` records every version that was ever used to write an object. The API server refuses to remove a version from `spec.versions` while it is still listed in `storedVersions`, because objects of that version might still sit in etcd. The safe way to retire a version is to read every object and write it back so that it is stored in the new storage version, and then to remove the old version from `storedVersions` in the CRD status.

## The status subresource

Setting `subresources.status: {}` gives the type a separate endpoint, `/status`. The effect is a split of write permissions and write paths:

- A write to the main endpoint changes everything except `status`. Any `status` in the request body is ignored.
- A write to the `/status` endpoint changes only `status`. Everything else in the body is ignored.
- Writes to the main endpoint increase `metadata.generation` only when `spec` changes. Writes to `/status` do not.

This lets a user own the `spec` while a controller owns the `status`, and it lets RBAC grant `beacons/status` separately from `beacons`. Without the subresource, one endpoint writes both.

### The scale subresource

The `scale` subresource connects a custom resource to `kubectl scale` and to the HorizontalPodAutoscaler. Its fields tell the API server which JSON paths hold the desired count, the observed count and a label selector:

```yaml
subresources:
  scale:
    specReplicasPath: .spec.replicas
    statusReplicasPath: .status.replicas
    labelSelectorPath: .status.selector
```

The paths must start with `.spec` or `.status`. The `Beacon` type has no replica count, so it does not enable `scale` here.

## Printer columns

By default `kubectl get beacons` shows only the name and the age. The field `additionalPrinterColumns` adds columns. Each column has a `name`, a `type` (`string`, `integer`, `number`, `boolean` or `date`) and a `jsonPath` that selects a value from the object. The server builds the table, so every client that asks for a table gets the same columns.

```sh
kubectl -n starfleet get beacons
```

With the CRD above, the output has the columns `NAME`, `CHANNEL`, `INTERVAL` and `AGE`.

## Common pitfalls

> [!WARNING]
> Do not mark two versions with `storage: true`, or none; the API server rejects the CRD. Do not use the `None` conversion strategy for versions that rename fields. Do not remove a version while it is listed in `storedVersions`. Do not send `status` through the main endpoint when the `status` subresource is on; it is ignored. Do not start a `jsonPath` with anything other than a leading dot path from the object root.
