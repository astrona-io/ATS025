---
draft: true
exam_objectives:
- Prepare underlying infrastructure for installing a Kubernetes cluster
---
# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. The expected result of each step is described, not copied from a run.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-020/module-03/labs/lab-01
```

## Step 1: Read the API server and the scheduler and controller manager ports

```sh
kubectl -n kube-system get pod -l component=kube-apiserver -o jsonpath='{.items[0].spec.containers[0].livenessProbe.httpGet.port}{"\n"}'
kubectl -n kube-system get pod -l component=kube-scheduler -o jsonpath='{.items[0].spec.containers[0].livenessProbe.httpGet.port}{"\n"}'
kubectl -n kube-system get pod -l component=kube-controller-manager -o jsonpath='{.items[0].spec.containers[0].livenessProbe.httpGet.port}{"\n"}'
```

Each command prints one port number. Note the three numbers in this order: API server, scheduler, controller manager.

## Step 2: Read the etcd ports

```sh
kubectl -n kube-system get pod -l component=etcd -o jsonpath='{range .items[0].spec.containers[0].command[*]}{@}{"\n"}{end}' | grep -E 'listen-(client|peer)-urls'
```

The output lists two flags with one or more addresses. The port is the number after the last colon.

## Step 3: Read the kubelet port

```sh
kubectl get nodes -o jsonpath='{.items[0].status.daemonEndpoints.kubeletEndpoint.Port}{"\n"}'
```

The command prints one number.

## Step 4: Write the record

Save this as `configmap-control-plane-ports.yaml` and replace each placeholder with a number you noted:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: control-plane-ports
  namespace: starfleet
data:
  apiserver: "<PORT>"
  etcdClient: "<PORT>"
  etcdPeer: "<PORT>"
  scheduler: "<PORT>"
  controllerManager: "<PORT>"
  kubelet: "<PORT>"
```

Apply it:

```sh
kubectl apply -f configmap-control-plane-ports.yaml
```

Then check the result:

```sh
kubectl -n starfleet get configmap control-plane-ports -o yaml
```

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-020/module-03/labs/lab-01 --keep
```

All five checks must pass. If `scheduler-controller-manager-ports` fails, check that you did not keep the old values 10251 and 10252. If `etcd-ports` fails, make sure you took the number after the last colon and that client and peer are not swapped. If `kubelet-port` fails, you probably kept the read-only port from the outdated record.

When you finish, remove the lab:

```sh
astrona destroy ats-025-lab-020-03-01
```
