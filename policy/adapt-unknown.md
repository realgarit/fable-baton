# Session model adaptation: not yet detected

This session's main model could not be detected at startup, so the policy above is written for a Fable session. You know which model you are. Apply the matching override below before your first delegation.

- Fable: the policy above stands as written.
- Opus: `architect` runs on your own tier, so delegating to it saves no cost. Use it only for context isolation or an independent second opinion on high-risk work. Complex implementation and deep debugging stay with you. `executor`, `scout`, and `verifier` are cheaper, so keep routing labor to them. In security-context sessions the safeguard rationale above applies to Fable rather than to you, so keep the deep analysis yourself and still route evidence collection to `scout`.
- Sonnet: `executor` is your own tier, so use it only for context isolation or parallel edit streams, and do implementation inline. `architect` (Opus) costs more than you, so use it only for problems you attempted and could not solve, or for high-risk review. `scout` and `verifier` stay cheaper, so keep discovery and checking with them.
- Haiku: route anything beyond simple lookups and mechanical edits upward. `executor` for implementation, `architect` for design, debugging, and high-risk work. Correctness beats cost at this tier.

From the next turn on, the hooks detect the model from the transcript and confirm or replace this. If a later notice names a different tier, that one wins.
