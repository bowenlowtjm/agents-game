# Agent Team Architecture

Roles are **native Hermes agents** — each a system prompt + tool set defined in the harness (no Claude Code / gstack). An **orchestrator** agent drives a Think→Plan→Build→Review→Test→Ship→Reflect loop; **parallelism is native `git worktree`** (one worktree per parallel role/run). Coordinated through a **local `tasks/` board** (markdown, one file per task — no external tracker). Two configs are tested head-to-head: **Solo agent** vs **Hermes role-team**, at equal token budget.

## Config A — Solo agent (control)
One capable agent, full toolset (Unity MCP + build + git + `tasks/` board + Discord + flat-docs memory). Simplest, no handoff failures, no parallelism. Every fancier setup must beat this.

## Config B — Hermes role-team (orchestrator + roles)
```
                         ┌──────────────────────────┐
       tasks/ board ◄──►│   Game PM  (role agent)   │  owns brief→backlog,
                         │                            │  priorities, "is it fun?"
                         └─────────────┬─────────────┘
                                       ▼
                         ┌──────────────────────────┐
                         │   Orchestrator (Hermes)   │  sprint loop, gates merges,
                         │   Codex or Kimi K2.5       │  owns decisions + run-log
                         └─────┬───────┬───────┬─────┘
        ┌──────────────┬───────┘       │       └────────┬───────────────┐
        ▼              ▼               ▼                ▼               ▼
   Game-Logic     Unity-Scene      Game Art         Build/CI        Test author
   (C# systems)   (scenes,prefabs  (sprites +       (batchmode APK, (writes Edit/
                   via Unity MCP)   atlas import)    install)        PlayMode tests)
        └──────────────┴───────────────┴────────────────┴───────┬───────┘
                                                                 ▼
                                          ┌──────────────────────────────────┐
                                          │  QA — independent gate            │  every major
                                          │  errors (compile/CI/console) +    │  push: sign
                                          │  playability (bot/smoke/feel)     │  off or block
                                          └──────────────────────────────────┘
```
Each box is a Hermes agent (prompt + tools). Workers run in parallel git worktrees. **Two gates, different lenses:** the **Staff Engineer** reviews+fixes the diff *before every major commit* (white-box code quality/correctness), then the **QA gate** verifies *every major push* (black-box playability/errors). Sequence: `worker → staff-engineer (pre-commit) → commit/push → QA (pre-merge) → merge`. The orchestrator merges only on QA **PASS** + green CI.

### Roles (Hermes agents)
| Role                                       | Defined in                | Owns                                                                                                                                 |
| ------------------------------------------ | ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| **Senior Game Product Manager** *(custom)* | `roles/game-pm.SKILL.md`  | Brief→`tasks/` board, prioritization, the *fun/10-star* product calls, accept/reject features, **gameplay-quality bar**              |
| **Orchestrator**                           | harness config            | decompose, sequence, gate merges, maintain memory                                                                                    |
| **Game-Logic worker**                      | role prompt               | scoring, combo, ruleset SO, input→gesture recognition                                                                                |
| **Unity-Scene worker**                     | role prompt (Unity MCP)   | scenes, prefabs, HUD wiring, references                                                                                              |
| **Game Art** *(custom)*                    | `roles/game-art.SKILL.md` | 2D sprite generation, palette/style (`DESIGN.md`), atlas packing, Unity import                                                       |
| **Build/CI worker**                        | role prompt               | `Builder.cs`, batchmode/GameCI APK, install                                                                                          |
| **Test author**                            | role prompt               | writes EditMode+PlayMode tests alongside features; gesture sim; **gameplay-quality harness** (bot player, recorder, judge)           |
| **Staff Engineer — tech lead** *(custom)*  | `roles/staff-engineer.SKILL.md` | **pre-commit, white-box gate**: before every major commit, reviews AND **fixes** the diff for correctness/clean-code, enforces [`code-conventions`](roles/code-conventions.SKILL.md), leaves it compiling + green |
| **QA — independent gate** *(verifier)*     | `roles/qa.SKILL.md`       | **pre-merge, black-box gate**: on every major push, errors (compile/CI/console) + playability (bot, smoke playthrough, feel); **signs off or blocks** the merge |

