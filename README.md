# Cluster Architecture, Installation & Configuration (ATS025)

Certified Kubernetes Administrator (CKA): Cluster Architecture, Installation & Configuration, worth 25% of the official curriculum. This course belongs to ATP005.

Developed reading lessons explain configuration, component responsibility, worked reasoning and failure limits. Every section has an introduction, and every module ends with a summary. Reusable YAML knowledge checks are indexed separately. Technical content remains draft.

## Course Outline

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

## Author Review

The [curriculum map](CURRICULUM.md) records objective coverage. [Sources](SOURCES.md) support author review, and [assessment documentation](ASSESSMENTS.md) describes the reusable YAML contract. No runtime is required or claimed, and no new labs or playgrounds are included.
