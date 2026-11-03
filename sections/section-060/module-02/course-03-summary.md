---
draft: true
exam_objectives:
- Use Helm and Kustomize to install cluster components
---
# Summary

A Helm chart is a directory with fixed file names: `Chart.yaml` for the metadata, `values.yaml` for the defaults, `templates/` for the YAML templates and optional folders for dependencies and custom resource definitions. The `helm` command renders the templates on the client. The API server only receives finished objects and checks them as it checks any other object. The chart `version` identifies the package, and the `appVersion` is information that changes nothing unless a template uses it.

A value has an effect only when a template reads it. Helm merges the chart defaults, the values files and the `--set` flags in that order, and a later source wins. Maps merge key by key, and lists are replaced as a whole. Rendering with `helm template` shows the result without a cluster, and a server-side dry run asks the API server to validate it. A typo in a key is accepted silently unless the chart uses `required` or a values schema.

A release is a named installation with numbered revisions. Helm keeps each revision as a Secret in the release namespace, so no server part runs in the cluster. The status `deployed` says that Helm sent the objects, and the application can still be unhealthy unless the install waited for readiness and the pods were checked.

An upgrade starts from the chart defaults plus the values given in the command, so earlier values disappear unless they are passed again, stored in a values file or reused on purpose. Helm compares the previous manifest, the live object and the new manifest when it patches. A rollback adds a new revision that carries the content of an older one. An uninstall removes the objects and records, except objects with the keep policy and custom resource definitions from the `crds/` folder.

An object that already exists without Helm ownership metadata blocks an install. The label `app.kubernetes.io/managed-by: Helm` and the two `meta.helm.sh` annotations let Helm adopt it in place.

<!-- astrona:playground:destroy -->
