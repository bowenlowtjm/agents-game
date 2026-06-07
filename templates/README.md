# templates/ — scaffold payload (copy into each new run repo)

These files are copied **verbatim into the new run repo** at Step 0 of [../RUN-PROTOCOL.md](../RUN-PROTOCOL.md), then filled in. They are not the spec — the spec is in `../spec/`.

| Path (→ repo root) | What it is | Fill-in |
|--------------------|-----------|---------|
| `AGENTS.md` | run-repo routing + conventions + spec pointer | none — ready |
| `DESIGN.md` | art taste memory | palette + style (Game Art / run param) |
| `Editor/Builder.cs` | batchmode Android build (agent-callable) | none — ready |
| `Editor/AutoRefresher.cs` · `LocalRefreshServer.cs` · `Pully.EditorTools.asmdef` | headless compile + error check (no Editor focus) | none — ready |
| `scripts/unity-check.sh` | wrapper: refresh+compile+read errors after each C# edit | set `PULLY_REFRESH_PORT` or `UNITY_BIN` |
| `Assets/_Game/Scripts/RulesetDefinition.cs` | data-driven ruleset SO | create an asset, populate from `spec/RULESET.md` |
| `Assets/_Game/Scripts/ScoreCalculator.cs` | pure scoring logic (unit-testable) | extend as the loop grows |
| `Assets/_Game/Scripts/Pully.Game.asmdef` | game assembly | none — ready |
| `Assets/Tests/EditMode/*` | unit tests + asmdef (1 passing sample) | add gesture/ruleset/determinism tests |
| `Assets/Tests/PlayMode/*` | integration tests + asmdef (1 passing sample) | add input→score / lives / replay tests |
| `.github/workflows/ci.yml` | run EditMode+PlayMode on PR (GameCI) | add `UNITY_*` secrets in repo |
| `.github/workflows/build.yml` | Android APK artifact on `main` (GameCI) | add `UNITY_*` secrets in repo |
| `docs/decisions.md` · `CONVENTIONS.md` · `GOTCHAS.md` · `run-log.md` | project memory | append during the run |
| `adr/README.md` | ADR index + template | write `ADR{NNN}-*.md` at milestone checkpoints (`$SPEC_REPO/12-ADR-Process.md`) |
| `tasks/BOARD.md` · `tasks/TEMPLATE.md` | local task board (replaces Linear) | PM writes `T###-*.md` task files; `status: done` gates autonomy |
| `.gitignore` | Unity ignores | none — ready |

After copying: create the Unity 6 **3D** project around these (Android module, Input System, 2D Sprite + 2D Atlas), then commit `chore: scaffold <RUN_ID> from spec kit`.

> Note: Unity also generates `ProjectSettings/`, `Packages/`, and `.meta` files when you create/open the project — commit those too. They aren't templated here because Unity produces them.
