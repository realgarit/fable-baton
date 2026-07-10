---
name: baton-setup
description: One-time setup and health check for fable-baton. Use when the user asks to set up, configure, verify, or troubleshoot fable-baton — sets the default model to "best" (Fable 5 with Opus fallback) in ~/.claude/settings.json and verifies the plugin is fully installed.
---

# baton-setup

One-time setup for fable-baton. Run each step in order. Never rewrite `~/.claude/settings.json` wholesale — edit only the named keys and preserve everything else.

## Step 1 — Read current state

1. Read `~/.claude/settings.json` (if missing, you will create a minimal one).
2. Check `echo "$CLAUDE_CODE_SUBAGENT_MODEL"`. If set, warn the user: this variable silently overrides every agent's `model` frontmatter and defeats the tiering. Recommend unsetting it, but do not unset it yourself without approval.

## Step 2 — Propose changes and get approval

Show the user exactly what you will change before writing anything:

| Key | Rule |
|---|---|
| `model` | If absent → set `"best"`. If present with a different value → ask: keep theirs, or switch to `"best"`? (`best` resolves to Fable 5 when the account has access, otherwise the latest Opus.) If already `"best"` → no change. |
| `fallbackModel` | If absent → add `["opus", "sonnet"]` (covers overload/unavailability). If present → leave it. |
| `availableModels` | Only if the key already exists (it is an allowlist): ensure it contains `"opus"`, `"sonnet"`, `"haiku"`, and the chosen main-model value. If absent → do not add it. |

Back up the file first: copy it to `~/.claude/settings.json.baton-backup-<YYYYMMDD-HHMMSS>` (skip if the file didn't exist).

## Step 3 — Apply and validate

Apply the approved edits, then validate: `jq empty ~/.claude/settings.json` must exit 0 (or parse the JSON yourself if `jq` is unavailable).

If Claude Code rejects the `best` alias at startup (older versions), fall back to `"opus"` and suggest updating Claude Code.

## Step 4 — Verify the install

1. Confirm the four agents are available: scout, executor, architect, verifier (ask "which subagent types are available?" or check the Agent tool's list).
2. Confirm the orchestration policy is present in context (it is injected at session start; in a session started before install it won't be — that's expected).
3. Tell the user to restart their Claude Code session: agents and the model setting load at session start.

## Step 5 — Report

Summarize: what changed, what was skipped, where the backup is, and that a restart is needed.

## Uninstall (on request)

1. `/plugin uninstall fable-baton` removes the agents, hook, and this skill.
2. In `~/.claude/settings.json`: restore `model` from the oldest `settings.json.baton-backup-*` file, or remove the key if the backup has none. Remove `fallbackModel` if the user doesn't want it.
