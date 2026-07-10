# fable-baton 🪄

**Fable 5 holds the baton. The orchestra plays.**

A Claude Code plugin that makes Fable 5 the orchestrator. Fable keeps the judgment: intent, architecture, decomposition, tradeoffs, final review. Tiered subagents on Opus, Sonnet and Haiku do the labor. Install once and every new session in every repo starts this way.

## Why

Fable 5 is the strongest model you can get on a Claude subscription. It is also the most expensive one to burn on grep runs and boilerplate. fable-baton routes each piece of work to the **cheapest tier that can do it well**, so you can keep Fable 5 as your daily model.

There is a second goal: stopping the mid-session switcheroo. When Fable time runs dry, Opus quietly takes over your session. With fable-baton, Fable spends its tokens on judgment only, Opus does the heavy work below it as a subagent, and Fable stays the one holding the context. The tiers are Opus, Sonnet and Haiku today. Later this should open up to other models and structures.

## How it works

Four pieces, all shipped by the plugin:

1. **Four tiered agents**, each pinned to a model:

   | Agent | Model | Owns |
   |---|---|---|
   | `scout` | Haiku | Discovery, reading files/logs, summaries, simple checks |
   | `executor` | Sonnet | Scoped implementation, tests, routine edits, local refactors |
   | `architect` | Opus | Complex implementation, deep debugging, high-risk work, reviewing cheaper agents |
   | `verifier` | Haiku | Evidence checks: tests green, diff matches plan, no regressions |

2. **An orchestration policy**, injected into every new session by a SessionStart hook. The policy tells Fable what to keep (judgment) and what to route down (labor), with anti-waste rules: no pointless fan-out, focused context per agent, and no delegation for genuinely trivial single steps.

3. **Enforcement.** A one-time policy is not enough. Models drift back to doing everything inline as a session goes on. We watched it happen in real sessions. So the plugin works in three layers: the policy at session start, a short reminder on every prompt (UserPromptSubmit hook), and a PostToolUse hook that counts consecutive inline tool calls and injects a delegation notice once a streak crosses the threshold (default 4, set with `FABLE_BATON_TRIPWIRE`, resets whenever an agent is used). The model can still ignore a notice. But ignoring a fresh instruction mid-streak is much harder than forgetting something from page one.

4. **A setup skill** (`baton-setup`) that configures your default model to `best` (Fable 5, with Opus fallback) - the one thing a plugin can't set by itself.

High-risk areas (auth, billing, migrations, concurrency, public APIs, …) get special handling: Fable decides, `architect` executes or reviews, `verifier` confirms with evidence.

Security-focused sessions (scans, audits, vulnerability triage) send even the cheap hands-on steps to the agents from the start. Fable stays at planning and synthesis. That is the right split anyway, and it avoids interruptions from the top model's intentionally broad safeguards on routine security output.

## Install

In any Claude Code session:

```
/plugin marketplace add realgarit/fable-baton
/plugin install fable-baton@fable-baton
```

Then ask Claude to **"run baton-setup"** - it sets `model: "best"` in your `~/.claude/settings.json` (with your approval and a backup) and verifies the install. Restart your session and you're done.

### Requirements

- Claude Code with plugin support
- A subscription or API access that includes Fable 5 (the `best` model alias falls back to the latest Opus otherwise - the orchestration still works, just with Opus conducting)

## Day-to-day

Nothing. That's the point - every new chat, in any repo, starts with the policy loaded and the agents available. Fable delegates on its own. If you want to check it's active, ask: *"which subagent types are available?"* - you should see scout, executor, architect, and verifier. You can also watch the plugin work: after a few inline tool calls in a row you will see a `[fable-baton]` notice in the session telling the model to delegate.

To skip orchestration for a session, just say so ("don't delegate in this session") - the policy defers to your instructions.

## Uninstall

```
/plugin uninstall fable-baton
```

Then, if you want your old default model back, restore `model` in `~/.claude/settings.json` from the `settings.json.baton-backup-*` file that baton-setup created.

## License

MIT
