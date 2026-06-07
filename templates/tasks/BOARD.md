# tasks/ — local task board (replaces Linear)

Coordination is **local markdown** — no external tracker, no API key. **Source of truth = one file per task:** `tasks/T###-slug.md` (frontmatter holds status/owner/etc). This file is the human-readable **index**; the **Game PM keeps it in sync** with the task files.

One-file-per-task (not a single shared board) is deliberate: parallel role worktrees can each edit their own task file without merge conflicts.

## Statuses
`todo` → `in-progress` → `in-review` → `done`  (or `blocked`).
**Who may set `status: done` is the autonomy gate** — a human at **L1**, the team itself at **L3/L4** (see [Autonomy Ladder](../../05-Autonomy-Ladder.md)). `in-review` = QA gate running.

## Board (index — keep in sync with the task files)
| ID | Title | Status | Milestone | Owner | Branch |
|----|-------|--------|-----------|-------|--------|
| T001 | _(example — replace)_ | todo | M1 | game-logic | feature/T001-… |

## How to use
- **Create a task:** copy `TEMPLATE.md` → `T###-slug.md`, fill the frontmatter, add a row here.
- **Update status:** edit the task file's `status:` field **and** its row here (keep them consistent).
- Each **branch / PR / commit references `T###`**. Significant changes (incl. status→done, build, blocker) → Discord + `docs/run-log.md`.
- No fake `done`: a task is `done` only with a verification artifact (clean compile, passing test, APK path, atlas…).
