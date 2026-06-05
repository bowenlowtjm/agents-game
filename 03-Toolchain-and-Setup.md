# Toolchain & Setup

The stack splits into five layers. The interesting experimental surface is layers 2–5.

## Layer 1 — Engine & project
- **Unity 6 LTS**. **3D project**, 2D-sprite gameplay (see [Game Design Brief](02-Game-Design-Brief.md)).
- **Android Build Support** module (SDK/NDK/JDK) — APK output.
- **Input System** package (touch + pointer); **2D Sprite** + **2D Atlas** packages for the sprite pipeline.
- Project in a **git repo** from commit 0 — agents work on branches/worktrees; every run is an auditable diff.

## Layer 2 — Agent↔Unity bridge (the crux)
Agents can't click the Editor; they need a tool bridge.

| Bridge | Gives agents | Notes |
|--------|--------------|-------|
| **Unity official MCP** (`com.unity.ai.assistant`) | scene mgmt, asset ops, script editing, console read | first-party, actively shipping — default |
| **CoplayDev/unity-mcp** | assets, scenes, scripts, automation | mature community server |
| **IvanMurzak/Unity-MCP** | full develop+test loop, custom C#→tool, CLI | keep for the **automated test loop** + custom verify tools |

**Decision:** official Unity MCP for stability; IvanMurzak in reserve for the in-Editor test loop. The agent's ability to *verify its own work in-Editor* is the single biggest lever.

## Layer 3 — Harness, roles & models (no Claude Code)
- **Hermes** — orchestration runtime (spawns agents, routes tools, run lifecycle).
- **Native Hermes role-agents** — the **role layer**: orchestrator + custom **Game PM** + **Game Art** + Game-Logic/Scene/Build/QA, each a system prompt + tool set defined in the harness, driving a Think→Plan→Build→Review→Test→Ship→Reflect loop. Role definitions live in `roles/`. See [Architecture](04-Agent-Team-Architecture.md).
  - **Parallelism** — native **`git worktree`** (one worktree per parallel role/run); no Conductor.
- **Models under test:** **Kimi K2.5** and **Codex**, A/B'd across orchestrator vs worker roles (see [Architecture](04-Agent-Team-Architecture.md#model-placement-to-test)). *No Anthropic/Claude required* — it's only an optional extra model.
- **CLI build path:** Unity batchmode (`-batchmode -executeMethod Builder.BuildAndroid`) so the build is an agent-callable tool, not a human click. Cloud option: **GameCI** GitHub Action (see [Tool-Stack Options](09-Tool-Stack-Options.md)).

## Layer 4 — Work organization & comms (Linear + Discord)
**Linear (backlog/state):**
- **[Linear — team SAA](https://linear.app/saaavvvy-dev-space/team/SAA/active)** is the backlog + state machine.
- The **Game PM agent** authors epics/issues from the [Game Brief](02-Game-Design-Brief.md); the orchestrator pulls issues; workers move them `Todo → In Progress → In Review → Done`; Release closes them on merge.
- **Issue-state transitions encode the autonomy level** (see [Autonomy Ladder](05-Autonomy-Ladder.md)): who is allowed to move an issue to Done — a human (L1) or the team itself (L3/L4).
- Integration: **Linear MCP** so agents create/update/transition issues directly; link each branch/PR to its `SAA-###` issue.

**Discord (human↔agent comms):** two mechanisms, chosen by autonomy rung (see [Autonomy Ladder › Communication](05-Autonomy-Ladder.md#communication-per-rung)):
- **Post-only (L3/L4)** — a **Discord webhook**. The agent broadcasts *significant changes* to a feed channel; no read-back. Zero-infra, fire-and-forget.
- **Two-way channel (L1)** — a **Discord bot / Discord MCP** the agent can both post to *and read replies from* — questions, approvals, design answers flow back in-channel.
- **"Significant change"** = milestone reached, issue→Done, build produced (APK path), a logged decision, or a blocker/escalation. Each post links the `SAA-###` issue + commit.

## Layer 5 — Memory & knowledge
Backend is **paired to the config** (decided — see [Architecture › Memory](04-Agent-Team-Architecture.md#memory)):
- **Config A (solo)** → flat versioned docs: `docs/decisions.md` (ADR-lite), `CONVENTIONS.md`, `GOTCHAS.md`, `run-log.md`.
- **Config B (Hermes role-team)** → **OpenViking** (`viking://` filesystem context DB, tiered L0/L1/L2, self-evolving; self-hosted, model-agnostic).
- Either way, `DESIGN.md` holds the **art style** so the Game Art agent stays consistent across runs.
- Other backends worth a look (Mem0 / Zep / Letta / Cognee / MCP memory server) — see [Tool-Stack Options › Memory](09-Tool-Stack-Options.md#8-agent-memory-backends).

## Repo layout (target)
```
pully/
  Assets/
    _Game/
      Scripts/        # one asmdef: Pully.Game
      Scenes/
      Sprites/        # generated 2D sprites + atlas
      Data/           # ScriptableObject rulesets
    Tests/            # EditMode + PlayMode
  Editor/Builder.cs   # batchmode build (agent-callable)
  docs/               # decisions / CONVENTIONS / GOTCHAS / run-log
  DESIGN.md           # art style + taste memory
  AGENTS.md           # harness role manifest + routing
  ProjectSettings/  Packages/
```

## Setup checklist (M0)
- [ ] Unity Hub + 6 LTS + Android module; empty 3D project committed
- [ ] Hermes role-agents defined (`roles/`); `AGENTS.md` manifest in repo; **Game PM** + **Game Art** wired
- [ ] Unity MCP connected to Hermes; smoke-test "read console" + "create scene"
- [ ] Linear MCP connected; PM agent can create/transition an `SAA-###` issue
- [ ] Discord set up: **webhook** (post-only feed, L3/L4) + **bot/MCP** (two-way, L1); agent posts a test "significant change"
- [ ] `Builder.cs` batchmode → debug APK *by hand* once (baseline path)
- [ ] GitHub repo + `UNITY_*` secrets; `ci.yml` green on sample tests; `build.yml` yields an APK artifact (see [Testing & CI/CD](10-Testing-and-CICD.md))
- [ ] Memory ready: flat `docs/` (solo) **/** OpenViking server up + seeded (team)
- [ ] Hermes launches one worker that calls one Unity MCP tool end-to-end
