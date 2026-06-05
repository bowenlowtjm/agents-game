# GAME-SPEC — Pully (authoritative)

A one-thumb arcade scorer. Build exactly this unless your run parameters say otherwise. Keep it small and deterministic.

## Platform & tech
- **Unity 6 LTS, 3D project.** Gameplay is **2D sprites** (textured quads/sprites) on a flat play-field viewed by an orthographic (or shallow-perspective) camera.
- **Input System** (new) — touch + pointer, so it runs in the Editor with a mouse.
- **Target:** Android, debug APK. Portrait orientation.

## Core loop
Targets spawn on the play-field. Each target has a **shape** + **color** that together define a **required gesture** (see [RULESET](RULESET.md)). The player performs the matching gesture before the target expires → score. Wrong gesture, miss, or expiry → penalty + combo break. Round is a **60-second timed mode** (deterministic, testable).

## Gesture vocabulary
| Gesture | Input |
|---------|-------|
| Single tap | one quick tap |
| Double tap | two taps < 300 ms |
| Long press | hold > 500 ms |
| Swipe-tap | tap + directional flick |
| Two-finger tap | two simultaneous touches |

Exact reward values and the shape×color→gesture mapping live in [RULESET](RULESET.md) and must be loaded from a **ScriptableObject** (`RulesetDefinition`), never hardcoded.

## Scoring
- Correct gesture: base reward × combo multiplier.
- Combo: ×1.1 per consecutive correct, capped ×5.
- Miss / wrong / expiry: combo resets to ×1, lose 1 life (3 lives) **or** time penalty — use **lives mode** for v1.
- Deterministic spawn via seeded RNG (seed in the ruleset) so sessions replay identically.

## Screens
1. **Main menu** — Play, best score, (settings stub).
2. **Game scene** — HUD (score, combo, lives, timer), spawn field.
3. **Game over** — score, best, Retry / Menu.

## Art (Game Art agent owns)
- v1 starts with **procedural placeholders** (solid-color primitive sprites) so logic isn't blocked.
- Then the Game Art agent replaces them with generated **2D sprites** for each shape, plus UI/FX, packed into a **sprite atlas**, consistent with the palette/style in `DESIGN.md`.
- Art style: set per run parameters (`ART_STYLE`) at L1/L3; the agent chooses at L4.

## Code shape (conventions)
- One assembly definition: `Pully.Game`.
- All game assets under `Assets/_Game/`.
- Tests under `Assets/Tests/` (EditMode for scoring/combo, PlayMode for one gesture→score path).
- Build via `Editor/Builder.cs` batchmode (already in templates).

## Explicitly out of scope (v1)
Monetization, ads, online leaderboards/backend, iOS signing, store submission, audio (optional stretch only). Don't build these.

## Stretch (only if asked / only as an autonomy stress test)
True-3D targets (depth/meshes + perspective camera); a new mechanic (e.g. power-up). Not part of v1.
