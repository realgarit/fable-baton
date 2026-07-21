#!/bin/bash
# fable-baton SessionStart hook: inject the orchestration policy as session context.
# Stdout from a SessionStart hook is added to the model's context.
# The hook input JSON may carry the session's model. When the main model is not
# Fable, append a tier adaptation so the cost logic stays correct, and persist
# the detected tier to a state file so the other hooks can read it. Any parse
# failure falls back to the base (Fable) policy - this must never break a session.

tier="$(python3 -c '
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


tier = "fable"
session = "default"
try:
    payload = json.load(sys.stdin)
    session = str(payload.get("session_id") or "default")
    model = str(payload.get("model") or "").lower()
    found = tier_from_model(model)
    if found:
        tier = found
    else:
        found = tier_from_transcript(payload.get("transcript_path"))
        if found:
            tier = found
except Exception:
    pass

safe_session = re.sub(r"[^A-Za-z0-9-]", "", session) or "default"
try:
    with open(os.path.join(tempfile.gettempdir(), "fable-baton-tier-" + safe_session), "w") as f:
        f.write(tier)
except Exception:
    pass

# The adaptation for this tier is injected below; mark it announced so the
# per-prompt nudge does not repeat the full text on the first turn.
if tier in ("opus", "sonnet", "haiku"):
    try:
        with open(os.path.join(tempfile.gettempdir(), "fable-baton-adapted-" + safe_session), "w") as f:
            f.write(tier)
    except Exception:
        pass

print(tier)
' 2>/dev/null)"

cat "${CLAUDE_PLUGIN_ROOT}/policy/orchestration.md"

case "$tier" in
  opus|sonnet|haiku)
    echo
    cat "${CLAUDE_PLUGIN_ROOT}/policy/adapt-${tier}.md"
    ;;
esac
