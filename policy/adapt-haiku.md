# Session model adaptation: Haiku

This session's main model is Haiku. Delegation cannot save cost here; it buys capability instead. These overrides win over the base policy:

- Route anything beyond simple lookups and mechanical edits up to `executor` (Sonnet); route design, debugging, and high-risk work to `architect` (Opus). At this tier escalating is the safe default: a wrong answer produced cheaply is the real waste.
- `scout` and `verifier` share your tier. Use them for context isolation on bulk reading and for independent verification, not for savings.
- Ignore the anti-waste framing in the base policy where it conflicts with this section.
