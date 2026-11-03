---
draft: true
exam_objectives:
- Understand CRDs, install and configure operators
---
# Guided Practice: Reconcile A Custom Resource

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

<!-- astrona:playground:renew -->

```sh
export KUBECONFIG="$(astrona kubeconfig ats-025-playground-080-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-025-playground-080-01" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.

## Inspect And Explain

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Inspect the relevant evidence:

```sh
kubectl api-resources --api-group=training.astrona.io
kubectl explain probesetting.spec --api-version=training.astrona.io/v1
```

A CustomResourceDefinition adds an API type and validation schema. A controller supplies the behavior for that type. The custom resource expresses desired configuration, and the provided controller reconciles an output ConfigMap. Verify the status and the output rather than assuming API acceptance means reconciliation completed.


Save this as `probesetting-greeting.yaml`:

```yaml
apiVersion: training.astrona.io/v1
kind: ProbeSetting
metadata:
  name: greeting
  namespace: starfleet
spec:
  message: configured
```

Apply the required change:

```sh
kubectl apply -f probesetting-greeting.yaml
```

## Verify The Result

Observe the actual result. A denied-request command returns a nonzero status when the denial works. Run denial checks separately from a shell sequence that stops on the first nonzero status.

```sh
kubectl -n starfleet wait --for=jsonpath='{.status.ready}'=true probesetting/greeting --timeout=120s
```

Create ProbeSetting `greeting` in `starfleet` using `training.astrona.io/v1`, with `spec.message: configured`. The supplied controller must mark it ready and produce ConfigMap `settings-greeting` with `data.message: configured`. Keep the controller running. Do not manually create the output ConfigMap instead of the custom resource.


## Read The Result Layer By Layer

When the wait command succeeds, read each layer on its own, so you know why it worked and where to look when it does not.

```sh
kubectl -n starfleet get probesetting greeting -o jsonpath='{.metadata.generation}{" "}{.status.observedGeneration}{"\n"}'
kubectl -n starfleet get configmap settings-greeting -o jsonpath='{.data.message}{"\n"}'
kubectl get pods --all-namespaces | grep -i controller
```

The first command prints two numbers. The generation is the revision of the desired state, and the observed generation is the revision that the controller last handled. When the two numbers are equal, the status describes the current request. The second command prints the message that the controller copied into the output ConfigMap. The third command finds the Pod that runs the controller, which is the component that did the work.

## Change The Request And Watch It Follow

Reconciliation is a loop, not a single action. Change the message and see that the output follows:

```sh
kubectl -n starfleet patch probesetting greeting --type=merge -p '{"spec":{"message":"updated"}}'
kubectl -n starfleet wait --for=jsonpath='{.data.message}'=updated configmap/settings-greeting --timeout=120s
```

The patch changes `spec`, so the generation increases. The controller polls accepted objects, notices the new message and rewrites the ConfigMap. If the wait times out, check the controller Pod first and then its log, because the request itself was accepted by the API server.

## Clean Up The Request

Delete the custom object when you are done. The controller owns the output ConfigMap, so check what remains afterward:

```sh
kubectl -n starfleet delete probesetting greeting
kubectl -n starfleet get configmap settings-greeting
```

Whether the ConfigMap disappears depends on whether the controller set an owner reference on it. If it remains, the controller did not link the two objects, and cleanup is a manual step.

## Common pitfalls

> [!WARNING]
> Installing an API type does not supply controller behavior. Preserve the supplied controller and create the custom resource. Manually creating its output bypasses reconciliation.