### The two custom agents (the new asks)
- **Game PM** — the product brain. Reads [Game Brief](02-Game-Design-Brief.md), writes the backlog as `tasks/T###-*.md` files (+ keeps `tasks/BOARD.md` in sync), sequences milestones, and is the *only* role allowed to declare a feature "fun enough." At L1 it proposes and a human ratifies; at L3/L4 it decides alone and logs rationale. Frames the work as "find the 10-star product hiding in the request."
- **Game Art** — the sprite pipeline. Generates 2D sprites (shapes, targets, FX, UI) via the chosen art stack (see [Tool-Stack Options](09-Tool-Stack-Options.md)), enforces a palette/style captured in `DESIGN.md`, packs an atlas, imports into `Assets/_Game/Sprites`, and hands the Scene worker ready prefab-able sprites. Replaces the v1 procedural placeholders.

## Memory
Backend is **paired to the config** (decided):

| Config | Project-memory backend | Why |
|--------|------------------------|-----|
| **A — Solo agent** | **flat `docs/`** (`decisions`, `CONVENTIONS`, `GOTCHAS`, `run-log`) | simple, transparent, no infra; matches a single agent's needs |
| **B — Hermes role-team** | **OpenViking** (filesystem context DB, `viking://`) | hierarchical, self-evolving memory shared across parallel role worktrees |

**OpenViking** (ByteDance/Volcano Engine, open-source) organizes memory/resources/skills as a `viking://` filesystem with tiered L0/L1/L2 on-demand loading and self-compressing long-term memory — a natural fit for a multi-role team and for the flat-docs philosophy, but queryable and shared. Self-hosted; model-agnostic, so it sits behind Hermes regardless of model.

> Caveat: pairing memory to config means the A-vs-B comparison also varies the memory backend — a difference can't be cleanly attributed to *orchestration alone*. Accepted trade for simplicity; to isolate, run one B pass on flat docs. Other backends in [Tool-Stack Options › Memory](09-Tool-Stack-Options.md#8-agent-memory-backends).

Tiers (independent of backend):

| Tier | Lives in | Lifetime | Holds |
|------|----------|----------|-------|
| **Working** | agent context | one task | current task + recent tool output |
| **Project** | flat `docs/` (A) **/** OpenViking (B) | the experiment | decisions, conventions, traps, per-run summaries |
| **Taste/art** | `DESIGN.md` | the experiment | palette, sprite style, "what looks right" |
| **Episodic** | `docs/notes/*` (A) **/** OpenViking self-evolving memory (B) | across runs | "last time APK signing failed, fix was X" |

**Memory discipline:** every run appends to `run-log.md`; orchestrator reads `GOTCHAS.md` before each phase; Game Art reads `DESIGN.md` before generating.

## Handoff protocol
- Each role returns a structured result: `{ task_id, changed_files, tests_run, pass/fail, stubs, next_blockers }`.
- Orchestrator never trusts "done" without an artifact (clean console, passing test, APK path, atlas file).
- All work on branches in **git worktrees**; on a major push the **QA gate** runs (errors + playability); orchestrator merges only on QA **PASS** + green CI; PR + branch link back to `T###`.
- **Separation of duties:** the QA agent is *not* the agent that wrote the code (nor the Test author). Independent verification is the point — it's the main defense against "marks its own work done." In **solo config (A)** there's no second agent, so the lone agent runs the QA checklist itself before declaring done (weaker, by design — part of what A-vs-B measures).

## Task flow (local `tasks/` board)
`Game PM creates tasks/T### (todo) → orchestrator pulls → worker sets in-progress → **QA gate** (in-review) → Build/CI ships → done`. **Who may set `status: done` is the autonomy knob** (see [Autonomy Ladder](05-Autonomy-Ladder.md)); QA PASS is the precondition. Task files are committed with the work, so the board state is versioned alongside the code.

## Model placement to test (phased)
**Start Kimi-only; swap in Codex later.** Phase 1 establishes a clean baseline on a single model before adding the model variable.

| Phase | Run | Orchestrator | Workers | Purpose |
|-------|-----|-------------|---------|---------|
| **1 (now)** | K0 | Kimi K2.5 | Kimi K2.5 | baseline — all-Kimi, both configs (A & B), across L1/L3/L4 |
| **2 (later)** | C1 | Codex | Kimi K2.5 | does Codex orchestration beat all-Kimi? |
| **2 (later)** | C2 | Kimi K2.5 | Codex | does Codex as surgical-C# worker help? |
| **2 (later)** | C3 | best-of-above | mixed per-role | role-optimal assignment |

Phase 1 needs only `MOONSHOT_API_KEY`. Phase 2 adds the Codex key (see [SETUP-CREDENTIALS](SETUP-CREDENTIALS.md)).
