---
draft: true
exam_objectives:
- Create and manage Kubernetes clusters using kubeadm
---
# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. The expected result of each step is described, not copied from a run.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-030/module-03/labs/lab-01
```

## Step 1: Read the flags of the API server

```sh
kubectl -n kube-system get pod -l component=kube-apiserver -o jsonpath='{range .items[0].spec.containers[0].command[*]}{@}{"\n"}{end}' | grep -E 'tls-cert-file|kubelet-client-certificate|etcd-certfile|service-account-key-file'
```

The command prints four lines, each in the form `--flag=/path`. Note the four paths.

## Step 2: Read the other three pods

```sh
kubectl -n kube-system get pod -l component=kube-controller-manager -o jsonpath='{range .items[0].spec.containers[0].command[*]}{@}{"\n"}{end}' | grep -E 'service-account-private-key-file|cluster-signing-cert-file'
kubectl -n kube-system get pod -l component=etcd -o jsonpath='{range .items[0].spec.containers[0].command[*]}{@}{"\n"}{end}' | grep peer-cert-file
kubectl -n kube-system get pod -l component=kube-scheduler -o jsonpath='{range .items[0].spec.containers[0].command[*]}{@}{"\n"}{end}' | grep kubeconfig
```

Note the paths after the equals sign. Do not copy the flag name.

## Step 3: Write the map

Save this as `configmap-pki-map.yaml` and replace each placeholder with the path you noted:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: pki-map
  namespace: starfleet
data:
  apiserverServingCert: <PATH>
  apiserverKubeletClientCert: <PATH>
  apiserverEtcdClientCert: <PATH>
  saPublicKey: <PATH>
  saSigningKey: <PATH>
  clusterSigningCert: <PATH>
  etcdPeerCert: <PATH>
  schedulerKubeconfig: <PATH>
```

Apply it:

```sh
kubectl apply -f configmap-pki-map.yaml
```

Then check the result:

```sh
kubectl -n starfleet get configmap pki-map -o yaml
```

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-030/module-03/labs/lab-01 --keep
```

All five checks must pass. If one fails, the message names the key and the value the pod declares. A trailing space or a copied `--flag=` prefix is the usual cause.

When you finish, remove the lab:

```sh
astrona destroy ats-025-lab-030-03-01
```
