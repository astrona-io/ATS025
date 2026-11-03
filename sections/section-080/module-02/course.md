---
draft: true
exam_objectives:
- Understand CRDs, install and configure operators
---
# CustomResourceDefinition Schema, Validation And Versions

A CustomResourceDefinition (CRD) adds a new resource type to the Kubernetes API. The API server then stores objects of that type in etcd, checks them against a schema and serves them at a normal REST path. Whether a cluster accepts or rejects a custom object depends only on the CRD, because no controller is involved in that decision. This module shows what is inside a CRD and how each field changes what the API server does.

Keep one idea in mind: **the CRD is the whole contract that the API server enforces for a custom resource: names, scope, schema, defaults, versions and subresources.** You write a small CRD for a `Beacon` type, send valid and invalid objects to it, and read how the API server answers.

The module has three parts. The first part explains the structure of a CRD and the OpenAPI schema that validates objects. The second part adds defaults, pruning and validation rules written in the Common Expression Language (CEL). The third part covers versions, storage, the status and scale subresources, and printer columns.

## Learning objectives

After this module you can:

- Write a CRD with the fields `group`, `names`, `scope` and `versions`, and say what each field changes.
- Describe a structural schema and name what the API server does with unknown fields, defaults and invalid values.
- Write validation rules with `x-kubernetes-validations` and explain `self` and `oldSelf`.
- Explain the difference between a served version and the storage version, and what conversion does.
- Enable the `status` subresource and add a printer column.

## Before you start

You need Kubernetes basics: namespaces, `kubectl apply` and `kubectl get`, and how to read YAML. You do not need to write a controller, because this module is about the API side only.

Your playground runs Kubernetes 1.35 with one node:

| Item | What is in it |
| --- | --- |
| `starfleet` | An empty namespace for your `Beacon` objects |
| cluster scope | No custom resource definitions of your own yet |

`kubectl` already points at the playground cluster, as the cluster administrator.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
