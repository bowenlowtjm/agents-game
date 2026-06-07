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

## Flavor, feel & appeal (build something *fun*, not just correct)
Pully is a **reaction/dexterity** game — the joy is escalating pressure and the satisfying *snap* of nailing the right gesture just in time. Build for the **"one more go"** loop. A mechanically correct build with no juice is a *failed* build (see [ACCEPTANCE](ACCEPTANCE.md) gameplay bar).

**Theme (default — give it personality):** "**Critters**" — each shape is a little creature with a face that reacts: squashes when tapped, blinks idly, looks panicked as it's about to expire. Cute, high-contrast, instantly readable. *L1/L3: human may set a different theme via run params; L4: the agent picks one and records it in `DESIGN.md` with a one-line rationale.*

**Game-feel must-haves** (these directly drive the gameplay-quality score):
- **Juicy hits** — scale-pop + particle burst + a crisp sound on every correct gesture.
- **Felt misses** — screen shake/flash + a distinct "oof" so failure is felt, not just shown.
- **Combo escalation** — rising pitch + building visual intensity as the combo climbs; ×5 should feel *alive*.
- **Fair tension** — targets telegraph imminent expiry (shrink/flash/wobble) so a miss never feels cheap.
- **Reward the chase** — big satisfying score popups; a celebratory sting on a new high score.

**Reference games — borrow the *specific* thing, not the whole game:**
| Game | Borrow |
|------|--------|
| **Bop It** | the core "different action on cue" loop + escalating speed — Pully's gesture vocabulary *is* Bop It |
| **Fruit Ninja** | the satisfying swipe + particle splatter for the swipe-tap gesture |
| **Piano Tiles / Beatstar** | tap precision under rising tempo; "don't break the chain" tension |
| **Whack-a-Mole** | spawn-and-react target field + poppy hit feedback |
| **Color Switch / reflex tests** | minimal, instantly readable, addictive "one more try" |

**Anti-flatness rule:** static targets, no sound, no feedback → caps gameplay quality low **even if every functional gate passes**. Appeal is a requirement, not a bonus.

## Release-quality polish (the real goal: feels like a game a human would keep)
The **build stays a debug APK** — *no* store signing, keystore, or submission. But the **polish and feel must match a released hyper-casual game** (think the sheen of Fruit Ninja / Piano Tiles, scoped to Pully). Apply the **"uninstall test":** would a real player keep it past a few sessions? Every item below is required:

- **First-run experience** — a short **skippable how-to-play** that teaches the 5 gestures. No dead ends.
- **Looks finished** — app icon + splash screen, consistent UI, and **zero programmer-art placeholders**. It's a debug build, but it shouldn't *look* like one.
- **Audio** — a **background music loop** *and* a full SFX set (hit/miss/combo/UI/game-over), with **mute/volume in settings**. (Music is now in scope, not stretch.) Mobile **haptics** on hit/miss.
- **Juice everywhere** — every interaction has feedback: animated screen transitions, button press states, combo escalation, expiry telegraph, big score popups, a celebratory new-high-score moment.
- **UX completeness** — main menu, **settings** (sound/haptics, optional colorblind mode), **pause**, game-over with retry, persistent high score, and a reason to come back (score chase / rising difficulty / simple progression).
- **Performance** — stable **60 fps** on a mid-range Android device, cold start < ~3 s, no GC hitches or input lag.
- **Stability** — no crashes or softlocks across extended play; handles app backgrounding and rotation/locked-orientation correctly.

This bar is gated in [ACCEPTANCE](ACCEPTANCE.md) and scored in [../07-Metrics](07-Metrics-and-Evaluation.md). The autonomy experiment measures **how much human involvement it takes to reach this polish bar** — not just to compile. Distribution (signing, store submission, monetization) stays out of scope.

## Screens
1. **Splash / boot** — branded splash, fast load into menu.
2. **First-run how-to-play** — short, skippable, teaches the 5 gestures (shown once; replayable from settings).
3. **Main menu** — Play, best score, Settings.
4. **Settings** — music/SFX volume + mute, haptics toggle, optional colorblind mode, replay tutorial.
5. **Game scene** — HUD (score, combo, lives, timer), spawn field, **pause** button.
6. **Pause** — resume, restart, settings, quit to menu.
7. **Game over** — score, best (with celebratory new-high-score moment), Retry / Menu.

## Art (Game Art agent owns)
- v1 starts with **procedural placeholders** (solid-color primitive sprites) so logic isn't blocked.
- Then the Game Art agent replaces them with generated **2D sprites** for each shape, plus UI/FX, packed into a **sprite atlas**, consistent with the palette/style in `DESIGN.md`.
- Art style: set per run parameters (`ART_STYLE`) at L1/L3; the agent chooses at L4.

## Code shape (conventions)
- One assembly definition: `Pully.Game`.
- All game assets under `Assets/_Game/`.
- Tests under `Assets/Tests/` (EditMode for scoring/combo, PlayMode for one gesture→score path).
- Build via `Editor/Builder.cs` batchmode (already in templates).

## Explicitly out of scope
Distribution stays out: **release signing / keystore, store submission**, monetization, ads, online leaderboards/backend, iOS. The build is a **debug APK** — polished to release *quality* but not *distributed*.
- **Audio is in scope:** music loop **and** the SFX set (hit/miss/combo/UI/game-over) — part of the release-polish bar. Free/placeholder/generated sounds are fine (no paid tool required).

## Stretch (only if asked / only as an autonomy stress test)
True-3D targets (depth/meshes + perspective camera); a new mechanic (e.g. power-up). Not part of v1.
