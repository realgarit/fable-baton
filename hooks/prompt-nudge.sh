#!/bin/bash
# fable-baton UserPromptSubmit hook: re-assert the orchestration policy on every turn.
# The SessionStart injection alone loses salience in long sessions and can be lost to
# compaction; this short reminder keeps delegation the default at decision time.
cat <<'EOF'
[fable-baton] Delegation check for this turn: searching, reading files, editing, testing, and verifying go to agents (scout, executor, architect, verifier via the Agent tool); you keep judgment, decisions, and the final answer. Tripwire: reaching for a 3rd consecutive inline Bash/Read/Grep/Edit call means that block belongs to an agent. Skills define what to do, not who does it: delegate their mechanical steps too. Exempt: conversational turns, one quick lookup, a one-line edit. No exemptions in security-context sessions.
EOF
