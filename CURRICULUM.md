# Curriculum And Authoring Plan

Exam: Certified Kubernetes Administrator (CKA). Domain: Cluster Architecture, Installation & Configuration (25%).
Source: [official curriculum](https://training.linuxfoundation.org/certification/certified-kubernetes-administrator-cka/), checked 2026-10-10.
Objectives are attributed to The Linux Foundation and CNCF.

Preparation scaffold; content authoring has not started.

| Section | Official objective | Authoring status |
| --- | --- | --- |
| 010 | Manage role based access control (RBAC) | Planned |
| 020 | Prepare underlying infrastructure for installing a Kubernetes cluster | Planned |
| 030 | Create and manage Kubernetes clusters using kubeadm | Planned |
| 040 | Manage the lifecycle of Kubernetes clusters | Planned |
| 050 | Implement and configure a highly-available control plane | Planned |
| 060 | Use Helm and Kustomize to install cluster components | Planned |
| 070 | Understand extension interfaces (CNI, CSI, CRI, etc.) | Planned |
| 080 | Understand CRDs, install and configure operators | Planned |

Before building content:

- Recheck the curriculum and refine broad objectives into teachable modules.
- Choose and record the environment versions and any image dependencies.
- Write the introduction and remove placeholder notices only when it is ready.
- Build short parts and runnable playgrounds; add graded labs where appropriate.
- Add quizzes and a capstone when the completed domain needs them.
- Check real outputs and reference solutions, and update `astrona.yaml`.
- Remove `draft: true` from completed technical pages after review.
- Publish the course only after the maintainer approves the completed content.
