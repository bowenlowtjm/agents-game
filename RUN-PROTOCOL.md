# RUN-PROTOCOL — how one run executes

A "run" = one attempt to build Pully, in its own fresh repo, at a stated autonomy rung and config. The human fills the **Run Parameters** block, then launches the agent pointed at [AGENT-BRIEF](AGENT-BRIEF.md).

## Run Parameters (human fills before launch)
```
SPEC_REPO:     <local path to a clone of github.com/bowenlowtjm/agents-game>   # the spec kit
RUN_ID:        pully-<config>-<rung>-<YYYYMMDD>      # e.g. pully-B-L3-20260604
CONFIG:        A (solo)  |  B (Hermes role-team)
RUNG:          L1 (reviewer) | L3 (spec-only) | L4 (autonomous)
MODELS:        orchestrator=KimiK2.5  workers=KimiK2.5     # Phase 1 = Kimi-only; swap Codex in Phase 2
MEMORY:        flat-docs (default for A)  |  OpenViking (default for B)
LINEAR_TEAM:   SAA
LINEAR_LABEL:  run:<RUN_ID>                            # so parallel runs don't blur the board
DISCORD_TARGET: <webhook-url (L3/L4) | channel-id for the bot (L1)>   # per run — see Parallel Runs
ART_STYLE:     <flat-vector | pixel | …>   # L1/L3: human sets here. L4: leave "AGENT-DECIDES"
REPO_LOCATION: <path or git remote for the NEW repo>
UNITY_MCP_PORT: <unique per concurrent run>           # e.g. 6401, 6402 — only matters when running in parallel
PULLY_REFRESH_PORT: <unique per concurrent run>       # e.g. 8090, 8091 — headless compile-check server port
VIKING_NAMESPACE: viking://runs/<RUN_ID>/             # Config B team memory; omit for solo/flat-docs
```
> Running several at once? See [Parallel Runs & Discord Routing](11-Parallel-Runs.md) — every shared resource (Editor port, memory namespace, Linear label, Discord channel) must be unique per run.

## Step 0 — Create the new repo (never build in the spec repo)
1. `git init` a new repo at `REPO_LOCATION`, named `RUN_ID`.
2. Copy everything under `$SPEC_REPO/templates/` into the new repo root (so `Editor/Builder.cs`, `docs/`, `AGENTS.md`, `DESIGN.md`, `.gitignore` land in place).
3. Create the Unity **3D** project in that repo (Unity 6 LTS) if not pre-created; add Android Build Support, Input System, 2D Sprite + 2D Atlas packages.
4. Commit: `chore: scaffold <RUN_ID> from spec kit`.

## Step 1 — Set up the rails
- Connect Unity MCP, Linear MCP, and Discord (webhook or bot per `RUNG`).
- Push the scaffold to GitHub; add Unity license secrets (`UNITY_LICENSE`, `UNITY_EMAIL`, `UNITY_PASSWORD`); **confirm `ci.yml` runs green** on the scaffold's sample tests (proves the test+CI loop before any feature work). See [Testing & CI/CD](10-Testing-and-CICD.md).
- **Verify the headless compile-check loop:** `scripts/unity-check.sh` flags a deliberately-broken `.cs` and returns CLEAN once fixed — no Editor focus. This is the agent's tightest feedback loop ([Toolchain › Headless compile & error check](03-Toolchain-and-Setup.md#headless-compile--error-check-no-window-focus)).
- **Game PM** (team config) reads `spec/GAME-SPEC.md` → creates the `SAA` epic + issues for this run.
- Memory: use `MEMORY` backend; seed `DESIGN.md` with `ART_STYLE` (or mark AGENT-DECIDES at L4).

## Step 2 — Build to the milestones (test-driven, PR-gated)
Work feature-branch → PR → `ci.yml` green → **QA gate** (team config: the independent [`qa`](roles/qa.SKILL.md) role verifies errors + playability on every major push) → merge on QA PASS. Add EditMode unit tests + PlayMode integration tests alongside each feature ([Testing & CI/CD](10-Testing-and-CICD.md)). Follow the milestone order (mirrors [../08-Roadmap](08-Roadmap.md)):
- **M1** core loop (input → gesture recognition → ruleset → scoring/combo), procedural placeholder targets, seeded RNG; **unit tests** for scoring/combo/gesture/determinism, one **PlayMode** input→score test.
- **M2** menus + HUD + high score + **Game Art** sprites/atlas + juice; **APK that installs** (via `build.yml` artifact); integration tests for lives/timer/game-over.
- **M3** balance, robustness, gameplay-quality harness (bot player + recorder + judge); determinism replay test.
- **M4 release polish** — full screen flow (splash/how-to-play/settings/pause), **music + SFX + haptics**, app icon/splash, animated transitions, 60fps perf pass, soak test. **Target ≥ 8/10 + "uninstall test"** ([release bar](spec/GAME-SPEC.md#release-quality-polish-the-real-goal-feels-like-a-game-a-human-would-keep)).
Each significant change (incl. **CI green/red**) → Discord (post-only L3/L4, two-way L1) + append `docs/run-log.md`.

**At each milestone checkpoint (M1/M2/M3 exit + any major architectural fork):** write/refresh formal ADRs in `adr/` for the significant architectural decisions made since the last checkpoint — follow `$SPEC_REPO/12-ADR-Process.md`, promoting them from the `docs/decisions.md` running log. Post the `adr/` summary to Discord.

## Step 3 — Acceptance & record
- Verify against `spec/ACCEPTANCE.md` (every gate + quality bars).
- Write the final entry in `docs/run-log.md` using the template there (outcome, interventions, code/15, gameplay/10, time, tokens, bottleneck, new gotchas).
- Tag the repo `run/<RUN_ID>`; ensure the `SAA` board matches reality (no fake "Done").

## Autonomy rung — what changes
| | L1 (Reviewer) | L3 (Spec-only) | L4 (Autonomous) |
|---|---|---|---|
| Human presence | in the loop | absent after launch | absent entirely |
| Open decisions (art/balance) | human, live (Discord) | human, baked into params up front | **agent decides + logs** |
| Linear `→ Done` | human approves | team self-transitions | team self-transitions |
| Discord | two-way bot/channel | post-only feed | post-only feed |
| Blocker needing human | ask in Discord | log assumption, proceed, flag | **counts as autonomy failure** |

## Output of a run (goes back to the human)
- The new repo (tagged), its `docs/run-log.md`, the APK, and a one-paragraph self-report.
- Copy the run-log summary line into the experiment results table (see [../07-Metrics](07-Metrics-and-Evaluation.md#output)).
