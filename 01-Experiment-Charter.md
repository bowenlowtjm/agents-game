                                                          # Experiment Charter

## Why
Test new agentic tools & concepts on a *real, bounded* deliverable. A mobile game is ideal: it has code, assets, UI, build/packaging, and a clear "does it run and feel good" success bar. Small enough to finish, rich enough to stress an agent team.

## Primary hypothesis
> A multi-agent team on the Hermes harness can take Pully from empty repo to a **polished, release-quality** Android game (a debug build a real player would download and keep — see [Release-quality polish](spec/GAME-SPEC.md#release-quality-polish-the-real-goal-feels-like-a-game-a-human-would-keep)) with **review-only** human involvement — and the *gap* between autonomy levels is mostly about **spec quality, memory, and verification loops**, not raw model capability.

## Secondary questions
- Where does the team break without a human? (Asset pipeline? Unity Editor state? Scene wiring? Build signing?)
- Does an orchestrator + specialized workers beat a single strong agent at equal token budget?
- How much does **persistent memory** (decisions, conventions, gotchas) reduce repeated mistakes across runs?
- Kimi K2.5 vs Codex — which is the better *worker* for C#/Unity, and which is the better *orchestrator*?

## Scope guardrails (so the game doesn't eat the experiment)
- **In:** core tap loop, 3–4 target types, scoring, full screen flow (splash, how-to-play, menu, settings, pause, game-over), local high score, **generated 2D sprites + atlas + app icon/splash**, **music + SFX + haptics**, **release-quality polish** (juice, transitions, 60fps), Android **debug** build, **measured gameplay & polish quality**.
- **Out:** **release signing / keystore, store submission**, monetization, ads, online backend/leaderboards, iOS. The build is a polished *debug* APK — release **quality**, not release **distribution**.

## Definition of done (per run)
A run is "complete" when an agent (or the team) produces:
1. A Unity project that opens with no compile errors.
2. The core loop playable in Editor Play mode.
3. An Android (debug) APK that installs and launches on a device/emulator.
4. **The full game flow + release-quality polish** met (see [Release-quality polish](spec/GAME-SPEC.md#release-quality-polish-the-real-goal-feels-like-a-game-a-human-would-keep)): onboarding, settings, pause, audio, juice, icon/splash, 60fps, no softlocks.
5. A short self-report: what was built, what's stubbed, known issues.

Quality and autonomy level are scored separately — see [Metrics & Evaluation](07-Metrics-and-Evaluation.md). Item 4 (polish) is the bar that distinguishes "a build" from "a game someone would keep."

## Success looks like
Not "a great game." Success = **a clear, evidenced answer** to: *at which rung of the [Autonomy Ladder](05-Autonomy-Ladder.md) does the team stop being able to ship, and why?*
