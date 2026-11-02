---
draft: true
exam_objectives:
- Use Helm and Kustomize to install cluster components
---
# Starting Environment

The existing chart is supplied in full below. Save its three files in a local `chart` directory before inspecting or installing it. Release `demo` has not been installed.

Use the provided `probe-chart` chart, release `demo` in `starfleet`, and two replicas. Install version one and retain a deployed Helm release with effective value `replicaCount: 2`. The client must reach the `helm-probe` Service. Do not replace Helm ownership with a manually applied Deployment.
