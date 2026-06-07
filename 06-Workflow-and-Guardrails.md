# Workflow & Guardrails

How a run actually executes, and what keeps an unattended run safe and honest.

## The run loop (per task)
1. **Plan** — orchestrator reads brief + `GOTCHAS.md`, emits a task list.
2. **Implement** — worker edits code / drives Unity MCP on a branch.
3. **Verify** — after each C# edit run `scripts/unity-check.sh` (headless refresh + compile + read errors, no Editor focus needed) until CLEAN; then run tests, check console, attempt build.
4. **Gate** — open a PR. On every major push the **independent QA role** runs ([roles/qa](roles/qa.SKILL.md)): errors (compile/CI/console) + playability (bot run, smoke playthrough, feel). Orchestrator merges only on **QA PASS + green `ci.yml`**; else QA bounces it back with the failing check. (Solo config: the lone agent runs the QA checklist itself.)
5. **Record** — append to `run-log.md`; promote any new trap to `GOTCHAS.md`; log decisions in `docs/decisions.md`. **At milestone checkpoints / major architectural forks,** promote significant architectural decisions into formal ADRs in `adr/` (see [ADR Process](12-ADR-Process.md)).
6. **Broadcast** — if the change is *significant* (milestone, issue→Done, build produced, decision logged, escalation), post to Discord (see [Ladder › Communication](05-Autonomy-Ladder.md#communication-per-rung)): post-only webhook at L3/L4, two-way channel at L1.

Verification is non-negotiable: **"done" must come with an artifact** (clean console, passing test, APK path). This is what prevents the over-claiming failure mode at high autonomy.

## Guardrails (especially for L2–L4 unattended runs)
- **Branch isolation** — agents never commit to `main`; every run is an auditable diff.
- **Budget caps** — wall-clock + token ceiling per run; hitting the cap = stop and report, not "keep trying."
- **No destructive ops** — deny tools that wipe project/git history; `ProjectSettings/` changes flagged for review.
- **Loop breaker** — if the same task fails N times (e.g. 4), stop and escalate instead of burning budget.
- **Read-only secrets** — Android signing keys (if used) are injected, never generated/printed by agents.
- **Deterministic seeds** — RNG seeded so play-tests and any automated gesture sims are reproducible.

## Commit discipline
- One logical change per commit; message references the task id.
- `run-log.md` updated in the same commit as the work it describes.
- Tag each ladder run: `git tag run/<RUN_ID>` (e.g. `run/pully-B-L3-20260605`).

## What stops a run (escalation triggers)
| Trigger | Action |
|---------|--------|
| Compile errors persist after N fixes | Stop, dump console to report |
| Build (APK) fails 3× | Stop, capture batchmode log |
| Budget cap hit | Stop, summarize progress + remaining work |
| Agent proposes destructive/irreversible op | Block, require human (even at L3+) |
| Spec ambiguity blocks progress | L1: ask human in Discord · L3–L4: log assumption, proceed, flag it |

## Human-involvement mechanics per rung
- **L1 (Reviewer / agent pair):** human responds in the **Discord two-way channel**; the team asks questions + requests merge/issue approval; replies count as interventions.
- **L3 (Spec-only):** detached after the brief; team self-transitions issues and posts *significant changes* to the **Discord webhook feed**; no reply expected. Spec-ambiguity → log assumption, proceed, flag it.
- **L4 (Autonomous):** fully detached; only the escalation triggers above can interrupt. A trigger that genuinely needs a human is logged as an **autonomy failure**, not silently retried forever.
