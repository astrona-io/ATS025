---
draft: true
exam_objectives:
- Understand extension interfaces (CNI, CSI, CRI, etc.)
---
# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. The expected result of each step is described, not copied from a run.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-070/module-03/labs/lab-01
```

## Step 1: Read the default class

```sh
kubectl get storageclass
kubectl get storageclass standard -o yaml
kubectl -n starfleet get pvc legacy-claim -o jsonpath='{.spec.storageClassName}{"\n"}'
```

The list marks `standard` as the default. The YAML shows the `provisioner`, the `reclaimPolicy` and the `volumeBindingMode`. The claim shows `standard`: the API server filled in the default class when the claim was created without one.

## Step 2: Create the StorageClass

Save this as `storageclass-outpost-retain.yaml`. Replace `<PROVISIONER>` with the provisioner that Step 1 showed for `standard`:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: outpost-retain
provisioner: <PROVISIONER>
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

Apply it and submit:

```sh
kubectl apply -f storageclass-outpost-retain.yaml
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-070/module-03/labs/lab-01 --keep
```

The two StorageClass checks pass. The other checks still fail. There is no default-class annotation on the new class, so `standard` stays the only default.

## Step 3: Create the CSIDriver object

Save this as `csidriver-logbook.yaml`:

```yaml
apiVersion: storage.k8s.io/v1
kind: CSIDriver
metadata:
  name: logbook.csi.astrona.io
spec:
  attachRequired: false
  podInfoOnMount: true
  fsGroupPolicy: File
  volumeLifecycleModes:
    - Persistent
    - Ephemeral
```

This object only describes how Kubernetes must treat a driver of this name. No driver runs in the cluster, so nothing uses it yet.

Apply it and submit:

```sh
kubectl apply -f csidriver-logbook.yaml
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-070/module-03/labs/lab-01 --keep
```

## Step 4: Create the claim

Save this as `pvc-logbook.yaml`:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: logbook
  namespace: starfleet
spec:
  storageClassName: outpost-retain
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

Apply it and check it:

```sh
kubectl apply -f pvc-logbook.yaml
kubectl -n starfleet get pvc logbook
kubectl -n starfleet describe pvc logbook
```

The claim stays `Pending`. The events say that the claim waits for the first consumer, because the class uses `WaitForFirstConsumer`. That is the expected state.

## Step 5: Create the report

```sh
provisioner="$(kubectl get storageclass standard -o jsonpath='{.provisioner}')"
binding_mode="$(kubectl get storageclass standard -o jsonpath='{.volumeBindingMode}')"
reclaim_policy="$(kubectl get storageclass standard -o jsonpath='{.reclaimPolicy}')"
legacy_class="$(kubectl -n starfleet get pvc legacy-claim -o jsonpath='{.spec.storageClassName}')"
kubectl -n starfleet create configmap storage-report \
  --from-literal=defaultClass=standard \
  --from-literal=provisioner="$provisioner" \
  --from-literal=bindingMode="$binding_mode" \
  --from-literal=reclaimPolicy="$reclaim_policy" \
  --from-literal=legacyClaimClass="$legacy_class"
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-070/module-03/labs/lab-01 --keep
```

All checks pass.

## Step 6: Check the result yourself

```sh
kubectl get storageclass
kubectl get csidriver
kubectl -n starfleet get pvc
```

`outpost-retain` is listed without the default marker, the CSIDriver is listed with its settings, and both claims are `Pending` until a pod uses them.

Clean up when you are done:

```sh
astrona destroy ats-025-lab-070-03-01
```
