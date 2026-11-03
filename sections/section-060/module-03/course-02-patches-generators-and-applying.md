---
draft: true
exam_objectives:
- Use Helm and Kustomize to install cluster components
---
# Patches, Generators And Applying

Transformers change one kind of field everywhere. Real overlays also need to change one field of one object: a memory limit, a port, an extra argument. They also need configuration that changes with the environment. Kustomize covers both with patches and generators. This part shows the two patch types, the ConfigMap generator and its content hash, and the `kubectl` commands that compare, apply and delete the result.

## Two kinds of patch

A patch changes a field of an object that the base already defines. Kustomize accepts two formats, and both go in the `patches` field of `kustomization.yaml`.

A strategic merge patch is a partial YAML object. It names the same kind and name as the target and contains only the fields to change. Kustomize merges it into the target. Lists of objects are merged by a key that Kubernetes defines for the field: containers are matched by `name`, so a patch that names the container `scout` changes that container and keeps the others.

A JSON 6902 patch is a list of operations. Each operation has an `op` (`add`, `replace` or `remove`), a `path` in JSON pointer form such as `/spec/ports/0/port`, and usually a `value`. A list item is addressed by its index. This format is exact and can change one array element, but it fails if the path does not exist and it breaks when the list order changes.

| Need | Better choice |
| --- | --- |
| Add or change a field in a container, found by name | Strategic merge patch |
| Change one list element by position, or remove a field | JSON 6902 patch |
| Change the same field on many objects | JSON 6902 patch with a `target` selector |

A strategic merge patch finds its target from its own `apiVersion`, `kind` and `metadata.name`. A JSON 6902 patch has no such header, so it needs a `target` with at least a `kind` and a `name`. A target can also select by `group`, `version`, `namespace`, `labelSelector` and `annotationSelector`. Patches run on the names that the base uses, so write the base name in the patch even when the overlay adds a prefix.

## A base with a generator

A generator creates an object from literal values or files, so the values live in the kustomization. Start with a new base. Save this as `scout/base/deployment.yaml`:

<!-- astrona:playground:renew -->

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout
spec:
  replicas: 1
  selector:
    matchLabels:
      app: scout
  template:
    metadata:
      labels:
        app: scout
    spec:
      containers:
        - name: scout
          image: docker.io/library/busybox:1.37.0
          command: ["sh", "-c", "echo mode=$MODE; sleep 3600"]
          envFrom:
            - configMapRef:
                name: scout-config
          ports:
            - name: http
              containerPort: 8080
```

Save this as `scout/base/service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: scout
spec:
  selector:
    app: scout
  ports:
    - name: http
      port: 80
      targetPort: http
```

Save this as `scout/base/kustomization.yaml`. The ConfigMap `scout-config` has no YAML file. The generator creates it:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
configMapGenerator:
  - name: scout-config
    literals:
      - MODE=idle
```

Render the base and look at the ConfigMap name:

```sh
kubectl kustomize scout/base
```

The generated ConfigMap is named `scout-config-` followed by ten characters. Kustomize computes them from the content. The Deployment now refers to that full name in `envFrom`, because Kustomize rewrote the reference. The Deployment you wrote said `scout-config`, and the rendered one says the hashed name.

## Why the hash exists

A Deployment does not restart its pods when a ConfigMap changes. With a fixed name, a changed ConfigMap would reach the pods only after a manual restart. With a hash, a changed literal gives a new name, the Deployment template then refers to a new name, and Kubernetes performs a normal rolling update. An unchanged literal gives the same name, so nothing restarts. A `secretGenerator` works the same way for Secrets. Note that a generated Secret is only encoded, not encrypted, and the literal stays in the kustomization files.

The `generatorOptions` field with `disableNameSuffixHash: true` turns the hash off. Then you get a stable name and no automatic rollout. The generator field `behavior` controls what happens when an overlay generates an object with a name that the base already generated:

| Behavior | Result |
| --- | --- |
| `create` | The default. A second object with the same name is an error |
| `merge` | Keys of the overlay are added to or replace keys of the base object |
| `replace` | The overlay object replaces the base object |

## An overlay with patches and a merged generator

Save this as `scout/overlays/outpost/limits.yaml`. It is a strategic merge patch that names the container:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout
spec:
  replicas: 3
  template:
    spec:
      containers:
        - name: scout
          resources:
            limits:
              cpu: 100m
              memory: 64Mi
```

Save this as `scout/overlays/outpost/kustomization.yaml`. It also holds an inline JSON 6902 patch for the Service port and a merged generator:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base
namespace: outpost
namePrefix: outpost-
configMapGenerator:
  - name: scout-config
    behavior: merge
    literals:
      - MODE=patrol
patches:
  - path: limits.yaml
  - target:
      kind: Service
      name: scout
    patch: |-
      - op: replace
        path: /spec/ports/0/port
        value: 8080
```

Render the overlay before you apply it:

```sh
kubectl kustomize scout/overlays/outpost
```

You should see the name `outpost-scout`, three replicas, the limits on the container, the Service port `8080` with `targetPort: http` unchanged, and a ConfigMap `outpost-scout-config-<hash>` with `MODE: patrol`. The Deployment refers to that hashed name.

## Compare, apply and delete

Three `kubectl` commands cover the working cycle:

```sh
kubectl diff -k scout/overlays/outpost
kubectl apply -k scout/overlays/outpost
kubectl -n outpost rollout status deployment/outpost-scout --timeout=120s
```

`kubectl diff -k` renders the kustomization and shows what would change in the cluster, with no change made. It exits with code 1 when there is a difference, which is normal. `kubectl apply -k` stores the rendered objects, and records each one in the annotation `kubectl.kubernetes.io/last-applied-configuration` for later three-way comparisons.

Now change `MODE=patrol` to `MODE=guard` in the overlay and apply again:

```sh
kubectl apply -k scout/overlays/outpost
kubectl -n outpost get configmap
kubectl -n outpost get pods
```

The ConfigMap name has a new suffix, the Deployment points at it, and the pods are replaced by a rolling update. The old ConfigMap stays in the namespace, because `kubectl apply` does not remove objects that disappear from the input. Remove everything the current kustomization defines with `kubectl delete -k scout/overlays/outpost`; it deletes by the rendered names, which is why a stale generated ConfigMap from an earlier hash needs a manual delete.

## Failures to recognise

A patch whose target does not exist stops the build with an error that no resource matched, so a wrong name or kind is caught when you render. A strategic merge patch that names a container that does not exist adds a new container with only the given fields, and the API server then rejects it because the image is missing. A JSON 6902 patch with a wrong index or a missing path fails the build. When two patches change the same field, the later one in the list wins.

Kustomize and Helm solve different problems. Helm templates and records a release with a history. Kustomize patches plain YAML and keeps no record. Because the version of Kustomize in `kubectl` can be older than the stand-alone tool, a feature that works in one can be missing in the other, so confirm with `kubectl kustomize`.

You now know how to change any field, generate configuration that rolls out safely and review a change before applying it. The remaining skill is to combine the tools: render a chart with Helm and let Kustomize adjust the output.

## Common pitfalls

> [!WARNING]
> Do not write the prefixed name in a patch; use the name in the base. Do not forget `behavior: merge` when an overlay generates a ConfigMap that the base already generates. Do not expect `kubectl apply -k` to delete stale objects or old ConfigMaps. Do not call a generated Secret secure; it is only encoded. Do not read the exit code 1 of `kubectl diff` as an error.
