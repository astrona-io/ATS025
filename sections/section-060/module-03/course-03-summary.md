---
draft: true
exam_objectives:
- Use Helm and Kustomize to install cluster components
---
# Summary

Kustomize customises plain YAML without templates. A kustomization is a directory with a `kustomization.yaml` file. A base is complete on its own, and an overlay lists a base in its `resources` field and adds changes. The base files are never edited. The `kubectl kustomize` command renders the result on the client, and `kubectl apply -k` sends it to the API server, which cannot tell that Kustomize was used.

Transformers change one kind of field on every object: the namespace, a name prefix or suffix, labels, annotations, images and replica counts. They also fix references, so a renamed object is still found by the objects that name it. Selectors of an existing Deployment cannot change, so selector labels must be chosen before the first apply. A transformer that matches nothing is silent, so the rendered output must always be read.

Patches change one field of one object. A strategic merge patch is partial YAML that Kubernetes merges by field keys, such as the container name. A JSON 6902 patch is a list of operations on exact paths and needs a target. Patches match the names used in the base, before a prefix is added.

A generator builds a ConfigMap or Secret from literals or files and adds a hash of the content to the name. A changed value gives a new name, which changes the pod template and triggers a rolling update. The `merge` behavior lets an overlay change a base generator. The old generated object is not removed by `kubectl apply`.

The cycle is render, compare with `kubectl diff -k`, apply and verify. Kustomize keeps no release record, no revision history and no rollback, so version control holds the history. It differs from Helm, which templates and records releases, and the two can be combined by customising the YAML that a chart renders.

<!-- astrona:playground:destroy -->
