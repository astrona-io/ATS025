---
draft: true
exam_objectives:
- Manage the lifecycle of Kubernetes clusters
---
# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. The expected result of each step is described, not copied from a run.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-040/capstone/labs/lab-01
```

## Step 1: Take and check the snapshot

```sh
POD=$(kubectl -n kube-system get pod -l component=etcd -o jsonpath='{.items[0].metadata.name}')
kubectl -n kube-system exec "$POD" -- etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt --key=/etc/kubernetes/pki/etcd/healthcheck-client.key snapshot save /tmp/lifecycle-snapshot.db
kubectl -n kube-system exec "$POD" -- etcdutl snapshot status /tmp/lifecycle-snapshot.db --write-out=table
```

The second command prints the hash, the revision, the total keys and the size. Note the revision and the total keys.

## Step 2: Return the worker

```sh
kubectl get nodes
kubectl uncordon <WORKER>
kubectl -n starfleet rollout status deployment/probe
```

The first command lists the nodes. The worker shows `SchedulingDisabled`. Replace `<WORKER>` with its name. After the uncordon, the scheduler places the waiting `probe` pods on the worker.

## Step 3: Read the versions

```sh
kubectl -n kube-system get pod -l component=kube-apiserver -o jsonpath='{.items[0].spec.containers[0].image}{"\n"}'
kubectl -n kube-system get pod -l component=etcd -o jsonpath='{.items[0].spec.containers[0].image}{"\n"}'
kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.kubeletVersion}{"\n"}'
kubectl -n kube-system get configmap kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' | grep kubernetesVersion
```

The version of an image is the text after the last colon. For the API server minor 35, the oldest kubelet minor is 32 and the next minor is 36. Use the real minor of your cluster.

## Step 4: Write the record

Save this as `configmap-lifecycle-review.yaml` and replace each placeholder with the values you noted. Keep the quotes around values that look like numbers:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: lifecycle-review
  namespace: starfleet
data:
  apiServerVersion: <API>
  kubeletVersion: <KUBELET>
  storedVersion: <STORED>
  etcdVersion: <ETCD>
  oldestKubelet: "<OLDEST>"
  nextMinor: "<NEXT>"
  snapshotPath: /tmp/lifecycle-snapshot.db
  snapshotRevision: "<REVISION>"
  snapshotTotalKeys: "<KEYS>"
  workerName: <WORKER>
```

Apply it:

```sh
kubectl apply -f configmap-lifecycle-review.yaml
```

Then check the result:

```sh
kubectl -n starfleet get configmap lifecycle-review -o yaml
```

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-040/capstone/labs/lab-01 --keep
```

All six checks must pass. If `worker-returned` fails, the node is still cordoned or the pods are not available yet; wait for the rollout. If `snapshot-record` fails, read the numbers from `etcdutl snapshot status` again.

When you finish, remove the lab:

```sh
astrona destroy ats-025-lab-040-capstone-01
```
