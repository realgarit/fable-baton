#!/bin/bash
# fable-baton SessionStart hook: inject the orchestration policy as session context.
# Stdout from a SessionStart hook is added to the model's context.
cat "${CLAUDE_PLUGIN_ROOT}/policy/orchestration.md"
