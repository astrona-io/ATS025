---
draft: true
exam_objectives:
- Manage the lifecycle of Kubernetes clusters
---
# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. The expected result of each step is described, not copied from a run.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-040/module-02/labs/lab-01
```

## Step 1: Read the control plane versions

```sh
kubectl -n kube-system get pod -l component=kube-apiserver -o jsonpath='{.items[0].spec.containers[0].image}{"\n"}'
kubectl -n kube-system get pod -l component=kube-controller-manager -o jsonpath='{.items[0].spec.containers[0].image}{"\n"}'
kubectl -n kube-system get pod -l component=kube-scheduler -o jsonpath='{.items[0].spec.containers[0].image}{"\n"}'
```

Each command prints an image name. The version is the text after the last colon. Note the three versions. If an image has a digest after `@`, ignore the digest.

## Step 2: Read kube-proxy, the kubelet and the stored version

```sh
kubectl -n kube-system get daemonset kube-proxy -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.kubeletVersion}{"\n"}'
kubectl -n kube-system get configmap kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' | grep kubernetesVersion
```

Note the kube-proxy tag, the kubelet version and the stored version.

## Step 3: Compute the skew window

Take the minor number of the API server version. For `v1.35.0` it is 35. The oldest kubelet minor is the API server minor minus 3, and the next upgrade minor is the API server minor plus 1. A kubelet at `v1.31.4` is supported only if its minor number, 31, is at least the oldest kubelet minor. Otherwise the verdict is `unsupported`.

## Step 4: Write the record

Save this as `configmap-upgrade-review.yaml` and replace each placeholder with the values you noted. Keep the quotes around the two minor versions, because ConfigMap values are text:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: upgrade-review
  namespace: starfleet
data:
  apiServerVersion: <API>
  controllerManagerVersion: <CONTROLLER>
  schedulerVersion: <SCHEDULER>
  kubeProxyVersion: <PROXY>
  kubeletVersion: <KUBELET>
  storedVersion: <STORED>
  oldestKubelet: "<OLDEST>"
  nextMinor: "<NEXT>"
  skewVerdict: <VERDICT>
```

Apply it:

```sh
kubectl apply -f configmap-upgrade-review.yaml
```

Then check the result:

```sh
kubectl -n starfleet get configmap upgrade-review -o yaml
```

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-040/module-02/labs/lab-01 --keep
```

All six checks must pass. If `control-plane-versions` fails, compare each value with its image tag. If `proxy-and-kubelet` fails, check for a stray space or a missing `v`. If `skew-window` fails, recompute the two minors and the verdict. If `kubeadm-config-untouched` fails, you changed the stored configuration; the lab keeps a checksum of it.

When you finish, remove the lab:

```sh
astrona destroy ats-025-lab-040-02-01
```
