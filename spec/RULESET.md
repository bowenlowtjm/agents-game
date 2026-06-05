# RULESET — target mapping & tuning (authoritative data)

Load this into the `RulesetDefinition` ScriptableObject (`templates/Assets/_Game/Scripts/RulesetDefinition.cs`). These are the v1 default values — the Game PM may tune them during balancing (M3) and must log changes in `docs/decisions.md`.

## Target → required gesture
| Shape | Color | Required gesture | Base reward |
|-------|-------|------------------|-------------|
| Circle | Green | Single tap | 1 |
| Circle | Red | Long press (defuse) | 5 |
| Square | Blue | Double tap | 3 |
| Triangle | Yellow | Swipe-tap (flick) | 5 |
| Star | Purple | Two-finger tap | 8 |

## Combo & scoring
| Param | Value |
|-------|-------|
| Combo step (per consecutive correct) | ×1.1 |
| Combo cap | ×5.0 |
| Score awarded | `round(base_reward × current_combo)` |
| On miss / wrong / expiry | combo → ×1.0, −1 life |

## Round / session
| Param | Value |
|-------|-------|
| Mode | timed |
| Round length | 60 s |
| Lives | 3 |
| Target lifetime (on screen) | 1.6 s (tune in M3) |
| Spawn interval | starts 1.2 s, ramps to 0.6 s over the round |
| Max concurrent targets | 4 |
| RNG seed (default) | 12345 |

## Determinism contract
Given the same seed + the same input timeline, the spawn sequence and final score **must** be identical. The gameplay-quality bot player and PlayMode tests rely on this.

## Balancing guidance (M3)
- Aim for a median bot-player score that is neither trivially maxed nor near-zero across 10 seeded sessions.
- Red-circle long-press is the "trap" — it should feel punishing if mis-tapped (single tap on red = wrong).
- Keep gesture-recognition thresholds (300 ms / 500 ms / flick distance) in the ruleset so they're tunable without code edits.
