# Curriculum Coverage

Exam: Certified Kubernetes Administrator (CKA). Domain: Cluster Architecture, Installation & Configuration (25%).

The [official objectives](https://training.linuxfoundation.org/certification/certified-kubernetes-administrator-cka/) were verified on 2026-10-11. Teaching structure is original; it does not add official exam requirements.

| Section | Official objective | Modules |
| --- | --- | --- |
| 010 | Manage role based access control (RBAC) | 1 |
| 020 | Prepare underlying infrastructure for installing a Kubernetes cluster | 1 |
| 030 | Create and manage Kubernetes clusters using kubeadm | 1 |
| 040 | Manage the lifecycle of Kubernetes clusters | 1 |
| 050 | Implement and configure a highly-available control plane | 1 |
| 060 | Use Helm and Kustomize to install cluster components | 1 |
| 070 | Understand extension interfaces (CNI, CSI, CRI, etc.) | 1 |
| 080 | Understand CRDs, install and configure operators | 1 |

| Section / module | Module | Teaching lessons |
| --- | --- | --- |
| 010 / 01 | Role Rules, Bindings And Administrative Authority | RBAC Grants And Their Consequences; RBAC Scope And Least Privilege |
| 020 / 01 | Host Prerequisites And Installation Topology | Preparing Hosts, Runtime And Network Infrastructure |
| 030 / 01 | Initial Control Plane And Joining Nodes | Understanding kubeadm Initialization And Node Joining |
| 040 / 01 | Supported Upgrade And Node Maintenance | Cluster Upgrades And Maintenance Boundaries; Datastore Snapshots And The Limits Of Recovery |
| 050 / 01 | Resilient Control-Plane Topology | Highly Available API Access And Datastore Quorum |
| 060 / 01 | Packaging Cluster Components | Charts, Values And The Rendered Application; Composing Resources With Kustomize |
| 070 / 01 | Networking, Storage And Runtime Interfaces | CNI, CSI And CRI Extension Responsibilities; Runtimes And Kubernetes Integration |
| 080 / 01 | Custom APIs And Operator Installation | Reading A Custom Resource And Its Controller Contract; Custom Resources And Operators |

The module goals and adaptation sources are recorded in AUTHORING.yaml. Every official objective is covered. Each section starts with an introduction, and each module ends with a summary. YAML banks follow the relevant summary and remain separate from the Markdown manifest.

This is a reading-only draft. No new labs, playgrounds, command output or runtime verification are included. ATP005 publication remains draft.
