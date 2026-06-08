---
name: code-conventions
description: Canonical clean-code conventions for Pully (Unity 6 / C#). Loaded by every coding role and enforced by the staff-engineer before each major commit. The run repo's docs/CONVENTIONS.md defers to this.
---

# Code Conventions — Pully (Unity 6 / C#)

The standard the [staff-engineer](staff-engineer.SKILL.md) enforces and every coding role follows. Goal: **correct, clean, deterministic, testable** code. Specifics beat preferences — when in doubt, match the surrounding code.

## Structure & assemblies
- All game content under `Assets/_Game/`. One game asmdef: **`Pully.Game`** (namespace `Pully.Game`). **One folder owns one asmdef** — never two asmdefs in the same folder (guaranteed compile conflict).
- Editor-only tools live in **`Pully.EditorTools`** (no game reference, so they run even when game code is broken).
- Tests in `Assets/Tests/` (`Pully.Tests.EditMode`, `Pully.Tests.PlayMode`) with the `UNITY_INCLUDE_TESTS` constraint + nunit precompiled ref.
- **Never rename a namespace/asmdef halfway and leave the old one behind** (the classic broken-scaffold failure).

## Naming
- PascalCase types/methods/properties; camelCase locals/params; private fields camelCase (consistent within the file); `UPPER_SNAKE` consts.
- Names state intent: `requiredGesture`, not `g`. No non-domain abbreviations.

## Data-driven — no hardcoding
- The ruleset (shape×color→gesture, rewards, combo step/cap, thresholds, timings, seed) comes from the **`RulesetDefinition` ScriptableObject** — never hardcode the mapping or magic numbers in logic.
- Tunables live in data/config, not literals scattered through code.

## Unity correctness & performance
- **No per-frame heap allocations** in `Update`/`FixedUpdate` — cache, pool, avoid `new`/LINQ/boxing in hot paths. **Object-pool** spawned targets.
- Cache component references; never `GetComponent` per frame. Guard against null/destroyed objects.
- Physics in `FixedUpdate`; input via the **Input System**; gameplay timing from a **seeded, fixed step** so sessions replay deterministically (the bot-player + tests depend on it).
- Coroutines/async: always handle cancellation and object destruction; no fire-and-forget leaks.

## Correctness & error handling
- Handle edge cases: zero/empty, combo at cap, simultaneous touches, expiry on the frame boundary, app backgrounding/rotation.
- Fail loud in dev (assert/log); never crash the player. No silent catch-all `catch {}`.
- Small, single-purpose functions; early-return over deep nesting.

## Tests
- Pure logic (scoring, combo, gesture classification, spawn sequence) is **EditMode**-unit-tested; scene/integration in **PlayMode**.
- Every bug fix adds a **regression test**. Don't delete or `[Ignore]` tests to go green.

## Comments & altitude
- Comment the **why**, not the what. Match surrounding density. No commented-out code, no dead code, no leftover TODOs in a "done" commit.

## Pre-commit checklist (staff-engineer enforces before every major commit)
- [ ] `scripts/unity-check.sh` CLEAN; relevant tests green
- [ ] No duplicate asmdefs; namespaces consistent across the tree
- [ ] No hardcoded ruleset values / magic numbers (data-driven via the SO)
- [ ] No per-frame allocations in hot paths; spawned objects pooled
- [ ] Edge cases handled; no silent stubs/TODOs
- [ ] Changed logic has tests; nothing skipped/deleted to pass
