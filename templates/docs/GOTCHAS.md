# GOTCHAS.md — accumulated Unity/agent traps

Read before each phase. Append any new trap + its fix so the next run (and the next phase) avoids it. Seeded with common Unity-agent pitfalls; confirm/replace with what you actually hit.

## Seeded (verify in your setup)
- **.meta files:** every asset has a `.meta` with a GUID. Don't delete/regenerate casually — it breaks references. Commit them.
- **Scene wiring via MCP:** assigning serialized references through the Editor bridge often needs the object to exist + scene saved first; expect retries.
- **Input System:** project must be set to the new Input System (Player Settings) or touch reads return nothing.
- **Compilation pauses without focus:** Unity won't compile new C# until the Editor window regains focus. An unattended agent will write code and see *stale* errors. Always run `scripts/unity-check.sh` to force refresh+compile and read errors headlessly. (Also: Edit > Preferences > General > Auto Refresh = Enabled helps, but still often needs OS focus — the script is the reliable path.)
- **Two Editors, same project:** can't open one project in two Editors. Parallel runs use different projects + unique `PULLY_REFRESH_PORT` / MCP ports.
- **Batchmode build:** no enabled scenes in Build Settings → silent empty build. `Builder.cs` exits 2 to catch this.
- **Android module:** missing SDK/NDK/JDK → build fails late. Verify in M0.
- **Sprite import:** pixel art blurs unless filter mode = Point and compression = None.
- **Determinism:** any `Time.deltaTime`-driven spawn without a fixed/seeded step breaks replay. Drive spawns from the seeded sequence.
- **GameCI + Builder.cs:** don't pass `Builder.BuildAndroid` as GameCI `buildMethod` — its `EditorApplication.Exit` kills GameCI's flow. CI uses GameCI's default builder (→ `build/Android`); `Builder.cs` is local-only (→ `Builds/Android`).
- **Unity license in CI:** `ci.yml`/`build.yml` need `UNITY_LICENSE`+`UNITY_EMAIL`+`UNITY_PASSWORD` secrets; missing → CI fails at activation, not at your code.
- **Test asmdefs:** test assemblies need `UNITY_INCLUDE_TESTS` define constraint + `nunit.framework.dll` precompiled ref, else they compile into builds or fail to find NUnit.
- **PlayMode tests + Input System:** simulate input via `InputTestFixture` (Unity.InputSystem.TestFramework), not real devices.

## Discovered this experiment
- <date> — <trap> → <fix>
