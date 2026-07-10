# fable-baton 🪄

**Fable 5 holds the baton. The orchestra plays.**

A Claude Code plugin that turns Fable 5 into a token-frugal orchestrator: Fable keeps the judgment - intent, architecture, decomposition, tradeoffs, final review - while tiered subagents (Opus / Sonnet / Haiku) do the labor. Install once, and every new session in every repo starts orchestrated.

## Why

Fable 5 is the strongest model available on a Claude subscription - and the most expensive one to burn on grep runs and boilerplate. fable-baton routes every piece of work to the **cheapest tier that can do it well**, so you can drive Fable 5 as your daily model without fearing token cost.

## How it works

Three pieces, all shipped by the plugin:

1. **Four tiered agents**, each pinned to a model:

   | Agent | Model | Owns |
   |---|---|---|
   | `scout` | Haiku | Discovery, reading files/logs, summaries, simple checks |
   | `executor` | Sonnet | Scoped implementation, tests, routine edits, local refactors |
   | `architect` | Opus | Complex implementation, deep debugging, high-risk work, reviewing cheaper agents |
   | `verifier` | Haiku | Evidence checks: tests green, diff matches plan, no regressions |

2. **An orchestration policy**, injected into every new session by a SessionStart hook. It tells Fable what to keep (judgment) and what to route down (labor), with anti-waste rules: no pointless fan-out, focused context per agent, and no delegation at all when doing it directly is cheaper.

3. **A setup skill** (`baton-setup`) that configures your default model to `best` (Fable 5, with Opus fallback) - the one thing a plugin can't set by itself.

High-risk areas (auth, billing, migrations, concurrency, public APIs, …) get special handling: Fable decides, `architect` executes or reviews, `verifier` confirms with evidence.

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

Nothing. That's the point - every new chat, in any repo, starts with the policy loaded and the agents available. Fable delegates on its own. If you want to check it's active, ask: *"which subagent types are available?"* - you should see scout, executor, architect, and verifier.

To skip orchestration for a session, just say so ("don't delegate in this session") - the policy defers to your instructions.

## Uninstall

```
/plugin uninstall fable-baton
```

Then, if you want your old default model back, restore `model` in `~/.claude/settings.json` from the `settings.json.baton-backup-*` file that baton-setup created.

## License

MIT
