# Autonomy Ladder

The core experiment: build Pully at **three** human-involvement levels — **L1, L3, L4** — holding the [Game Brief](02-Game-Design-Brief.md), toolchain, and roles constant. Change *only* the human's role. Find where shipping breaks.

> Scope: we deliberately skip L0 (full pair) and L2 (milestone-gate) to focus on the three points that bracket the interesting transition — **supervised**, **fire-and-forget from a spec**, and **fully autonomous**.

| Rung | Human role | Human touches | Linear (SAA) gate | What it tests |
|------|-----------|---------------|-------------------|---------------|
| **L1 — Reviewer** | PR/issue gatekeeper | Reviews each merge, approves/rejects, answers questions when asked | Human moves issues `In Review → Done` | Can the team self-drive *between* checkpoints? |
| **L3 — Spec-only** | Author, then absent | Writes the brief, presses go, returns at the end | Team self-transitions; human reads final board | Is spec + memory + roles enough? Where does it silently fail? |
| **L4 — Autonomous** | Observer | No input; team self-specs from a one-line prompt | Game PM agent owns the whole board | Pure capability ceiling of the harness |

## Who decides open design/art questions
When the spec leaves something open (e.g. **art style** — flat-vector vs pixel — or a balance call), ownership follows the rung:

| Rung | Who decides | Mechanism |
|------|-------------|-----------|
| **L1 — Reviewer** | **You (human)**, live | Game PM proposes, you choose in the loop |
| **L3 — Spec-only** | **You (human)**, up front | You bake the choice into the brief before pressing go; team executes it |
| **L4 — Autonomous** | **The agent** | Game PM agent decides and logs rationale; no human input |

So art direction is a *fixed input* at L1/L3 and a *measured output* at L4 — at L4 the team's taste itself is under test.

## Communication per rung (Discord)
The human↔agent channel changes shape with autonomy — one-way feed when the human is absent, two-way when they're in the loop.

| Rung | Discord mode | Mechanism | Direction |
|------|--------------|-----------|-----------|
| **L1 — Reviewer** (agent pair) | **Channel for communication** | Discord **bot / MCP** (read + write) | two-way — agent asks, you approve/answer in-channel |
| **L3 — Spec-only** | **Significant-change feed** | Discord **webhook** (post-only) | one-way — you monitor async, no reply expected |
| **L4 — Autonomous** | **Significant-change feed** | Discord **webhook** (post-only) | one-way — agent broadcasts; you observe |

- **L1** uses Discord as a genuine back-and-forth workspace: the team pings questions, balance/art choices, and merge approvals; your replies unblock it (these count as interventions in [Metrics](07-Metrics-and-Evaluation.md)).
- **L3/L4** post *significant changes only* (milestone, issue→Done, build produced, decision logged, escalation) so the feed stays signal-dense. No human reply is part of the run; at L4 an escalation that *would* need a human is itself a recorded failure of autonomy.

## Protocol
- Same brief, tools, roles, and model config within a ladder pass.
- **Two configs:** Config A (solo) and Config B (Hermes role-team) across L1/L3/L4 → a **3×2 grid**.
- Optional extra dimension: **memory on/off** (see [Architecture › Memory](04-Agent-Team-Architecture.md#memory)).
- Cap each run: wall-clock + token budget (so "infinite retries" isn't how it wins).

## What to watch
- **L1→L3:** removing the human reviewer — does the team drift from the spec, over-claim "Done", or stub the hard parts (build signing, scene wiring, art import)?
- **L3→L4:** with no spec ratification, does the Game PM agent even scope the *right* game, or invent its own?
- Across all: where does it break first — Editor bridge, build toolchain, gesture recognition, or art import?

## Expected break point (hypothesis to falsify)
Shipping holds at **L1**, gets shaky at **L3** (silent stubs, over-claiming, art drift), and the failure is dominated by **verification + Editor-bridge gaps**, not coding ability. With **memory on**, the team should hold up better at L3. Whether that's true is a headline result.

## Per-run record (`docs/run-log.md`)
```
Run: pully-B-L3 / memory=OpenViking
Models: orch=Kimi K2.5, workers=Kimi K2.5   (Phase 1)
Linear: SAA epic #__, 9/11 issues Done
Outcome: APK built ✅ / wrong gesture mapping ❌ / art atlas ✅
Human interventions: 0 (spec-only)
Gameplay quality: 7/10 (judge) · latency 48ms · 0 softlocks
Time: 3h12m   Tokens: ~X
Bottleneck: scene wiring 4 retries (MCP ref assignment)
New gotcha: ...
```
