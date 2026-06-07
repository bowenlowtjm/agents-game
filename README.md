# Dev-Hermes-Pully

An experiment: **how much of a shippable mobile game can an agent team produce, at varying levels of human involvement?**

"Pully" is the game codename — a fast finger-tap arcade game (tap variations on colored/shaped targets for points). The game is the *payload*; the real subject under test is the **agent harness + orchestration + roles + memory stack**.

## The stack (decided)
- **Engine:** 3D engine (Unity), **2D-sprite gameplay** (sprites/quads in a 3D scene). See [Game Design Brief](02-Game-Design-Brief.md).
- **Harness:** Hermes. **Phase 1 = Kimi K2.5 only**; swap in Codex (A/B) in Phase 2.
- **Roles:** native Hermes role-agents (no Claude Code) + two custom agents — **Game Product Manager** and **Game Art**. Parallelism via `git worktree`.
- **Work org:** [Linear — team SAA](https://linear.app/saaavvvy-dev-space/team/SAA/active) (backlog, issue states gate autonomy).
- **Comms:** Discord — two-way bot/MCP at L1, post-only webhook feed of significant changes at L3/L4.
- **Editor bridge:** Unity MCP (agents drive the Editor). See [Toolchain & Setup](03-Toolchain-and-Setup.md).

## The two questions this repo answers
1. **Capability** — what can the agent team build end-to-end (game + sprites + build + tests)?
2. **Leverage** — how does output quality/speed change as the human dials involvement from **reviewer** → **spec-only** → **absent**?

## Two layers in this folder
1. **Spec kit (point your agent here to run)** — operational, agent-consumable. Each run scaffolds a **new repo** from it.
2. **Experiment design (`01`–`09`)** — the *why* behind the kit, for the human.

### Spec kit — start an agent here
| File | Purpose |
|------|---------|
| **[AGENT-BRIEF.md](AGENT-BRIEF.md)** | **The entry point — point the agent at this.** |
| [RUN-PROTOCOL.md](RUN-PROTOCOL.md) | Run parameters, new-repo scaffold steps, per-rung behavior |
| [spec/GAME-SPEC.md](spec/GAME-SPEC.md) | Authoritative game definition |
| [spec/RULESET.md](spec/RULESET.md) | Target→gesture→score data |
| [spec/ACCEPTANCE.md](spec/ACCEPTANCE.md) | Definition of done + quality bars |
| [roles/game-pm.SKILL.md](roles/game-pm.SKILL.md) · [roles/game-art.SKILL.md](roles/game-art.SKILL.md) | Custom agent skills |
| [templates/](templates/README.md) | Scaffold payload copied into each new run repo |

## Experiment design

| Doc | Purpose |
|-----|---------|
| [Experiment Charter](01-Experiment-Charter.md) | Goal, hypotheses, what "done" means |
| [Game Design Brief — Pully](02-Game-Design-Brief.md) | The game spec the agents build against |
| [Toolchain & Setup](03-Toolchain-and-Setup.md) | Unity, MCP, Hermes roles, Linear, repo layout |
| [Agent Team Architecture](04-Agent-Team-Architecture.md) | Hermes role-agents + Game PM + Game Art, memory, Linear flow |
| [Autonomy Ladder](05-Autonomy-Ladder.md) | The 3 human-involvement levels tested: **L1 / L3 / L4** |
| [Workflow & Guardrails](06-Workflow-and-Guardrails.md) | Run loop, commit discipline, what stops a run |
| [Metrics & Evaluation](07-Metrics-and-Evaluation.md) | Shipped / code-quality / **gameplay-quality** / cost |
| [Roadmap](08-Roadmap.md) | Milestones M0–M4 |
| [Tool-Stack Options](09-Tool-Stack-Options.md) | Art gen, audio, build CI, device test, judge tooling |
| [Testing & CI/CD](10-Testing-and-CICD.md) | Test pyramid + GitHub Actions (GameCI) pipeline |
| [Parallel Runs](11-Parallel-Runs.md) | Running many runs at once + Discord channel routing |
| [ADR Process](12-ADR-Process.md) | Writing architecture decision records at checkpoints |

## Start here
[Charter](01-Experiment-Charter.md) → [Game Brief](02-Game-Design-Brief.md) → set up per [Toolchain](03-Toolchain-and-Setup.md) → run [Autonomy Ladder](05-Autonomy-Ladder.md) (L1 → L3 → L4).
