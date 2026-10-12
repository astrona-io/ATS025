---
draft: true
exam_objectives:
- Understand extension interfaces (CNI, CSI, CRI, etc.)
---
# Understand extension interfaces (CNI, CSI, CRI, etc.)

The node can start a container but cannot attach its volume or connect its Pod network. Runtime, networking and storage integrations provide different responsibilities.

The explanations identify the responsible components, compare intended and observed state, and work through the decisions needed to preserve the requirement. Read the worked examples as reasoning about a proposed system; no environment is started by this section.

Each module begins with its goals and ends with a summary. Reusable YAML knowledge checks follow the section summary and are registered separately for future presentation.

## Learning Outcomes

- Distinguish CNI, CSI and CRI responsibilities.
- Identify core-to-extension integration points.
- Evaluate optional driver and policy capabilities.
- Diagnose the responsible extension stage.
