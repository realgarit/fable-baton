# fable-baton 🪄

[![CI](https://github.com/realgarit/fable-baton/actions/workflows/ci.yml/badge.svg)](https://github.com/realgarit/fable-baton/actions/workflows/ci.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

![fable-baton: Fable conducts, tiered agents play](assets/hero.gif)

**Fable 5 holds the baton. The orchestra plays.**

A Claude Code plugin that makes Fable 5 the orchestrator. Fable keeps the judgment, tiered subagents on Opus, Sonnet and Haiku do the labor. Install once and every new session in every repo starts this way.

**[Why](#why) · [How it works](#how-it-works) · [What you'll see](#what-youll-see) · [Install](#install) · [Day-to-day](#day-to-day) · [Alternatives](#alternatives)**

## Why

- **Fable time is precious.** It is the strongest model on a Claude subscription and the most expensive one to burn on grep runs and boilerplate. fable-baton routes each piece of work to the cheapest tier that can do it well, so you can keep Fable 5 as your daily model.
- **No more switcheroo.** When Fable time runs dry, Opus quietly takes over your session. With fable-baton, Fable spends its tokens on judgment only, Opus does the heavy work below it as a subagent, and Fable stays the one holding the context.

The tiers are Opus, Sonnet and Haiku today. Later this should open up to other models and structures.

## How it works

### Four tiered agents

   | Agent | Model | Owns |
   |---|---|---|
   | `scout` | Haiku | Discovery, reading files/logs, summaries, simple checks |
   | `executor` | Sonnet | Scoped implementation, tests, routine edits, local refactors |
   | `architect` | Opus | Complex implementation, deep debugging, high-risk work, reviewing cheaper agents |
   | `verifier` | Haiku | Evidence checks: tests green, diff matches plan, no regressions |

### One policy

A SessionStart hook injects the orchestration policy into every new session. It tells Fable what to keep (intent, architecture, tradeoffs, review) and what to route down (labor), with anti-waste rules: no pointless fan-out, focused context per agent, no delegation for genuinely trivial single steps.

### Three layers of enforcement

A one-time policy is not enough. Models drift back to doing everything inline as a session goes on. We watched it happen in real sessions.

| Layer | Hook | What it does |
|---|---|---|
| Policy | SessionStart | Loads the full orchestration policy when the session starts |
| Reminder | UserPromptSubmit | Re-asserts the delegation rules on every prompt |
| Counter | PostToolUse | Counts consecutive inline tool calls and injects a delegation notice once a streak crosses the threshold (default 4, set with `FABLE_BATON_TRIPWIRE`, resets whenever an agent is used) |

The model can still ignore a notice. But ignoring a fresh instruction mid-streak is much harder than forgetting something from page one.

### Special handling

- **High-risk areas** (auth, billing, migrations, concurrency, public APIs): Fable decides, `architect` executes or reviews, `verifier` confirms with evidence.
- **Security sessions** (scans, audits, vulnerability triage): even the cheap hands-on steps go to the agents from the start. Fable stays at planning and synthesis. That is the right split anyway, and it avoids interruptions from the top model's intentionally broad safeguards on routine security output.
- **Setup skill**: `baton-setup` sets your default model to `best` (Fable 5, with Opus fallback) - the one thing a plugin can't set by itself.

## What you'll see

Every prompt gets a short delegation reminder, and when the model does too much inline work in a row, the counter steps in:

![A session where the counter fires and the model delegates](assets/fable-baton-demo.gif)

*Recreated replay. The hook text shown is the exact output from a real session.*

```
[fable-baton] 4 consecutive inline tool calls without delegating. Main session: this block
belongs to an agent (scout for discovery, executor for edits) - delegate the remainder now.
```

That notice comes from a deterministic PostToolUse hook, and the CI suite proves it fires at exactly the threshold.

## Install

In any Claude Code session:

```
/plugin marketplace add realgarit/fable-baton
/plugin install fable-baton@fable-baton
```

Then ask Claude to **"run baton-setup"** - it sets `model: "best"` in your `~/.claude/settings.json` (with your approval and a backup) and verifies the install. Restart your session and you're done.

**Requirements**

- Claude Code with plugin support
- A subscription or API access that includes Fable 5 (the `best` model alias falls back to the latest Opus otherwise - the orchestration still works, just with Opus conducting)

## Day-to-day

- Nothing to do. Every new chat, in any repo, starts with the policy loaded and the agents available. Fable delegates on its own.
- Check it is active: ask *"which subagent types are available?"* - you should see scout, executor, architect and verifier.
- Watch it work: after a few inline tool calls in a row you will see a `[fable-baton]` notice in the session telling the model to delegate.
- Skip it for a session: just say so ("don't delegate in this session") - your instructions win over the policy.

## Alternatives

Worth knowing before you pick this:

- [fable-advisor](https://github.com/DannyMac180/fable-advisor) keeps day-to-day work on other vendors' models and calls Fable at decision points. Choose it for multi-vendor routing. fable-baton keeps Fable conducting the whole session, so your context never leaves it.
- [claude-code-workflow-orchestration](https://github.com/barkain/claude-code-workflow-orchestration) ships eight agents and adaptive nudges. Choose it for complex workflow graphs.
- [fable5-orchestrator](https://github.com/Rylaa/fable5-orchestrator) is close in spirit, with a requirements ledger and per-workflow verification. fable-baton stays smaller on purpose: four agents, one policy, three enforcement layers, zero config.

Pick fable-baton when you want install-and-go and Fable staying in charge.

## Uninstall

```
/plugin uninstall fable-baton
```

To restore your old default model, restore `model` in `~/.claude/settings.json` from the `settings.json.baton-backup-*` file that baton-setup created.

## License

MIT
