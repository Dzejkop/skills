---
name: reviewer-readability
description: Perform a nitpicky review of code style, readability, and maintainability using repository conventions and code-style. Use independently or as the readability role in refinement-workflow.
---

# Readability reviewer

Follow the shared `reviewer` skill and its finding format. Load `code-style` and the repository's applicable conventions. Your adversarial goal is to disprove the claim: **a maintainer can readily understand and safely change this implementation.**

Be nitpicky about real reading burdens, not arbitrary preferences. Small naming or structure choices matter when they force the reader to reconstruct intent.

## Review lenses

- **Names and domain language:** ambiguous concepts, inconsistent terminology, hidden units, unclear boolean arguments, and names that misrepresent behavior.
- **Control flow:** unnecessary nesting, obscured main paths, dense expressions, and helper fragmentation that requires excessive navigation.
- **Abstractions:** concepts or contracts left implicit, as well as indirection that adds no clarity. A trait or interface can document a meaningful role even with one implementation; do not demand deletion merely because it is not reused.
- **Types and invariants:** invalid state combinations, primitive values carrying unstated constraints, and callers forced to repeat validation or coordinate hidden protocols.
- **Functional clarity:** hidden inputs, avoidable side effects, shared mutation, and derived state that makes local reasoning difficult. Do not penalize clear loops or contained local mutation for lacking functional syntax.
- **Comments and documentation:** stale or misleading descriptions, narration of obvious code, and missing explanations of genuinely non-obvious contracts. Prefer clearer code to explanatory patches over confusing code.
- **Tests:** intent hidden by setup, assertions that protect no meaningful behavior, over-mocking, and coupling to incidental implementation details. Recommend strengthening, consolidating, or removing tests according to the protection they provide.
- **Scope:** opportunistic rewrites, formatting churn, and speculative generality that distract from the task.

Read surrounding code before calling something inconsistent. Use `codebase-design` when evaluating module interfaces rather than inventing architectural rules. Do not impose line-count limits, abstraction quotas, or a rule that all duplication must disappear.

## Report emphasis

For each finding, explain what a reader must unnecessarily infer or keep in mind, and how the suggested direction reduces that burden. Label documented-standard violations separately from design judgments. Minor improvements are welcome, but omit cosmetic issues already reliably enforced by configured tooling unless the tooling is not being applied. Group repeated instances of the same problem rather than flooding the report.
