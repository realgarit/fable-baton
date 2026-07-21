#!/bin/bash
# fable-baton UserPromptSubmit hook: re-assert the orchestration policy on every turn.
# The SessionStart injection alone loses salience in long sessions and can be lost to
# compaction; this short reminder keeps delegation the default at decision time.
# The reminder is tier-aware: the SessionStart hook persists the session's model tier
# to a state file, and the text adapts so long sessions on Sonnet or Haiku are not
# nudged toward routing that no longer saves anything. Any failure to read the tier
# falls back to the base (Fable) reminder.

tier="$(python3 -c '
import json
import os
import re
import sys
import tempfile

session = "default"
try:
    payload = json.load(sys.stdin)
    session = str(payload.get("session_id") or "default")
except Exception:
    pass

safe_session = re.sub(r"[^A-Za-z0-9-]", "", session) or "default"
tier = "fable"
try:
    with open(os.path.join(tempfile.gettempdir(), "fable-baton-tier-" + safe_session)) as f:
        value = f.read().strip()
    if value in ("fable", "opus", "sonnet", "haiku"):
        tier = value
except Exception:
    pass

print(tier)
' 2>/dev/null)"

case "$tier" in
  sonnet)
    cat <<'EOF'
[fable-baton] Delegation check for this turn (Sonnet session): discovery and bulk reading go to scout, verification to verifier; implementation you do inline at your own tier, using executor only for context isolation or parallel edit streams. architect (Opus) costs more than you now: only for problems you attempted and could not solve, or high-risk review. Skills define what to do, not who does it.
EOF
    ;;
  opus)
    cat <<'EOF'
[fable-baton] Delegation check for this turn (Opus session): searching, reading files, editing, testing, and verifying go to the cheaper agents (scout, executor, verifier via the Agent tool); architect is your own tier, so use it only for context isolation or a second opinion. Tripwire: reaching for a 3rd consecutive inline Bash/Read/Grep/Edit call means that block belongs to an agent. Skills define what to do, not who does it.
EOF
    ;;
  haiku)
    cat <<'EOF'
[fable-baton] Delegation check for this turn (Haiku session): anything beyond simple lookups and mechanical edits goes UP - executor for implementation, architect for design, debugging, and high-risk work. Correctness beats cost at this tier.
EOF
    ;;
  *)
    cat <<'EOF'
[fable-baton] Delegation check for this turn: searching, reading files, editing, testing, and verifying go to agents (scout, executor, architect, verifier via the Agent tool); you keep judgment, decisions, and the final answer. Tripwire: reaching for a 3rd consecutive inline Bash/Read/Grep/Edit call means that block belongs to an agent. Skills define what to do, not who does it: delegate their mechanical steps too. Exempt: conversational turns, one quick lookup, a one-line edit. No exemptions in security-context sessions.
EOF
    ;;
esac
