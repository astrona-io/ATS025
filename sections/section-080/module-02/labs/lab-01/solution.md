---
draft: true
exam_objectives:
- Understand CRDs, install and configure operators
---
# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. The expected result of each step is described, not copied from a run.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-080/module-02/labs/lab-01
```

## Step 1: Read the current CRD

```sh
kubectl get crd beacons.training.astrona.io -o yaml
```

The schema of `v1` holds only `type: object` and `x-kubernetes-preserve-unknown-fields: true`. That marker is why every field is accepted.

## Step 2: Write the schema, defaults and rule

Save this as `crd-beacon.yaml`. It replaces the whole `v1` entry:

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
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              required:
                - channel
              x-kubernetes-validations:
                - rule: "self.channel == oldSelf.channel"
                  message: "channel cannot be changed after creation"
              properties:
                channel:
                  type: string
                  enum:
                    - alpha
                    - beta
                    - gamma
                interval:
                  type: integer
                  minimum: 5
                  maximum: 3600
                  default: 60
```

Apply it and submit:

```sh
kubectl apply -f crd-beacon.yaml
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-080/module-02/labs/lab-01 --keep
```

The checks for the CRD, the schema, the interval and the immutable channel pass. The checks for columns and status still fail.

## Step 3: Add the columns and the status subresource

Add these two blocks under the `v1` entry, at the same level as `schema`:

```yaml
      subresources:
        status: {}
      additionalPrinterColumns:
        - name: Channel
          type: string
          jsonPath: .spec.channel
        - name: Interval
          type: integer
          jsonPath: .spec.interval
```

Add a `status` node next to `spec` in the schema, so the status subresource has a place for fields:

```yaml
            status:
              type: object
              x-kubernetes-preserve-unknown-fields: true
```

Apply the file again and submit:

```sh
kubectl apply -f crd-beacon.yaml
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-080/module-02/labs/lab-01 --keep
```

## Step 4: Check the result yourself

```sh
kubectl -n starfleet get beacons
kubectl apply --dry-run=server -f - <<'BEACON'
apiVersion: training.astrona.io/v1
kind: Beacon
metadata:
  name: probe-beacon
  namespace: starfleet
spec:
  channel: delta
BEACON
```

The list shows the new columns, and `legacy-beacon` shows the default interval 60 even though it was stored without one. The dry run fails and names the supported values.

Clean up when you are done:

```sh
astrona destroy ats-025-lab-080-02-01
```
