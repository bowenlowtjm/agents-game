# AGENT-BRIEF — point your agent here

> **You are an agent (or agent team) building a mobile game called Pully.**
> This folder is **read-only spec**. Do **NOT** build here. Each run happens in a **brand-new git repo** that you create. See [RUN-PROTOCOL](RUN-PROTOCOL.md).

Spec root (absolute): `/Users/bowenlow/Documents/Shared_Notes/Dev-Hermes-Pully/`

## Your job, in one paragraph
Create a new git repo for this run, scaffold a Unity project from `templates/`, and implement the game defined in `spec/GAME-SPEC.md` to the bar in `spec/ACCEPTANCE.md`. Track work in Linear (team SAA), communicate over Discord per your assigned autonomy rung, and record results in the new repo's `docs/run-log.md`. Build a working Android APK.

## Read these, in order
1. **[RUN-PROTOCOL.md](RUN-PROTOCOL.md)** — how a run works: repo naming, scaffold steps, the run-parameter block, comms, where results go. **Start here.**
2. **[spec/GAME-SPEC.md](spec/GAME-SPEC.md)** — the authoritative game definition (what to build).
3. **[spec/RULESET.md](spec/RULESET.md)** — the exact target→gesture→score data.
4. **[spec/ACCEPTANCE.md](spec/ACCEPTANCE.md)** — definition of done + code & gameplay quality bars.
5. **[roles/](roles/)** — install `game-pm.SKILL.md` and `game-art.SKILL.md` as skills (if running the team config).

## Scaffold payload (copy into the new repo)
Everything under **[templates/](templates/)** is copied verbatim into the new repo and then filled in:
`AGENTS.md`, `DESIGN.md`, `Editor/Builder.cs`, `Assets/_Game/Scripts/RulesetDefinition.cs`, `docs/*`, `.gitignore`.

## Hard rules
- **New repo per run.** Never commit game code into this spec folder.
- **Verify, don't claim.** "Done" needs an artifact: clean Unity console, passing test, or APK path. No silent stubs.
- **Respect your autonomy rung** (L1 / L3 / L4) — it controls who decides open questions and how you use Discord. Defined in [RUN-PROTOCOL](RUN-PROTOCOL.md) and [../05-Autonomy-Ladder](05-Autonomy-Ladder.md).
- **One ruleset, data-driven.** Gesture mapping lives in the ScriptableObject, never hardcoded.

## Context (optional, for the human — the "why")
The numbered docs `01`–`09` in this folder are the *experiment design* behind this kit. You don't need them to build; read them only if you want the rationale. The files above are all you need to execute a run.
