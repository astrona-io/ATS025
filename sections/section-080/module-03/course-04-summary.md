---
draft: true
exam_objectives:
- Understand CRDs, install and configure operators
---
# Summary

An operator is an ordinary Deployment whose program watches custom resources through the API server. Its power comes from two things only: the CustomResourceDefinition that defines the type, and the permissions bound to the ServiceAccount that the pods use. An install bundle holds the CRD, a namespace, the ServiceAccount, the roles and bindings, and the Deployment, and the objects refer to each other by name without any check at apply time.

The permissions follow the controller loop. Reading and watching custom resources fills the cache, updating them manages finalizers, the status resource is a separate name, and leases support leader election. Reading a bundle before applying it shows how wide the role is. An administrator proves the wiring by asking what the identity can and cannot do.

The CRD must be established before any custom object or controller depends on it, so the safe order is CRD, namespace, identity and permissions, Deployment and then a first object. A running pod does not prove that the permissions work. Plain manifests, Helm charts and operator lifecycle managers all create the same objects, and the same checks apply to each of them.

Settings for the operator live on its Deployment or in its own configuration object, and settings for a workload live in custom resources. Status conditions and the observed generation tell whether the controller handled the latest change. Finalizers delay deletion until the controller cleans up. Removing an operator before its resources leaves them stuck, and deleting a CRD deletes all of its objects.

<!-- astrona:playground:destroy -->
