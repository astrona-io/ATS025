---
draft: true
exam_objectives:
- Understand CRDs, install and configure operators
---
# Installing And Configuring An Operator

An operator is a controller program that watches custom resources and works to make the cluster match them. Installing one means placing several objects in the right order: the CustomResourceDefinition that creates the type, the namespace, the identity of the controller, the permissions of that identity and the Deployment that runs the program. If any piece is missing, the operator either does not start or starts and cannot do its work. This module shows what each piece does and how to check that a new operator is wired correctly.

Keep one idea in mind: **an operator is an ordinary Deployment that talks to the API server as a ServiceAccount, so everything it can do is decided by the CRD it watches and the RBAC bound to its ServiceAccount.** You install a stand-in operator for a `Beacon` type and read every link between its parts.

The module has three parts. The first part names the objects that make up an operator and what each one does. The second part installs them in the right order and checks the result. The third part configures the operator with a custom resource, reads its status and covers upgrade, removal and the risk of deleting a CRD.

## Learning objectives

After this module you can:

- List the objects that an operator install needs and say what each one provides.
- Install the CRD before the controller and explain why the order matters.
- Bind the least permissions that a controller needs, including leader election.
- Read status conditions and events to see whether an operator accepted a resource.
- Explain finalizers, and what deleting a CRD or an operator does to existing custom resources.

## Before you start

You need Kubernetes basics: Deployments, ServiceAccounts, `kubectl apply` and RBAC roles and bindings. The operator in this module is a stand-in container that sleeps, so no image from outside the cluster is needed and the focus stays on the wiring.

Your playground runs Kubernetes 1.35 with one node:

| Item | What is in it |
| --- | --- |
| `beacon-system` | The namespace for the operator |
| `starfleet` | The namespace for custom resources |
| CRD | `beacons.training.astrona.io` is installed |
| Deployment | `beacon-operator`, a stand-in controller |

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
