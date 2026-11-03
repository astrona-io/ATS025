---
draft: true
exam_objectives:
- Understand extension interfaces (CNI, CSI, CRI, etc.)
---
# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. The expected result of each step is described, not copied from a run.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-070/module-02/labs/lab-01
```

## Step 1: Read the facts from the cluster

Read the pod range of the node, the address of the `shuttle` pod, the cluster IP of the Service and its endpoints:

```sh
kubectl get nodes -o jsonpath='{.items[0].spec.podCIDR}{"\n"}'
kubectl -n starfleet get pod shuttle -o jsonpath='{.status.podIP}{"\n"}'
kubectl -n starfleet get service probe -o jsonpath='{.spec.clusterIP}{"\n"}'
kubectl -n starfleet get endpointslices -l kubernetes.io/service-name=probe
```

The first command prints a range such as an address with a prefix length. The EndpointSlice list shows one slice with the addresses of both ready `probe` pods.

## Step 2: Create the report

Save the values in shell variables, then create the ConfigMap from them:

```sh
pod_cidr="$(kubectl get nodes -o jsonpath='{.items[0].spec.podCIDR}')"
shuttle_ip="$(kubectl -n starfleet get pod shuttle -o jsonpath='{.status.podIP}')"
cluster_ip="$(kubectl -n starfleet get service probe -o jsonpath='{.spec.clusterIP}')"
ready_count="$(kubectl -n starfleet get endpointslices -l kubernetes.io/service-name=probe -o jsonpath='{range .items[*].endpoints[?(@.conditions.ready==true)]}{.addresses[0]}{"\n"}{end}' | grep -c .)"
kubectl -n starfleet create configmap network-report \
  --from-literal=podCIDR="$pod_cidr" \
  --from-literal=shuttleIP="$shuttle_ip" \
  --from-literal=probeClusterIP="$cluster_ip" \
  --from-literal=readyEndpoints="$ready_count" \
  --from-literal=dnsName=probe.starfleet.svc.cluster.local
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-070/module-02/labs/lab-01 --keep
```

The two report checks pass. The two policy checks still fail. The DNS name has the form `<service>.<namespace>.svc.cluster.local`.

## Step 3: Deny all ingress

Save this as `networkpolicy-default-deny.yaml`:

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
```

An empty `podSelector` selects every pod in the namespace. `policyTypes` lists only `Ingress` and there are no `ingress` rules, so the policy allows no incoming traffic.

Apply it and submit:

```sh
kubectl apply -f networkpolicy-default-deny.yaml
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-070/module-02/labs/lab-01 --keep
```

## Step 4: Allow the shuttle pods

Save this as `networkpolicy-probe-ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: probe-ingress
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
```

The `from` entry has only a `podSelector`. Without a `namespaceSelector`, it matches pods in the namespace of the policy, which is `starfleet`. Policies add up, so the second policy opens one path that the first policy closed.

Apply it and submit:

```sh
kubectl apply -f networkpolicy-probe-ingress.yaml
astrona submit --git ssh://git@github.com/astrona-io/ATS025.git -c sections/section-070/module-02/labs/lab-01 --keep
```

## Step 5: Check the result yourself

```sh
kubectl -n starfleet get networkpolicy
kubectl -n starfleet describe networkpolicy probe-ingress
kubectl -n starfleet exec shuttle -- wget -q -O - -T 3 http://probe
kubectl -n outpost exec drifter -- wget -q -O - -T 3 http://probe.starfleet
```

The list shows both policies and the description shows the allowed source and port. The last two commands send real requests. If the CNI plugin of the cluster enforces NetworkPolicy, the `shuttle` request succeeds and the `drifter` request times out. If it does not enforce policies, both succeed. The grader does not depend on this result, because it reads the policy objects.

Clean up when you are done:

```sh
astrona destroy ats-025-lab-070-02-01
```
