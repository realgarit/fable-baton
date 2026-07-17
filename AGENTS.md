# fable-baton — Agent instructions

> Canonical instructions for all coding agents (Claude Code, Codex, GitHub Copilot). Claude loads this via the CLAUDE.md stub.

fable-baton is a Claude Code plugin that turns Fable 5 into a token-frugal orchestrator: Fable keeps judgment (intent, architecture, tradeoffs, review) while tiered subagents on Opus, Sonnet, and Haiku do the labor. It ships four agents (`scout`/Haiku, `executor`/Sonnet, `architect`/Opus, `verifier`/Haiku), a orchestration policy injected via a SessionStart hook, and enforcement hooks (SessionStart, UserPromptSubmit, PostToolUse) that keep nudging delegation through a session.

Repo layout:
- `agents/` — the four tiered subagent definitions (`architect.md`, `executor.md`, `scout.md`, `verifier.md`)
- `hooks/` — `hooks.json` plus the shell scripts (`session-start.sh`, `prompt-nudge.sh`, `inline-counter.sh`) that enforce delegation
- `policy/orchestration.md` — the orchestration policy text injected at session start
- `skills/baton-setup/` — the one-time setup skill that sets the default model to `best`
- `.claude-plugin/` — `plugin.json` (plugin manifest) and `marketplace.json`
- `assets/` — README images/GIFs

No package manifest / build step; this is a plugin distributed as plain files (Markdown, JSON, shell). CI (`.github/workflows/ci.yml`) validates JSON files, lints for em/en dashes, checks shell syntax (`bash -n hooks/*.sh`), and smoke-tests the hooks by running them directly with `CLAUDE_PLUGIN_ROOT=.` set.

## Cross-agent conventions

- This file (`AGENTS.md`) is the single source of truth for agent instructions in this repo. `CLAUDE.md` and `.github/copilot-instructions.md` are pointers to it — never edit them, never duplicate content into them.
- Reusable skills live in `.claude/skills/` (one folder per skill with a `SKILL.md`). GitHub Copilot reads that directory natively; Codex sees it via the `.agents/skills` symlink. New skills always go in `.claude/skills/`.
- Claude-specific subagent definitions live in `.claude/agents/`. If you are not Claude Code, you may read them as role/process guidance.
- Session continuity across tools: before ending substantial work in ANY tool (Claude Code, Codex, Copilot), record durable context — decisions made, gotchas discovered, in-progress state worth resuming — in the "Working notes" section below, or fold it into the relevant section above. This is the shared memory between agents.

## Working notes

<!-- Any agent: append short dated notes here (YYYY-MM-DD — note). Prune notes when stale or once folded into the sections above. -->
