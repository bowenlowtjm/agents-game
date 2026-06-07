                                                          # Experiment Charter

## Why
Test new agentic tools & concepts on a *real, bounded* deliverable. A mobile game is ideal: it has code, assets, UI, build/packaging, and a clear "does it run and feel good" success bar. Small enough to finish, rich enough to stress an agent team.

## Primary hypothesis
> A multi-agent team on the Hermes harness can take Pully from empty repo to a playable, installable Android build with **review-only** human involvement — and the *gap* between autonomy levels is mostly about **spec quality, memory, and verification loops**, not raw model capability.

## Secondary questions
- Where does the team break without a human? (Asset pipeline? Unity Editor state? Scene wiring? Build signing?)
- Does an orchestrator + specialized workers beat a single strong agent at equal token budget?
- How much does **persistent memory** (decisions, conventions, gotchas) reduce repeated mistakes across runs?
- Kimi K2.5 vs Codex — which is the better *worker* for C#/Unity, and which is the better *orchestrator*?

## Scope guardrails (so the game doesn't eat the experiment)
- **In:** core tap loop, 3–4 target types, scoring, one game scene + menu, local high score, **generated 2D sprites + atlas** (Game Art agent), Android debug build, **measured gameplay quality**.
- **Out (v1):** monetization, ads, backend/leaderboards online, iOS signing, background music, AAA-level polish beyond the feel must-haves in [GAME-SPEC](spec/GAME-SPEC.md#flavor-feel--appeal-build-something-fun-not-just-correct), store submission. *(Core juice/SFX is in scope — appeal is a requirement.)*

## Definition of done (per run)
A run is "complete" when an agent (or the team) produces:
1. A Unity project that opens with no compile errors.
2. The core loop playable in Editor Play mode.
3. An Android APK that installs and launches on a device/emulator.
4. A short self-report: what was built, what's stubbed, known issues.

Quality and autonomy level are scored separately — see [Metrics & Evaluation](07-Metrics-and-Evaluation.md).

## Success looks like
Not "a great game." Success = **a clear, evidenced answer** to: *at which rung of the [Autonomy Ladder](05-Autonomy-Ladder.md) does the team stop being able to ship, and why?*
