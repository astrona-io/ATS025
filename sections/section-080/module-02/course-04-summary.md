---
draft: true
exam_objectives:
- Understand CRDs, install and configure operators
---
# Summary

A CustomResourceDefinition is the complete contract that the API server enforces for a custom resource. It names the group, kind and plural, sets the scope, and holds one schema per version. The API server registers the new endpoint, stores the objects in etcd and checks every write against the schema without any controller taking part.

The schema must be structural: every node declares a type. That requirement lets the API server prune unknown fields, apply defaults and run constraints such as required fields, enumerations and numeric ranges. Strict field validation turns pruned fields into errors for the user, and the explain command reads the schema back so users can discover the fields.

Defaults are applied when an object is written and when it is read from etcd, and they need an existing parent node. Validation rules written in the Common Expression Language compare fields of one object, and rules that use the previous value run only on update, which makes a field immutable. The API server limits the cost of a rule, so bounded lists and strings are needed.

A type can have several versions. Exactly one is the storage version, and the others are converted on the fly with either a field-preserving no-op or a conversion webhook. The list of stored versions protects objects in etcd from being orphaned when a version is removed.

The status subresource separates the writer of the desired state from the writer of the observed state. The scale subresource connects a type to scaling tools. Printer columns control what a list shows. None of these features starts any workload: the behavior behind a custom resource always comes from a controller that is a separate program.

<!-- astrona:playground:destroy -->
