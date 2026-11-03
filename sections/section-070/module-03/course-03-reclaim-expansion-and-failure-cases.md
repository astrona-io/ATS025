---
draft: true
exam_objectives:
- Understand extension interfaces (CNI, CSI, CRI, etc.)
---
# Reclaim, Expansion And Failure Cases

Creating a volume is only the start of its life. Someone must decide what happens to the data when a claim is deleted, how a volume grows when the application needs more space, and how to find the cause when a pod cannot get its volume. This part covers those three decisions and gives a method for each failure.

## Reclaim policy

The reclaim policy of a PersistentVolume says what Kubernetes does with the volume after its claim is deleted. A dynamically provisioned volume copies the `reclaimPolicy` of its StorageClass at creation. The default for a class is `Delete`.

- `Delete`: the PV object and the storage behind it are deleted. The data is gone.
- `Retain`: the PV object stays with the phase `Released`, and the storage and its data stay. The volume is not given to any new claim, because it still refers to the old one. An administrator copies the data, then deletes the PV object, or clears the `claimRef` field to make the volume available again.

The policy of an existing PV can be changed with `kubectl patch`, and the change is the safe way to protect important data before you delete a claim.

Create a class that keeps its volumes. First read the provisioner of the default class with `kubectl get storageclass standard -o jsonpath='{.provisioner}'`.

<!-- astrona:playground:renew -->

Save this as `storageclass-keep.yaml`. Replace `<PROVISIONER>` with the value you read:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: keep
provisioner: <PROVISIONER>
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
```

Apply it:

```sh
kubectl apply -f storageclass-keep.yaml
```

Then save this claim and pod as `workload-keep.yaml` and apply them:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: logbook
  namespace: starfleet
spec:
  storageClassName: keep
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: writer
  namespace: starfleet
spec:
  containers:
    - name: writer
      image: docker.io/library/busybox:1.37.0
      command: ["sh", "-c", "echo day-one > /logbook/entry.txt && sleep 3600"]
      volumeMounts:
        - name: logbook
          mountPath: /logbook
  volumes:
    - name: logbook
      persistentVolumeClaim:
        claimName: logbook
```

```sh
kubectl apply -f workload-keep.yaml
kubectl -n starfleet wait --for=condition=Ready pod/writer --timeout=120s
kubectl get pv
```

Now delete the pod and the claim, and read the volume:

```sh
kubectl -n starfleet delete pod writer
kubectl -n starfleet delete pvc logbook
kubectl get pv
```

The volume is still listed, and its status is `Released`. With the class `standard` and its `Delete` policy, the same steps would remove the volume. A `Released` volume cannot be claimed by a new claim until the `claimRef` is removed.

## Expansion

A claim can grow if its class has `allowVolumeExpansion: true`. The user edits `spec.resources.requests.storage` of the claim to a larger value. The API server rejects the edit when the class does not allow expansion. A claim cannot shrink.

Expansion has up to two stages, each done by a different component. The `external-resizer` calls `ControllerExpandVolume` to grow the storage in the backend. If the file system must grow too, the kubelet calls `NodeExpandVolume` on the node, often while the pod is still running. The claim shows the conditions `Resizing` and `FileSystemResizePending` while these stages run. Whether the file system grows online depends on the driver.

Test the rule on a class that does not allow expansion. Save this as `workload-grow.yaml`. It uses the class `standard`, which has no `allowVolumeExpansion` setting in kind:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: grow
  namespace: starfleet
spec:
  storageClassName: standard
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: grower
  namespace: starfleet
spec:
  containers:
    - name: grower
      image: docker.io/library/busybox:1.37.0
      command: ["sh", "-c", "sleep 3600"]
      volumeMounts:
        - name: data
          mountPath: /data
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: grow
```

Apply it and wait until the claim is bound, then try to grow it:

```sh
kubectl apply -f workload-grow.yaml
kubectl -n starfleet wait --for=condition=Ready pod/grower --timeout=120s
kubectl -n starfleet patch pvc grow -p '{"spec":{"resources":{"requests":{"storage":"2Gi"}}}}'
```

The API server returns an error that says the class does not support resizing. The claim keeps its old size. A class with `allowVolumeExpansion: true` accepts the edit, but the volume only grows if the driver implements expansion. The flag on the class is permission, not a promise.

## Access modes

The access mode of a claim tells which nodes may mount the volume at the same time. `ReadWriteOnce` allows read and write from one node (several pods on that node can share it). `ReadOnlyMany` allows read from many nodes. `ReadWriteMany` allows read and write from many nodes. `ReadWriteOncePod` allows read and write from one pod only. A driver only supports the modes that its backend can provide, and a claim that asks for an unsupported mode stays `Pending`.

## Finding the failed stage

Use the order of events from claim to mounted volume and ask which stage did not finish. Read the events with `kubectl describe` on the object that is stuck, and then look at the component that owns that stage.

| What you see | Stage that failed | Component to check |
| --- | --- | --- |
| Claim `Pending`, event says waiting for first consumer | None: expected | Create a pod that uses the claim |
| Claim `Pending`, event `ProvisioningFailed` or no event | Provisioning | The provisioner: class name, driver pods, quota in the backend |
| Pod `Pending`, event about unbound claim | Binding or scheduling | Claim phase, node affinity of the volume |
| Pod `ContainerCreating`, event `FailedAttachVolume` | Attach | `external-attacher`, VolumeAttachment status |
| Pod `ContainerCreating`, event `FailedMount` | Stage or publish | The node pod of the driver and the kubelet log on that node |
| Event `Multi-Attach error` | Access mode | A `ReadWriteOnce` volume is still attached to another node |

Two checks come first for every case: that the `provisioner` named in the class matches a driver that runs, and that the node group of that driver runs on the node where the pod is scheduled.

```sh
kubectl get storageclass
kubectl -n starfleet describe pvc
kubectl -n starfleet get events --sort-by=.lastTimestamp
```

## What you know now

The reclaim policy decides whether the data survives its claim. Expansion needs permission from the class and support from the driver, and it runs in a controller stage and a node stage. A failed volume points to one stage, and each stage has one owner. This closes the path from a claim to a mounted volume.

## Common pitfalls

> [!WARNING]
> - `Delete` removes the data when the claim is deleted. Patch the volume to `Retain` before you delete a claim you may need.
> - A `Released` volume is not available. It still points to the old claim.
> - `allowVolumeExpansion: true` does not guarantee the driver can expand. A claim also cannot shrink.
> - `ReadWriteOnce` is per node, not per pod. A second node cannot mount the volume while the first holds it.
> - Do not delete the PV object of a bound claim to fix a problem. The claim then loses its volume.
