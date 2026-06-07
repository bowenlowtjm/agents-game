# Roadmap

Milestones double as the **checkpoint boundaries** for [Autonomy Ladder](05-Autonomy-Ladder.md) L2 runs.

## M0 — Harness & bridge proof (human-led)
Goal: prove the plumbing before testing autonomy.
- Unity 6 LTS + Android module; empty **3D** project committed.
- Hermes role-agents defined in `roles/`; `AGENTS.md` manifest; **Game PM** + **Game Art** wired; `git worktree` parallelism ready.
- Unity MCP + **Linear MCP** connected to Hermes; smoke-test scene create + console read + create an `SAA-###` issue.
- **Discord** wired: webhook (post-only feed for L3/L4) + bot/MCP (two-way channel for L1); agent posts a test significant-change.
- `Builder.cs` batchmode → debug APK *by hand* once (baseline path exists).
- **CI live:** push scaffold to GitHub, add `UNITY_*` secrets, confirm `ci.yml` green on the sample tests and `build.yml` produces an APK artifact ([Testing & CI/CD](10-Testing-and-CICD.md)).
- Memory ready: flat `docs/` (solo) or OpenViking server (team), seeded; `DESIGN.md` started.
- **Exit:** an agent reads the Unity console, creates a scene, files a Linear issue, and **opens a green PR through CI**.

## M1 — Core loop, agent-built (first ladder run)
- **Game PM** breaks the brief into the `SAA` backlog in Linear.
- Input System wired; gesture recognizer (single/double/long/swipe/two-finger).
- Ruleset ScriptableObject + scoring + combo.
- One game scene, targets spawn (procedural shapes/colors placeholders), seeded RNG.
- EditMode unit tests (scoring/combo, gesture classification, ruleset, determinism); PlayMode integration test (input→score).
- **Exit:** core loop playable in Editor; `ci.yml` green on the PR; issues moved through `SAA` board; **ADR pass** in `adr/` for the core-loop architecture (ruleset data model, gesture recognition, seeded spawn) — see [ADR Process](12-ADR-Process.md).

## M2 — Playable build + art pass
- Main menu + game-over screens; HUD (score/combo/timer).
- **Game Art** replaces placeholders with generated 2D sprites + packed atlas; palette in `DESIGN.md`.
- Local high score persistence.
- Minimal juice (hit pop, miss flash, score tween).
- Android debug APK installs + launches on device/emulator.
- **Exit:** [Charter DoD](01-Experiment-Charter.md#definition-of-done-per-run) met; **ADR pass** for scene/prefab structure, art/atlas pipeline, and persistence.

## M3 — Balance, robustness & gameplay-quality harness
- Tune ruleset (reward/penalty), edge-input handling, no softlocks.
- Stand up the **bot player + Unity Recorder + LLM judge** (see [Metrics §C](07-Metrics-and-Evaluation.md#c-gameplay-quality-the-new-headline-metric)).
- Full test pass; deterministic replay of a seeded session.
- **Exit:** Code-quality B ≥ 11/15 **and** Gameplay-quality ≥ 6/10 (PM bar); **ADR pass** for determinism/replay + balance config; `adr/` set is complete and ordered by blast radius.

## M4 — Autonomy stress tests
Run the [Autonomy Ladder](05-Autonomy-Ladder.md) **3×2 grid** (Config A solo vs B Hermes role-team × **L1 / L3 / L4**, memory on/off optional). Then optional stretch:
- **"True-3D-ify" run** — give targets depth/meshes + perspective camera as a *cold-start autonomy test* on the existing codebase.
- **New-mechanic run** — hand the team a one-line feature ("add a power-up") at L3 and measure.
- **Exit:** results table + writeup (see [Metrics › Output](07-Metrics-and-Evaluation.md#output)).

## Sequencing note
Do **M0–M2 once at L0/L1** to establish a working reference build and seed memory. *Then* reset and run the autonomy grid — so lower rungs aren't unfairly starting from zero with no `GOTCHAS.md`. Decide explicitly whether each grid run starts from empty repo or from the M0 scaffold; keep it constant within a comparison.
