---
name: refinement-workflow
description: Improve an implementation through repeated rounds of independent, parallel adversarial review and targeted fixes. Use when the user asks for iterative refinement, multiple review loops, or review-driven quality improvements rather than a one-off review.
---

# Refinement workflow

Alternate independent review with targeted implementation changes until the quality gate passes or the round budget is exhausted. Reviewers try to disprove different claims about the implementation; the coordinating agent assesses their evidence and owns the fixes.

This workflow is harness-independent. Use whatever subtask or agent facility is available. Do not require a particular CLI, issue tracker, or hosting platform.

## Defaults

- Run at least two review rounds, with a maximum of four. A round consists of parallel reviews, triage, fixes if needed, and verification. User-specified round counts or budgets override these defaults.
- Use the same model as the coordinating agent for every reviewer when possible. Do not silently select cheaper or weaker models. If model selection or the current model is unavailable, use the available default and disclose the limitation.
- Launch fresh reviewer contexts each round. Reviewers are read-only; only the coordinator edits the implementation.
- Use all three roles: `reviewer-correctness`, `reviewer-readability`, and `reviewer-robustness`. Each also follows the shared `reviewer` skill.
- If parallel subtasks are unavailable, perform separate role-specific passes sequentially and disclose that they were not independent parallel reviews. Do not simulate agents or claim independence that did not exist.

## 1. Establish the review packet

Before dispatching reviewers, establish:

- The problem statement, acceptance criteria, constraints, and explicit non-goals. Use the user's request and any supplied issue or specification. Ask if a material requirement is missing; do not invent one.
- A fixed comparison baseline and the scope of the proposed change. Include relevant committed, staged, unstaged, and untracked content, not just the committed diff. Preserve unrelated user work.
- Repository instructions, applicable standards, and the `code-style` skill.
- Relevant tests and verification commands, including known failures or environment limitations.
- The minimum and maximum number of rounds and any user-specified priorities.

Give every reviewer the same implementation snapshot and requirements. Freeze edits while reviewers are running; if the snapshot changes, rerun affected reviews rather than combining stale results. Do not commit merely to create a snapshot.

Provide skill contents or readable paths explicitly. Do not assume a child agent inherits the conversation, loaded skills, or knowledge of the task.

## 2. Run adversarial reviews in parallel

Launch one independent subtask per role against the same snapshot:

| Role | Claim to challenge |
| --- | --- |
| Correctness | This implementation solves the stated problem, completely and without unrelated behavior changes. |
| Readability | This implementation is understandable and follows the applicable style and design guidance. |
| Robustness | This implementation remains safe and correct under edge cases, failures, and hostile input. |

Include the shared reviewer instructions, the role-specific skill, review packet, and required finding format in each prompt. Ask reviewers to inspect surrounding callers and tests as needed, not just isolated changed lines.

Adversarial means searching for counterexamples, not manufacturing criticism. Do not require a minimum finding count. Do not share other reviewers' findings before their independent passes complete.

## 3. Triage the findings

Wait for all roles, then assess each finding against the code, requirements, and evidence. A failed or incomplete reviewer is not a clean review; retry it within the budget or report the gap.

Maintain a compact finding ledger in the working context with role, severity, location, evidence, disposition, and verification status. No separate report file is required unless requested.

- Accept supported findings that warrant a change.
- Reject unsupported findings with a concrete reason.
- Defer findings only with an explicit reason and visible residual risk. Deferring a blocking finding does not satisfy the quality gate.
- Merge duplicates while preserving their role attribution. Resolve contradictory advice by returning to the requirements and applicable standards, not by counting votes.
- Ask the user when a resolution requires a product decision, a scope expansion, or an incompatible behavior change.

Prioritize correctness and safety, but do not let a green test suite excuse unreadable code. Conversely, do not rewrite clear code solely to satisfy a reviewer's personal preference.

## 4. Apply targeted fixes and verify

The coordinator applies accepted fixes in coherent groups, preserving unrelated work. Add, improve, consolidate, or remove tests as appropriate under `code-style`; do not weaken meaningful assertions to make a failure disappear.

Run applicable tests, type checks, linters, and formatters. Record what actually ran and distinguish existing failures from regressions. A reviewer saying a fix looks right is not a substitute for executable verification where it is available.

Do not commit or push unless the user explicitly requested it.

## 5. Review again and stop deliberately

Start the next round with fresh reviewers against the complete updated change, not just the latest fix. Keep the original requirements and baseline stable. Ask reviewers to form their own findings first, then verify prior accepted findings and their fixes. They must also look for regressions introduced during refinement.

The quality gate passes only when:

- The minimum number of rounds has completed.
- All roles have completed review of the current snapshot.
- No supported blocking findings remain, and no material requirement or requirement-coverage gaps remain unresolved. Missing specification context cannot count as a clean correctness review.
- Accepted fixes have been reviewed in a subsequent round; a final-round edit is not automatically approved.
- Applicable verification passes. Unexplained failures and change-induced regressions prevent passage. Demonstrably unrelated baseline failures or required checks that could not run must be reported with evidence and leave the result qualified, not fully verified.

If the minimum is met and the gate passes, stop. Do not keep polishing merely to consume the maximum budget. If the budget is exhausted, stop and report unresolved issues, unreviewed final fixes, and the next useful action. Never claim sufficient quality just because the loop ended.

If rounds repeat contradictory preferences or reveal a requirement/design impasse, stop the churn and ask for a decision. Escalate urgent safety findings immediately rather than waiting for all rounds.

## Final report

Summarize rounds completed, reviewer roles and model selection, fixes made, rejected or deferred findings with reasons, checks performed, and remaining risks. State whether the quality gate passed, remained qualified, or was not reached. Be explicit about any sequential fallback or unavailable reviewer.
