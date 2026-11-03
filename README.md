# Cluster Architecture, Installation & Configuration (ATS025)

Certified Kubernetes Administrator (CKA): Cluster Architecture, Installation & Configuration, worth 25% of the official curriculum. This course belongs to ATP005.

Every module has reading lessons that explain configuration, component responsibility, worked reasoning and failure limits, a playground for practice and a graded lab. Every section has an introduction, a capstone lab and a knowledge check, and the course ends with a final domain knowledge check. Technical content remains draft.

## Course Outline

| Section / module | Module | Teaching lessons |
| --- | --- | --- |
| 010 / 01 | Roles, RoleBindings And Least Privilege | Roles, Rules And Verbs; RoleBindings And Subjects; Additive Grants And Indirect Privilege |
| 010 / 02 | Users, Client Certificates And ServiceAccount Tokens | Client Certificates And The CSR Flow; Kubeconfig Credentials And Granting Access; ServiceAccount Tokens And Automounting |
| 010 / 03 | Cluster-Scoped Access: ClusterRoles, Non-Resource URLs And Escalation Prevention | ClusterRoles And ClusterRoleBindings; Non-Resource URLs And Built-In Roles; Escalation Prevention And Sensitive Verbs |
| 020 / 01 | Host Prerequisites And Installation Topology | Preparing Hosts, Runtime And Network Infrastructure |
| 020 / 02 | Kernel Modules, sysctl, Swap And The cgroup Driver | Kernel Modules, sysctl And Swap; The cgroup Driver And kubelet Configuration |
| 020 / 03 | Packages, Ports And kubeadm Preflight Checks | Packages And Host Identity; Ports And Preflight Checks |
| 030 / 01 | Initial Control Plane And Joining Nodes | Understanding kubeadm Initialization And Node Joining |
| 030 / 02 | kubeadm Configuration Files And Init Phases | Configuration Kinds And Fields; Init Phases And The Stored Configuration |
| 030 / 03 | Certificates, kubeconfig Files And Joining Nodes | PKI Files And Certificate Lifetimes; Bootstrap Tokens And The CA Public-Key Hash; Joining A Node, Network Add-Ons And kubeadm Reset |
| 040 / 01 | Supported Upgrade And Node Maintenance | Cluster Upgrades And Maintenance Boundaries; Datastore Snapshots And The Limits Of Recovery |
| 040 / 02 | kubeadm Upgrade Workflow And Version Skew | The kubeadm Upgrade Workflow; Version Skew Policy And Reading Versions |
| 040 / 03 | etcd Restore And Recovery | Taking And Checking An etcd Snapshot; Restoring A Snapshot And Recovering The Control Plane |
| 050 / 01 | Resilient Control-Plane Topology | Highly Available API Access And Datastore Quorum |
| 050 / 02 | Control Plane Topology With kubeadm | Stacked And External etcd Topologies In kubeadm Clusters; Reading Quorum And Members From A Running Cluster |
| 050 / 03 | Leader Election, Health Endpoints And Failure Behavior | API Server Endpoints And Health Checks; Leader Election With Leases |
| 060 / 01 | Packaging Cluster Components | Charts, Values And The Rendered Application; Composing Resources With Kustomize |
| 060 / 02 | Helm Charts, Values And Releases | Chart Anatomy And Rendering; Values And The Release Lifecycle |
| 060 / 03 | Kustomize Overlays And Patches | Bases, Overlays And Transformers; Patches, Generators And Applying |
| 070 / 01 | Networking, Storage And Runtime Interfaces | CNI, CSI And CRI Extension Responsibilities; Runtimes And Kubernetes Integration |
| 070 / 02 | Pod Networking Through CNI | How A Pod Gets Its Network; Pod Addresses, Services And DNS; NetworkPolicy And Who Enforces It |
| 070 / 03 | Storage Through CSI | StorageClass, Claims And Provisioning; CSI Drivers And Their Objects; Reclaim, Expansion And Failure Cases |
| 080 / 01 | Custom APIs And Operator Installation | Reading A Custom Resource And Its Controller Contract; Custom Resources And Operators |
| 080 / 02 | CustomResourceDefinition Schema, Validation And Versions | CRD Structure And The OpenAPI Schema; Defaults, Pruning And CEL Validation Rules; Versions, Subresources And Printer Columns |
| 080 / 03 | Installing And Configuring An Operator | The Objects That Make Up An Operator; Installing In Order And Verifying; Configuring, Status, Finalizers And Removal |

## Author Review

The [curriculum map](CURRICULUM.md) records objective coverage. [Sources](SOURCES.md) support author review, and [assessment documentation](ASSESSMENTS.md) describes the reusable YAML contract. Each section has a `quiz.yaml` knowledge check registered in `astrona.yaml`, and `sections/final-domain-quiz.yaml` covers the whole domain. The older `questions.yaml` files and `assessments/` index are kept as the original question banks.

## Hands-On Coverage

This course has 24 module playgrounds, 26 module labs and 8 section capstone labs. Each lab task and solution is registered around the lab in `astrona.yaml`. All labs and playgrounds are UNTESTED: they were built and checked statically (configuration validation, shell syntax, YAML parsing and source paths) and have never been run.

| Module | Lab or capstone |
| --- | --- |
| 010/01 | Grant A ServiceAccount Pod Read Access With A Role |
| 010/02 | Issue A Client Certificate And Grant Pod Read Access |
| 010/03 | Grant Cluster-Scoped Read Access With A ClusterRole |
| 010/capstone |  |
| 020/01 | sections/section-020/module-01/labs/lab-01/config.yaml |
| 020/02 | Record Host Readiness From The API |
| 020/03 | Record Control Plane Ports From Static Pods |
| 020/capstone | Host Readiness Review Before Installation |
| 030/01 | sections/section-030/module-01/labs/lab-01/config.yaml |
| 030/02 | kubeadm Configuration Files And Init Phases |
| 030/03 | Map Certificates To Control Plane Components |
| 030/capstone | Join Review For A kubeadm Cluster |
| 040/01 | sections/section-040/module-01/labs/lab-01/config.yaml |
| 040/01 | sections/section-040/module-01/labs/lab-02/config.yaml |
| 040/02 | Audit Component Versions Before An Upgrade |
| 040/03 | Snapshot etcd And Record The Restore Facts |
| 040/capstone | Upgrade Readiness And Recovery Review |
| 050/01 | sections/section-050/module-01/labs/lab-01/config.yaml |
| 050/02 | Record The Control Plane Topology And Check A Quorum Proposal |
| 050/03 | Record Leader Election Facts And Grant Least-Privilege Lease Access |
| 050/capstone | Review A Control Plane For High Availability |
| 060/01 | sections/section-060/module-01/labs/lab-01/config.yaml |
| 060/01 | sections/section-060/module-01/labs/lab-02/config.yaml |
| 060/02 | Install, Upgrade And Roll Back A Helm Release |
| 060/03 | Build A Kustomize Overlay |
| 060/capstone | Adopt, Release And Customize A Cluster Component |
| 070/01 | sections/section-070/module-01/labs/lab-01/config.yaml |
| 070/02 | Record The Pod Network And Restrict Access With NetworkPolicy |
| 070/03 | Define A StorageClass, A CSIDriver And A Claim |
| 070/capstone | Secure And Persist The Probe Workload |
| 080/01 | sections/section-080/module-01/labs/lab-01/config.yaml |
| 080/02 | Tighten A CustomResourceDefinition Schema |
| 080/03 | Wire An Operator With Least Privilege |
| 080/capstone | Publish A Custom Type And Install Its Operator |
