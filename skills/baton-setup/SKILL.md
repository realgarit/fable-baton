---
name: baton-setup
description: One-time setup and health check for fable-baton. Use when the user asks to set up, configure, verify, or troubleshoot fable-baton - sets the default model to "fable" (with Opus and Sonnet fallback) in ~/.claude/settings.json, keeps a deliberate Opus choice, and verifies the plugin is fully installed.
---

# baton-setup

One-time setup for fable-baton. Run each step in order. Never rewrite `~/.claude/settings.json` wholesale - edit only the named keys and preserve everything else.

## Step 1 - Read current state

1. Read `~/.claude/settings.json` (if missing, you will create a minimal one).
2. Check `echo "$CLAUDE_CODE_SUBAGENT_MODEL"`. If set, warn the user: this variable silently overrides every agent's `model` frontmatter and defeats the tiering. Recommend unsetting it, but do not unset it yourself without approval.
3. Check what outranks the user settings file: `echo "$ANTHROPIC_MODEL"`, and a `model` key in `.claude/settings.json`, `.claude/settings.local.json` (current project), or managed settings. Any of these beats `~/.claude/settings.json`. Report them, but do not edit them.

A note on the `best` alias: from Claude Code 2.1.321 on, `best` resolves to the same model as `opus`. Older guides (and older versions of this skill) used `best` to get Fable. Treat an existing `"best"` as a stale setup, not as a deliberate choice.

## Step 2 - Propose changes and get approval

Show the user exactly what you will change before writing anything:

| Key | Rule |
|---|---|
| `model` | Ask which model should conduct: Fable (recommended) or keep the current setting. Then: absent and Fable chosen → set `"fable"`. `"best"` → explain that it now means Opus and offer `"fable"`; if the user wants Opus, write `"opus"` so the intent is explicit. `"opus"`, `"opus[1m]"`, or a `claude-opus-*` ID → this is a deliberate choice; keep it unless the user asks to switch. `"fable"` or a `claude-fable-*` ID → no change. Anything else → ask: keep theirs, or switch to `"fable"`? |
| `fallbackModel` | If absent → add `["opus", "sonnet"]` (covers overload/unavailability). If present → leave it. |
| `availableModels` | Only if the key already exists (it is an allowlist): ensure it contains `"opus"`, `"sonnet"`, `"haiku"`, and the chosen main-model value. If absent → do not add it. |

Back up the file first: copy it to `~/.claude/settings.json.baton-backup-<YYYYMMDD-HHMMSS>` (skip if the file didn't exist).

## Step 3 - Apply and validate

Apply the approved edits, then validate: `jq empty ~/.claude/settings.json` must exit 0 (or parse the JSON yourself if `jq` is unavailable).

If Claude Code rejects the `fable` alias at startup (older versions), suggest updating Claude Code. Do not fall back to `"best"`: on current versions it silently gives Opus.

## Step 4 - Verify the install

1. Confirm the four agents are available: scout, executor, architect, verifier (ask "which subagent types are available?" or check the Agent tool's list).
2. Confirm the orchestration policy is present in context (it is injected at session start; in a session started before install it won't be - that's expected).
3. Tell the user to restart their Claude Code session: agents and the model setting load at session start.
4. Give the user the check to run in the fresh session: `/model` with no argument shows the resolved model on its Default row. If Fable was chosen, it must name Fable. If it names Opus, something outranks the user settings (see Step 1.3), the account has no Fable access, or Claude Code is too old for the `fable` alias. Writing the setting is not proof that Fable is running; only this check is.

## Step 5 - Report

Summarize: what changed, what was skipped, where the backup is, that a restart is needed, and the `/model` check from Step 4. Do not report Fable as active until the user has confirmed that check.

## Uninstall (on request)

1. `/plugin uninstall fable-baton` removes the agents, hook, and this skill.
2. In `~/.claude/settings.json`: restore `model` from the oldest `settings.json.baton-backup-*` file, or remove the key if the backup has none. Remove `fallbackModel` if the user doesn't want it.
