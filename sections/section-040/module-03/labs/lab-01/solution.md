---
draft: true
exam_objectives:
- Manage the lifecycle of Kubernetes clusters
---
# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. The expected result of each step is described, not copied from a run.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-040/module-03/labs/lab-01
```

## Step 1: Read the etcd flags and volumes

```sh
kubectl -n kube-system get pod -l component=etcd -o jsonpath='{range .items[0].spec.containers[0].command[*]}{@}{"\n"}{end}'
kubectl -n kube-system get pod -l component=etcd -o jsonpath='{range .items[0].spec.volumes[*]}{.name}{"  "}{.hostPath.path}{"\n"}{end}'
```

The first command prints one flag on each line. Note the values of `--data-dir`, `--name`, `--trusted-ca-file` and `--initial-advertise-peer-urls`. The second prints each volume with its host path. Note the paths of `etcd-data` and `etcd-certs`.

## Step 2: Take and check the snapshot

```sh
POD=$(kubectl -n kube-system get pod -l component=etcd -o jsonpath='{.items[0].metadata.name}')
kubectl -n kube-system exec "$POD" -- etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt --key=/etc/kubernetes/pki/etcd/healthcheck-client.key snapshot save /tmp/recovery-snapshot.db
kubectl -n kube-system exec "$POD" -- etcdutl snapshot status /tmp/recovery-snapshot.db --write-out=table
```

The first command saves the file inside the etcd pod. The second prints a table with the hash, the revision, the total keys and the size. Note the revision and the total keys.

## Step 3: Write the record

Save this as `configmap-etcd-recovery.yaml` and replace each placeholder with the values you noted. Keep the quotes around the two numbers, because ConfigMap values are text:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: etcd-recovery
  namespace: starfleet
data:
  dataDir: <DATA-DIR>
  memberName: <NAME>
  trustedCaFile: <CA-FILE>
  peerUrl: <PEER-URL>
  dataHostPath: <DATA-HOST-PATH>
  certHostPath: <CERT-HOST-PATH>
  snapshotRevision: "<REVISION>"
  snapshotTotalKeys: "<KEYS>"
```

Apply it:

```sh
kubectl apply -f configmap-etcd-recovery.yaml
```

Then check the result:

```sh
kubectl -n starfleet get configmap etcd-recovery -o yaml
```

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-040/module-03/labs/lab-01 --keep
```

All six checks must pass. If `etcd-flags` fails, compare each value with the flag text after the equals sign. If `snapshot-file` fails, the file is missing in the pod or the snapshot command failed; take it again. If `snapshot-record` fails, read the numbers from `etcdutl snapshot status` again, because the file is the source. If `cluster-healthy` fails, the API server is not ready or the etcd pod changed.

When you finish, remove the lab:

```sh
astrona destroy ats-025-lab-040-03-01
```
