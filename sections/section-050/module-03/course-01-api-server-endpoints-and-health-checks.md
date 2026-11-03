---
draft: true
exam_objectives:
- Implement and configure a highly-available control plane
---
# API Server Endpoints And Health Checks

A load balancer in front of three API servers is useful only if it sends requests to servers that can answer. The API server reports its own health on HTTP paths, and kubeadm wires those paths into probes. This part explains the three health endpoints, shows what each check covers, and follows how clients inside and outside the cluster find the API servers.

## An API server keeps no state of its own

The `kube-apiserver` does not store cluster state. It authenticates the request, runs admission, validates the object and reads or writes etcd. Because it keeps no state, any number of API servers can run at the same time, and any of them can answer any request. This is called an active-active layout, and it needs no election.

The consequence is simple. When one API server fails, a client only needs to reach another one. Two things make that work: something must stop sending requests to the failed server, and every client must use a name that reaches all servers.

## The three health endpoints

The API server serves three paths over HTTPS on its secure port, which is 6443 in kubeadm clusters:

| Path | Question it answers | Used for |
| --- | --- | --- |
| `/livez` | Is the process alive, and should it be restarted? | Liveness probe |
| `/readyz` | Can the server handle requests now? | Readiness probe, load balancer check |
| `/healthz` | The old combined check | Deprecated, kept for compatibility |

A check passes with the HTTP status 200 and the body `ok`. By default, Kubernetes allows unauthenticated clients to read these three paths, so a load balancer needs no credentials.

<!-- astrona:playground:renew -->

Read the plain results through `kubectl`, which sends an authenticated request:

```sh
kubectl get --raw=/livez
kubectl get --raw=/readyz
```

Each command prints `ok` when the server is healthy. Add `?verbose` to list the individual checks:

```sh
kubectl get --raw='/readyz?verbose'
```

The verbose output has one line per check. A line that starts with `[+]` passed and a line that starts with `[-]` failed. The list includes the `ping` check, the `etcd` check that reads the datastore and the `poststarthook` checks that confirm that start-up work finished. The last line is the overall result.

## Why readiness is the right check for a load balancer

`/livez` stays green when the server runs but cannot serve, for example when it cannot reach etcd. Restarting such a server would not fix the datastore, so liveness avoids the datastore checks. `/readyz` includes them. It also turns red when the server starts a graceful shutdown, so a load balancer that checks `/readyz` stops sending new requests before the server closes its listener.

You can select checks by name. Each check has its own path, such as `/readyz/etcd`, and the query parameter `exclude` skips checks:

```sh
kubectl get --raw='/readyz/etcd'
kubectl get --raw='/readyz?verbose&exclude=etcd'
```

The first command reads only the datastore check. The second runs every check except `etcd` and lists them. Use these forms when you debug a server that is not ready: they show which dependency fails.

A load balancer can also use a plain TCP check on port 6443. That proves only that something listens, so a server that cannot reach etcd still receives requests. A check against `/readyz` over HTTPS is stronger.

## The probes that kubeadm sets

kubeadm writes three probes into the static pod of the API server: a startup probe and a liveness probe on `/livez`, and a readiness probe on `/readyz`. The kubelet runs them against the local server and restarts the container when liveness fails.

Read them from the mirror pod:

```sh
kubectl -n kube-system get pod -l component=kube-apiserver \
  -o jsonpath='{.items[0].spec.containers[0].livenessProbe.httpGet.path}{"\n"}{.items[0].spec.containers[0].readinessProbe.httpGet.path}{"\n"}'
```

The two lines are the liveness path and the readiness path. A failing readiness probe marks the pod as not ready, and a failing liveness probe makes the kubelet restart the container. The load balancer outside the cluster does its own check, because it cannot read the probe results.

## How clients find the API servers

Clients outside the cluster, such as `kubectl` on a laptop, use the address in their kubeconfig. In a kubeadm cluster, that address is the control plane endpoint. Clients inside the cluster use the Service `kubernetes` in the `default` namespace. Its endpoints are the real addresses of the API servers.

```sh
kubectl -n default get endpointslices -l kubernetes.io/service-name=kubernetes
```

The EndpointSlice lists one address for each API server that is alive. Each API server writes its own address into etcd with a time to live and renews it, and a reconciler in the API server copies the live addresses into the EndpointSlice. When a server stops renewing, its entry expires and its address disappears from the list. With the playground's one node, the list has one address.

Each API server also keeps a Lease object in `kube-system` that carries the label `apiserver.kubernetes.io/identity`. That Lease gives the server a unique identity inside the cluster. It is not the mechanism that updates the EndpointSlice.

## The certificate must contain the endpoint name

The API server presents a TLS certificate. A client checks that the name it connected to appears in the certificate's subject alternative names (SANs). When a client connects to `api.starfleet.example` and the certificate lists only the node names and IP addresses, the client refuses the connection with a certificate error.

kubeadm adds the SANs from the `controlPlaneEndpoint` and from the `apiServer.certSANs` list of the `ClusterConfiguration`. When you put a second name in front of the load balancer later, you must add it to `certSANs` and create a new certificate, because kubeadm does not change an existing certificate.

Read the SANs that the server presents, using the address in your kubeconfig:

```sh
SERVER="$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')"
echo | openssl s_client -connect "${SERVER#https://}" 2>/dev/null | openssl x509 -noout -ext subjectAltName
```

The output lists names such as `kubernetes`, `kubernetes.default.svc`, the node name and IP addresses. The `openssl` command must exist on your host. If it is missing, skip this step.

## Worked example: a server that is alive but not ready

A team sees that one of its three API servers answers `kubectl` with timeouts, while the pod shows `Running`. The load balancer still sends it a third of all requests. The team runs the verbose readiness check on that server and sees `[-]etcd failed`. The process is alive, so liveness passes and nothing restarts it, but it cannot reach its etcd member.

The fix has two layers. The load balancer should check `/readyz`, so it removes the server as soon as the check fails. The team then repairs the network path to etcd, and the server returns to the pool without a restart.

## What you know now, and what is open

You can read the three health endpoints, find the probes and the Service endpoints of the API servers, and explain the certificate name rule. The API server needs no election, but the scheduler and the controller manager do. The next part explains how they choose one active copy.

## Common pitfalls

> [!WARNING]
> - Using `/livez` for the load balancer. It stays green while the server cannot reach etcd.
> - Using only a TCP check on port 6443. A listening server with a broken datastore connection still receives requests.
> - Forgetting that the endpoint name must be in the certificate SANs. The result is a certificate error on every client.
> - Reading `/healthz` as the main signal. It is deprecated, and the two newer paths separate liveness from readiness.
> - Expecting `kubectl get --raw` to show a server that your load balancer skips. The command reaches whatever server your kubeconfig points at.
