# Metrics & Evaluation

Same scorecard every run. Four buckets: **did it ship**, **code quality**, **gameplay quality**, **cost/autonomy**.

## A. Shipped? (binary gates — from [Charter DoD](01-Experiment-Charter.md#definition-of-done-per-run))
- [ ] Opens with no compile errors
- [ ] Core loop playable in Editor
- [ ] APK installs + launches
- [ ] **CI green** (`ci.yml` tests pass) + APK artifact from `build.yml`
- [ ] Self-report produced
- [ ] `tasks/BOARD.md` reflects real state (no fake "done")

## B. Code quality (0–3 each)
| Dimension | 0 | 3 |
|-----------|---|---|
| Spec fidelity | wrong game | every brief rule correct (gestures, mapping, scoring) |
| Code health | no asmdef, hardcoded, no tests | clean asmdef, data-driven ruleset, tests present |
| Robustness | crashes / softlocks | handles miss/edge inputs, deterministic |
| Honesty of self-report | over-claims, hides stubs | accurately lists stubs + known issues |
| Art integration | placeholders only | generated sprites + packed atlas, consistent palette |

## C. Gameplay & polish quality (the headline metric) — score /10, **release bar ≥ 8**
The goal is a game a human would download and keep, so the bar is high. Combine **objective proxies** + an **LLM judge** + (at L1 only) a **human rating**, then reconcile.

| Sub-metric | How measured | Weight |
|-----------|--------------|--------|
| **Input responsiveness** | tap→feedback latency (ms) from PlayMode instrumentation; target < 60ms | 1.5 |
| **Readability** | can a fresh player tell which gesture each target wants? LLM judge on screenshots + human at L1 | 1.5 |
| **Difficulty curve** | bot-player score distribution over seeded sessions; not trivially win/lose | 1 |
| **Game feel / juice** | LLM judge on a 20s capture: hit pop, miss flash, combo escalation, transitions, **audio**, haptics | 2 |
| **Finish / polish** | app icon + splash, **no placeholders**, complete UX (onboarding/settings/pause), animated menus | 2 |
| **Stability + perf** | stable **60fps**, 0 softlocks/crashes across N seeded bot runs + extended play | 1 |
| **"Uninstall test"** | judge (+ L1 human): would a real player keep it past a few sessions? | 1 |

**Mechanics:**
- **Bot player** — a scripted/agent player drives seeded sessions; we log score, misses, session length, FPS. Removes human bottleneck from the quantitative half.
- **LLM-as-judge** — feed a short gameplay capture (frames or video) + the [Game Brief](02-Game-Design-Brief.md) to a model; it rates readability/feel on a rubric and must cite what it saw. Same judge + rubric every run for comparability.
- **Human anchor (L1 only)** — one human plays and rates; used to calibrate/validate the judge. At L3/L4 the judge stands alone (and *that gap* is itself a finding).

> Why it matters: "shipped + compiles" says nothing about whether the game is good. Gameplay quality is what separates "agents produced *a* build" from "agents produced something worth playing" — the real test of high-autonomy capability.

## D. Cost & autonomy
- **Human interventions** (count + type) — the headline autonomy number.
- **Wall-clock** to green APK · **tokens** total + per role · **retries** at the bottleneck.
- **Rung reached** — highest of L1/L3/L4 that still shipped *and* cleared the **release-polish bar (≥ 8/10)**.

## The comparisons that matter
1. **Solo (A, flat docs) vs Hermes role-team (B, OpenViking)** at equal budget — does orchestration + roles earn its overhead? (Note: this bundles the memory-backend change — see caveat in [Architecture › Memory](04-Agent-Team-Architecture.md#memory).)
2. **Rung descent (L1→L3→L4)** — gameplay-quality vs human-involvement curve. Where's the cliff?
3. **Memory backend** — optional follow-ups: run B on flat docs to isolate orchestration; or swap in Letta/Zep ([options](09-Tool-Stack-Options.md#8-agent-memory-backends)) to test repeated-mistake avoidance.
4. **Model placement (Phase 2: K0 vs C1/C2/C3)** — does swapping Codex in for orchestrator/worker beat the all-Kimi baseline?
5. **Judge vs human** — how well does the LLM gameplay judge track the human anchor?

## Output
```
| Run  | Cfg | Rung | Mem | Shipped | Code/15 | Gameplay/10 | Interventions | Time  | Tokens | Bottleneck   |
|------|-----|------|-----|---------|---------|-------------|---------------|-------|--------|--------------|
| A-L1 | solo| L1   | on  | ✅      | 11      | 6           | 3             | 2h40m | ~X     | scene wiring |
| B-L3 | team| L3   | on  | ✅      | 13      | 7           | 0             | 3h12m | ~Y     | APK signing  |
| ...  |     |      |     |         |         |             |               |       |        |              |
```
Plus a short writeup: *at which rung does it stop shipping playable-quality, what's the dominant bottleneck, and which lever (spec / memory / verification / roles / model) moves the needle most?*
