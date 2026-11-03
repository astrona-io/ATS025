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

This course includes developed readings, private playgrounds, graded labs, section capstones and quizzes, and a final domain quiz. Static checks pass; live execution remains pending. Technical content remains draft.

## Hands-On Coverage

This course has 24 module playgrounds, 34 graded labs (including 8 section capstones), 8 section quizzes and a final domain quiz. All labs are untested: they were built with static checks only and have never been run.

| Module | Lab |
| --- | --- |
| 010/01 | Grant A ServiceAccount Pod Read Access With A Role |
| 010/02 | Issue A Client Certificate And Grant Pod Read Access |
| 010/03 | Grant Cluster-Scoped Read Access With A ClusterRole |
| 010/capstone | Rebuild Access For Three Identities With RBAC — Task |
| 020/01 | Inspect Node Runtime And Host Prerequisites |
| 020/02 | Record Host Readiness From The API |
| 020/03 | Record Control Plane Ports From Static Pods |
| 020/capstone | Host Readiness Review Before Installation |
| 030/01 | Prepare Short-Lived Node Discovery Credentials |
| 030/02 | kubeadm Configuration Files And Init Phases |
| 030/03 | Map Certificates To Control Plane Components |
| 030/capstone | Join Review For A kubeadm Cluster |
| 040/01 | Drain And Return A Worker To Service |
| 040/01 | Save And Inspect An Etcd Snapshot |
| 040/02 | Audit Component Versions Before An Upgrade |
| 040/03 | Snapshot etcd And Record The Restore Facts |
| 040/capstone | Upgrade Readiness And Recovery Review |
| 050/01 | Inspect A Three-Member Control Plane |
| 050/02 | Record The Control Plane Topology And Check A Quorum Proposal |
| 050/03 | Record Leader Election Facts And Grant Least-Privilege Lease Access |
| 050/capstone | Review A Control Plane For High Availability |
| 060/01 | Install A Chart With Explicit Values |
| 060/01 | Apply A Kustomize Base |
| 060/02 | Install, Upgrade And Roll Back A Helm Release |
| 060/03 | Build A Kustomize Overlay |
| 060/capstone | Adopt, Release And Customize A Cluster Component |
| 070/01 | Trace The Runtime And Network Interfaces |
| 070/02 | Record The Pod Network And Restrict Access With NetworkPolicy |
| 070/03 | Define A StorageClass, A CSIDriver And A Claim |
| 070/capstone | Secure And Persist The Probe Workload |
| 080/01 | Reconcile A Custom Resource |
| 080/02 | Tighten A CustomResourceDefinition Schema |
| 080/03 | Wire An Operator With Least Privilege |
| 080/capstone | Publish A Custom Type And Install Its Operator |
