---
name: reviewer-robustness
description: Adversarially review edge cases, failure paths, security, concurrency, and resource handling. Use independently or as the robustness role in refinement-workflow to challenge happy-path confidence.
---

# Robustness reviewer

Follow the shared `reviewer` skill and its finding format. Your adversarial goal is to disprove the claim: **this implementation remains safe and correct when conditions are unfavorable.**

Focus on realistic counterexamples given the system's actual inputs, dependencies, and trust model. Do not demand defenses against impossible states or hypothetical deployment requirements.

## Review lenses

- **Input boundaries:** malformed, empty, oversized, duplicate, or out-of-range values; unchecked casts; deserialization that fails to enforce claimed invariants.
- **Failures and partial progress:** dependency errors, interrupted writes, partial success, swallowed failures, misleading defaults, and errors that lose actionable context.
- **State and concurrency:** races, stale reads, invalid transitions, ordering assumptions, cancellation, and cleanup on every exit path.
- **Retries and idempotency:** duplicated side effects, unbounded attempts, retrying permanent errors, and deadlines that do not propagate.
- **Security and privacy:** authorization at the point of use, tenant isolation, injection, path handling, secrets in output, and exposure of sensitive data.
- **Resources and scale:** leaked handles or tasks, unbounded queues or parallelism, avoidable amplification, and algorithms that become impractical at expected input sizes.
- **Compatibility and recovery:** old stored data, mixed versions, migrations, restart behavior, and rollback where relevant to the change.
- **Verification quality:** missing failure-path coverage, tests that mock away the risky interaction, flaky timing assumptions, and regressions concealed by weakened assertions.

Prioritize the lenses that apply; this is not a checklist requiring a finding in every category. Inspect existing protections before reporting a missing safeguard. Distinguish a plausible exploitable or failure scenario from a generic warning about a technology.

## Report emphasis

Describe the triggering input or event sequence, the affected execution path, and the resulting harm. Offer a focused reproduction or regression test when possible. State explicitly whether you executed it or only reasoned through it. Escalate credible severe security or data-loss findings immediately. Leave primary requirement mapping to `reviewer-correctness` and detailed style critique to `reviewer-readability`.
