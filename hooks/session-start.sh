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

tier = "fable"
session = "default"
try:
    payload = json.load(sys.stdin)
    session = str(payload.get("session_id") or "default")
    model = str(payload.get("model") or "").lower()
    if "opus" in model:
        tier = "opus"
    elif "sonnet" in model:
        tier = "sonnet"
    elif "haiku" in model:
        tier = "haiku"
except Exception:
    pass

safe_session = re.sub(r"[^A-Za-z0-9-]", "", session) or "default"
try:
    with open(os.path.join(tempfile.gettempdir(), "fable-baton-tier-" + safe_session), "w") as f:
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
