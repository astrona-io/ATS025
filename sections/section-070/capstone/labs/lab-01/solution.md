---
draft: true
exam_objectives:
- Understand extension interfaces (CNI, CSI, CRI, etc.)
---
# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. The expected result of each step is described, not copied from a run.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-070/capstone/labs/lab-01
```

## Step 1: Read the platform facts and create the report

```sh
kubectl get nodes -o wide
kubectl get nodes -o jsonpath='{.items[0].spec.podCIDR}{"\n"}'
kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.containerRuntimeVersion}{"\n"}'
kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.kubeletVersion}{"\n"}'
kubectl get storageclass
```

The runtime value has the form `<name>://<version>`. The name before `://` is the container runtime that the kubelet reaches through the Container Runtime Interface (CRI). Create the report:

```sh
pod_cidr="$(kubectl get nodes -o jsonpath='{.items[0].spec.podCIDR}')"
cluster_ip="$(kubectl -n starfleet get service probe -o jsonpath='{.spec.clusterIP}')"
runtime="$(kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.containerRuntimeVersion}')"
kubelet_version="$(kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.kubeletVersion}')"
kubectl -n starfleet create configmap platform-report \
  --from-literal=podCIDR="$pod_cidr" \
  --from-literal=probeClusterIP="$cluster_ip" \
  --from-literal=defaultClass=standard \
  --from-literal=containerRuntime="$runtime" \
  --from-literal=kubeletVersion="$kubelet_version"
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-070/capstone/labs/lab-01 --keep
```

The report check passes. The other checks still fail.

## Step 2: Write the three NetworkPolicy objects

Save this as `networkpolicies.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: starfleet
spec:
  podSelector: {}
  policyTypes:
    - Ingress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: probe-from-shuttle
  namespace: starfleet
spec:
  podSelector:
    matchLabels:
      app: probe
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: shuttle
      ports:
        - protocol: TCP
          port: 8080
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: probe-from-outpost
  namespace: starfleet
spec:
  podSelector:
    matchLabels:
      app: probe
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: outpost
          podSelector:
            matchLabels:
              app: drifter
      ports:
        - protocol: TCP
          port: 8080
```

In the last policy, `namespaceSelector` and `podSelector` sit in the same `from` entry. The entry therefore matches only pods that carry `app=drifter` and run in a namespace with that name. Two separate entries would match either one.

Apply it and submit:

```sh
kubectl apply -f networkpolicies.yaml
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-070/capstone/labs/lab-01 --keep
```

The three policy checks pass.

## Step 3: Create the storage objects

Read the provisioner of the default class first:

```sh
kubectl get storageclass standard -o jsonpath='{.provisioner}{"\n"}'
```

Save this as `storage.yaml`. Replace `<PROVISIONER>` with the value that the command printed:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: starfleet-data
provisioner: <PROVISIONER>
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
---
apiVersion: storage.k8s.io/v1
kind: CSIDriver
metadata:
  name: data.csi.astrona.io
spec:
  attachRequired: false
  podInfoOnMount: true
```

Apply it and submit:

```sh
kubectl apply -f storage.yaml
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-070/capstone/labs/lab-01 --keep
```

The storage objects check passes.

## Step 4: Create the claim and the pod

Save this as `recorder.yaml`:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: probe-data
  namespace: starfleet
spec:
  storageClassName: starfleet-data
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: recorder
  namespace: starfleet
  labels:
    app: recorder
spec:
  containers:
    - name: recorder
      image: docker.io/library/busybox:1.37.0
      command: ["sh", "-c", "sleep 3600"]
      volumeMounts:
        - name: data
          mountPath: /data
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: probe-data
```

Apply it and submit:

```sh
kubectl apply -f recorder.yaml
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-070/capstone/labs/lab-01 --keep
```

All checks pass. Because the class waits for a consumer, the pod is what triggers volume creation. Whether the volume is created and the pod starts depends on the provisioner of the cluster, and the grader does not require it.

## Step 5: Check the result yourself

```sh
kubectl -n starfleet get networkpolicy
kubectl -n starfleet get pvc,pod
kubectl -n starfleet describe pod recorder
```

The events of the pod show the volume steps: waiting for the claim, then the provisioning result. Read them to see which part of the storage flow acted.

Clean up when you are done:

```sh
astrona destroy ats-025-lab-070-capstone-01
```
