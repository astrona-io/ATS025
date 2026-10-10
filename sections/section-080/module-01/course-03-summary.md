---
draft: true
exam_objectives:
- Understand CRDs, install and configure operators
---
# Summary

Custom definitions register schemas, while operators perform application-specific reconciliation through their controllers. Both type availability and usable controller behavior are needed for the intended lifecycle.

Installation requires suitable versions, permissions and dependencies. Instance acceptance and condition names do not provide universal operational guarantees, and finalizer cleanup must follow the application contract.
