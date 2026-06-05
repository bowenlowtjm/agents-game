# Game Design Brief — Pully

A one-thumb arcade scorer. Keep it tiny and deterministic so agents can build *and verify* it.

## Core loop
Targets spawn on screen. Each target has a **shape** and a **color**, which together define the **required gesture**. Player performs the matching finger tap → score. Wrong gesture or miss → penalty / streak break. Survive a timer or a lives count.

## The tap vocabulary (the "variations")
| Gesture | Input | Default reward |
|---------|-------|----------------|
| Single tap | one quick tap | +1 |
| Double tap | two taps < 300ms | +3 |
| Long press | hold > 500ms | +5 |
| Swipe-tap | tap + directional flick | +5 |
| Two-finger tap | simultaneous 2-finger | +8 |

## Target → required gesture mapping (example ruleset)
| Shape | Color | Required gesture |
|-------|-------|------------------|
| Circle | Green | Single tap |
| Circle | Red | Long press (defuse) |
| Square | Blue | Double tap |
| Triangle | Yellow | Swipe-tap (flick away) |
| Star | Purple | Two-finger tap |

Rules live in a **ScriptableObject ruleset** so the mapping is data-driven — an agent can tune balance without touching input code. This is deliberate: it tests whether agents design for data-driven config vs hardcoding.

## Scoring & feel
- Combo multiplier: consecutive correct gestures ×1.1 each, capped ×5.
- Miss / wrong gesture: lose combo, –1 life (3 lives) **or** time penalty (pick one mode).
- Round length: 60s timed mode for v1 (deterministic, easy to test).
- Minimal "juice": scale-pop on hit, color flash on miss, score counter tween.

## Screens
1. **Main menu** — Play, high score, (settings stub).
2. **Game scene** — HUD (score, combo, lives/timer), spawn field.
3. **Game over** — score, best, retry / menu.

## Tech constraints (keeps agents on rails)
- **3D engine, 2D-sprite gameplay (decided).** Unity 6 LTS, a 3D project, but targets render as **sprites / textured quads** on a flat play-field with an orthographic (or shallow-perspective) camera. This gives a 3D engine/pipeline (lighting, post, depth, particles) while keeping gameplay and art 2D and cheap. The **Game Art agent** owns the sprite pipeline — see [Architecture](04-Agent-Team-Architecture.md).
- Input via the new **Input System** (touch + pointer) so it runs in Editor with mouse.
- **v1 art:** procedural shapes + solid colors first (unblocks logic), then the Game Art agent replaces them with generated 2D sprites + a packed atlas. Real art is no longer "out of scope" — it's a named role.
- One assembly definition for game code → faster compiles, cleaner agent edits.
- Deterministic spawn via seeded RNG so play-tests and any automated tests are repeatable.

## Later stretch (autonomy stress test, not v1)
- **True-3D-ify run** — give targets real depth/meshes and a perspective camera, handed to the team cold as an autonomy test on an existing codebase. Flagged in [Roadmap](08-Roadmap.md).
