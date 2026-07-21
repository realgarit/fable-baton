#!/bin/bash
# fable-baton UserPromptSubmit hook: re-assert the orchestration policy on every turn.
# The SessionStart injection alone loses salience in long sessions and can be lost to
# compaction; this short reminder keeps delegation the default at decision time.
# The reminder is tier-aware: the SessionStart hook persists the session's model tier
# to a state file, and the text adapts so long sessions on Sonnet or Haiku are not
# nudged toward routing that no longer saves anything. Any failure to read the tier
# falls back to the base (Fable) reminder.

detection="$(python3 -c '
import json
import os
import re
import sys
import tempfile


def tier_from_model(model):
    if "fable" in model or "mythos" in model:
        return "fable"
    if "opus" in model:
        return "opus"
    if "sonnet" in model:
        return "sonnet"
    if "haiku" in model:
        return "haiku"
    return None


def tier_from_transcript(transcript_path):
    try:
        if not transcript_path or not os.path.isfile(transcript_path):
            return None
        size = os.path.getsize(transcript_path)
        with open(transcript_path, "rb") as f:
            f.seek(max(0, size - 262144))
            data = f.read()
        lines = data.decode("utf-8", errors="replace").splitlines()
        for line in reversed(lines):
            try:
                entry = json.loads(line)
            except Exception:
                continue
            if entry.get("isSidechain"):
                continue
            message = entry.get("message")
            if not isinstance(message, dict):
                continue
            m = message.get("model")
            if not isinstance(m, str):
                continue
            found = tier_from_model(m.lower())
            if found:
                return found
    except Exception:
        return None
    return None


session = "default"
transcript_path = None
try:
    payload = json.load(sys.stdin)
    session = str(payload.get("session_id") or "default")
    transcript_path = payload.get("transcript_path")
except Exception:
    pass

safe_session = re.sub(r"[^A-Za-z0-9-]", "", session) or "default"
tier_file = os.path.join(tempfile.gettempdir(), "fable-baton-tier-" + safe_session)

tier = "fable"
try:
    with open(tier_file) as f:
        value = f.read().strip()
    if value in ("fable", "opus", "sonnet", "haiku"):
        tier = value
except Exception:
    pass

detected = tier_from_transcript(transcript_path)
if detected and detected != tier:
    tier = detected
    try:
        with open(tier_file, "w") as f:
            f.write(tier)
    except Exception:
        pass

announce = "quiet"
if tier in ("opus", "sonnet", "haiku"):
    marker_file = os.path.join(tempfile.gettempdir(), "fable-baton-adapted-" + safe_session)
    marker_value = None
    try:
        with open(marker_file) as f:
            marker_value = f.read().strip()
    except Exception:
        marker_value = None
    if marker_value != tier:
        announce = "announce"
        try:
            with open(marker_file, "w") as f:
                f.write(tier)
        except Exception:
            pass

print(tier)
print(announce)
' 2>/dev/null)"

tier="$(echo "$detection" | sed -n "1p")"
announce="$(echo "$detection" | sed -n "2p")"
if [ -z "$tier" ]; then
  tier="fable"
fi

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

if [ "$announce" = "announce" ]; then
  echo
  cat "${CLAUDE_PLUGIN_ROOT}/policy/adapt-${tier}.md"
fi
