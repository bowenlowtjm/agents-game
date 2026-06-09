# Testing & CI/CD

Automated testing is the **verification backbone** — especially at L3/L4 where the team can't ask a human, so *green CI is the artifact* that proves "done." This doc defines the test pyramid and the GitHub Actions pipeline. Scaffold tests + workflows ship in `templates/` and **pass on a fresh repo**, so CI is green from commit 0 and the agent extends them.

## Test pyramid for Pully
| Layer | Unity mode | Speed | Covers |
|-------|-----------|-------|--------|
| **Unit** | **EditMode** (NUnit) | ms, no scene | scoring/combo math, gesture classification, ruleset lookup, seeded spawn sequence (pure logic) |
| **Integration** | **PlayMode** | seconds, real scene | input→gesture→score end-to-end, spawn/expiry, lives/timer, game-over flow, **deterministic replay** |
| **Build/E2E** | GameCI build + (opt) emulator | minutes | APK builds, installs, launches; smoke run via bot player |

Keep the base wide: most logic (scoring, combo, gesture thresholds, spawn RNG) should be **pure and unit-tested in EditMode**, not requiring a scene.

## Unit tests (EditMode) — what to cover
- `ScoreCalculator`: combo step, cap clamp, score rounding (sample test ships in `templates/`).
- Gesture classification: timing thresholds (double-tap < 300ms, long-press > 500ms, swipe distance) from the ruleset.
- Ruleset lookup: each shape×color → correct required gesture + reward.
- Spawn determinism: same seed → same target sequence.
- Edge cases: wrong gesture, expiry, combo reset on miss.

## Integration tests (PlayMode) — what to cover
- Load the game scene; assert HUD + spawner exist.
- **Simulate input** with the Input System's `InputTestFixture` (synthetic touches/taps); assert score + combo update.
- Lives decrement on miss; timer ends the round; game-over screen shows final + best.
- **Determinism:** run a seeded session twice with the same input timeline → identical final score (the bot player + gameplay-quality metric depend on this).

## Test layout (in the run repo)
```
Assets/Tests/
  EditMode/   Pully.Tests.EditMode.asmdef  + *Tests.cs
  PlayMode/   Pully.Tests.PlayMode.asmdef  + *Tests.cs
```
asmdefs reference `Pully.Game` + `UnityEngine.TestRunner`/`UnityEditor.TestRunner` (+ `Unity.InputSystem.TestFramework` for PlayMode). Both ship in `templates/` with one passing sample each.

## CI/CD pipeline (GitHub Actions + GameCI)
Two workflows ship in `templates/.github/workflows/`:

> **CI is the pre-merge gate, NOT the inner loop.** The agent compile-checks **locally** every edit via `scripts/unity-check.sh` (seconds, no Docker pull). Waiting on cloud CI per edit is minutes of image-pull + asset import — don't. CI runs to confirm green before merge. The codex run got slow precisely by leaning on CI as its inner loop.

| Workflow | Trigger | Does | Cost |
|----------|---------|------|------|
| **`ci.yml` — EditMode** | every push to `feature/**` | EditMode (unit) tests via `game-ci/unity-test-runner` (compiles the code too) | **light** — base editor image, no PlayMode/Android |
| **`ci.yml` — PlayMode** | PR to `main` (+ dispatch) | adds the slower PlayMode pass | full |
| **`build.yml`** | push to `main` (+ dispatch) | Android APK via `game-ci/unity-builder` | **heavy** — Android NDK image; never on feature pushes |

Light-per-push / heavy-on-main keeps the feature loop cheap and reserves the slow Android build for milestones. All cache the Unity `Library/` folder (first run is cold + pulls a multi-GB image — *that's* the one-time slow run; subsequent runs are far faster), and require the license secrets (see [SETUP-CREDENTIALS §7](SETUP-CREDENTIALS.md#7-build--ci-)): `UNITY_LICENSE`, `UNITY_EMAIL`, `UNITY_PASSWORD`.

**Anti-patterns (these made the codex CI take forever):** validating compilation with the **Android builder image** (use EditMode / a Linux target — no NDK needed to compile); running **PlayMode + Android build on every feature push**; and **two overlapping workflows** firing per push. Don't.

### Pipeline gates
1. **Feature push** → EditMode (fast). **Open PR** → EditMode + PlayMode. Red = blocked; orchestrator merges only green (mirrors the [Workflow](06-Workflow-and-Guardrails.md) "verify with an artifact" rule).
2. **Merge to `main`** → `build.yml` produces the APK artifact = the shippable build for that milestone.
3. CI status is a **significant change** → post to Discord per rung (green/red + run URL).

> Build note: **CI uses GameCI's built-in builder** (outputs to `build/Android`). The local `Editor/Builder.cs` batchmode method is for agent-driven *local* builds and calls `EditorApplication.Exit` — do **not** pass it as GameCI `buildMethod` (the exit call breaks GameCI's flow). Two paths, same APK; keep them separate.

## Why this matters per autonomy rung
- **L1:** CI gives the human reviewer a green/red signal to approve against.
- **L3/L4:** CI *is* the human's stand-in. "Tests pass + APK artifact exists" is the only trustworthy "done" — it's what stops the over-claiming failure mode. A team that marks tasks `done` with red CI is auto-failing the honesty metric.

## Acceptance hooks
The [ACCEPTANCE](spec/ACCEPTANCE.md) gates require: tests present, **`ci.yml` green**, and **`build.yml` produced an APK artifact**. No green CI → not done.
