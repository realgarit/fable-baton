# fable-baton: Agent instructions

> Canonical instructions for all coding agents (Claude Code, Codex, GitHub Copilot). Claude loads this via the CLAUDE.md stub.

fable-baton is a Claude Code plugin that turns Fable 5 into a token-frugal orchestrator: Fable keeps judgment (intent, architecture, tradeoffs, review) while tiered subagents on Opus, Sonnet, and Haiku do the labor. It ships four agents (`scout`/Haiku, `executor`/Sonnet, `architect`/Opus, `verifier`/Haiku), a orchestration policy injected via a SessionStart hook, and enforcement hooks (SessionStart, UserPromptSubmit, PostToolUse) that keep nudging delegation through a session.

Repo layout:
- `agents/`: the four tiered subagent definitions (`architect.md`, `executor.md`, `scout.md`, `verifier.md`)
- `hooks/`: `hooks.json` plus the shell scripts (`session-start.sh`, `prompt-nudge.sh`, `inline-counter.sh`) that enforce delegation
- `policy/orchestration.md`: the orchestration policy text injected at session start
- `skills/baton-setup/`: the one-time setup skill that sets the default model to `best`
- `.claude-plugin/`: `plugin.json` (plugin manifest) and `marketplace.json`
- `assets/`: README images/GIFs

No package manifest / build step; this is a plugin distributed as plain files (Markdown, JSON, shell). CI (`.github/workflows/ci.yml`) validates JSON files, lints for em/en dashes, checks shell syntax (`bash -n hooks/*.sh`), and smoke-tests the hooks by running them directly with `CLAUDE_PLUGIN_ROOT=.` set.

## Project memory (distilled)

<!-- Curated snapshot of prior agent session knowledge (2026-07-17). Claude's private memory remains canonical; update via Working notes. -->

- Repo moved to `~/Git/fable-baton` from `~/Downloads` on 2026-07-10; GitHub remote is realgarit/fable-baton, made public 2026-07-13.
- fable-baton is a Claude Code plugin making Fable 5 a token-frugal orchestrator with tiered agents (scout=Haiku, executor=Sonnet, architect=Opus, verifier=Haiku), a SessionStart policy hook, and a baton-setup skill.
- Core product goal: stop the mid-session "switcheroo" where Fable's quota runs dry and Opus silently takes over. Inverted model: Fable spends tokens on judgment only; Opus/Sonnet/Haiku work below it as subagents; Fable keeps holding context. Tiering is meant to generalize to more models later.
- Repo rule: no em/en dashes anywhere (dash-lint enforced in CI), plain hyphens only. Also applies to any user-facing prose (posts, README, docs): no "not X, it's Y" constructions, no labeled sections in prose, no AI-marketing phrases (dive into, unleash, game-changing, leverage, optimize, unlock potential), short plain sentences, admit limitations plainly.
- No mention of the source notes the design came from, in any file.
- v1.1.0 added security-context routing: in security sessions, hands-on work is delegated from the first step so Fable only sees agent reports.
- v1.2.0 (2026-07-10) added a UserPromptSubmit per-prompt reminder hook, a 3-consecutive-inline-calls tripwire, and a "skills define what, not who" rule. Built after a real session showed SessionStart-only injection loses salience and invoked skills' imperative steps can override the policy.
- v1.3.0 (2026-07-10) added a PostToolUse inline-call counter hook (hooks/inline-counter.sh): counts consecutive Bash/Read/Grep/Glob/Edit/Write/NotebookEdit calls per session, resets on Agent/Task, injects a delegation notice at threshold (FABLE_BATON_TRIPWIRE, default 4, re-nudges every 6). Chose PostToolUse additionalContext over PreToolUse deny because hooks fire in subagents too and hard-blocking would break them. Known limitation: subagent calls may share the parent session's counter; the notice text tells subagents to ignore it in that case.
- Git flow rule: never commit to main directly. Always: feature branch, push, open PR with gh, watch CI on the PR, merge (squash, delete branch), then watch the post-merge main run until green. CI (.github/workflows/ci.yml) validates JSON, dash-lint, and hook smoke tests.
- 2026-07-13 benchmark (Claude Code 2.1.197, plugin v1.3.0, off vs on, 12 headless runs): plugin does not reduce total API cost (roughly equal, slightly higher on small tasks), but Fable 5's own output tokens dropped 44% on a spec'd feature task and 38% on a code review task, with work shifting to Sonnet/Haiku/Opus. Honest framing: value is preserving Fable quota and avoiding the switcheroo, not total cost savings. Results are in the README Benchmark section (added via PR #12).
- Plugin was submitted to the official Claude plugin directory (platform.claude.com/plugins/submit) and to community awesome-lists; awaiting review as of 2026-07-10.

## Cross-agent conventions

- This file (`AGENTS.md`) is the single source of truth for agent instructions in this repo. `CLAUDE.md` and `.github/copilot-instructions.md` are pointers to it; never edit them, never duplicate content into them.
- Reusable skills live in `.claude/skills/` (one folder per skill with a `SKILL.md`). GitHub Copilot reads that directory natively; Codex sees it via the `.agents/skills` symlink. New skills always go in `.claude/skills/`.
- Claude-specific subagent definitions live in `.claude/agents/`. If you are not Claude Code, you may read them as role/process guidance.
- Session continuity across tools: before ending substantial work in ANY tool (Claude Code, Codex, Copilot), record durable context (decisions made, gotchas discovered, in-progress state worth resuming) in the "Working notes" section below, or fold it into the relevant section above. This is the shared memory between agents.

## Working notes

<!-- Any agent: append short dated notes here (YYYY-MM-DD, note). Prune notes when stale or once folded into the sections above. -->
