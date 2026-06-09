# Parallel Runs & Discord Routing

Running the [Autonomy Ladder](05-Autonomy-Ladder.md) 3×2 grid (and model phases) means many runs. They can run **in parallel** — each run is already isolated (new repo per `RUN_ID`, git worktrees, own local `tasks/` board). To run N at once, namespace every *shared* resource.

## Isolation checklist (per concurrent run)
| Resource | Collision risk | Isolation |
|----------|---------------|-----------|
| **Repo / filesystem** | shared mutable state | own directory per `RUN_ID` (already the model) |
| **Unity Editor + MCP** | can't open the same project twice; two Editors need distinct projects **and ports** | one Editor process per run; `UNITY_MCP_PORT` unique per run |
| **Headless refresh server** | `LocalRefreshServer` binds a port | `PULLY_REFRESH_PORT` unique per run (e.g. 8090, 8091) |
| **OpenViking (team mem)** | cross-run contamination | namespace `viking://runs/<RUN_ID>/`; or a separate instance |
| **flat-docs (solo mem)** | — | per-repo already, no action |
| **Task board** | — | `tasks/` is local per-repo, so runs never collide (no shared tracker to namespace) |
| **Model API keys** | shared rate limits | mind quotas; per-run key or a gateway with per-run budget |
| **CI (GameCI)** | — | naturally parallel on GitHub runners — **push heavy test/build here** |
| **Discord** | interleaved posts | one channel/thread per run (below) |

> Bottleneck: the **local Unity Editor + MCP** is the real contention point, not the agents. Give each concurrent local run its own Editor + `UNITY_MCP_PORT`; parallelize tests/builds in CI where it's free. If you only have one Editor seat, serialize the Editor-bound steps and still parallelize everything else.

## Orchestration (meta-launcher)
A thin launcher starts each run and records it in a **registry**:
1. Scaffold the run repo from `$SPEC_REPO/templates/` (per [RUN-PROTOCOL](RUN-PROTOCOL.md)); push Unity CI secrets to it via `scripts/push-unity-secrets.sh <repo>` (or once org-wide — see [SETUP-CREDENTIALS §7](SETUP-CREDENTIALS.md#7-build--ci-)).
2. Start Unity + MCP on a free `UNITY_MCP_PORT`.
3. Assign the Discord target + Viking namespace (tasks are local per-repo — nothing to assign).
4. Hand the agent its run-parameter block; launch.
5. Post to **`#hermes-update`** (`HERMES_UPDATE_CHANNEL`): "started `<RUN_ID>`"; post again on completion with the outcome + quality scores.

Keep a registry mapping `RUN_ID ↔ repo ↔ UNITY_MCP_PORT ↔ PULLY_REFRESH_PORT ↔ discord-target` (a simple `runs/registry.md`). The launcher must allocate unique ports and Discord targets so two runs never share.

## Discord disambiguation — DECIDED: channel-per-run
A **"Pully Experiments" category** with **one channel named `<RUN_ID>`** per run, plus **`#hermes-update`** — the **Hermes agent's update channel** (harness-level, cross-run). Each run → its own webhook (L3/L4) or the shared bot scoped to that channel (L1). Clean, skimmable, and one channel = one run's full history.

```
Pully Experiments/
  #hermes-update            <- Hermes posts harness-level updates: run start/finish,
                               grid status, cross-run summaries, launcher errors
  #pully-a-l1-20260606      <- one channel per RUN_ID (the run's own feed)
  #pully-b-l3-20260606
  #pully-b-l4-20260606
  …
```

**`#hermes-update` (the update channel):** the Hermes harness/launcher posts here — when a run is spawned, when it completes (with its outcome + quality scores), grid progress, and any launcher/infra errors. Per-task significant changes still go to the run's own channel; `#hermes-update` is the roll-up you watch to track all runs at a glance. Set its webhook/id in `HERMES_UPDATE_CHANNEL`.

**Always:** prefix every message `[RUN_ID]`, set webhook `username=<RUN_ID>`, and store the per-run channel id in `DISCORD_TARGET`.

*Alternatives (not chosen):* thread-per-run (one parent channel, webhook `?thread_id=`) or forum-per-run (webhook `thread_name`) — use only if channel sprawl becomes a problem.

### Mechanism by rung
- **L3/L4 (post-only):** one webhook per channel/thread → `DISCORD_TARGET` holds the webhook URL (append `?thread_id=` for threads). Fire-and-forget; no routing needed.
- **L1 (two-way):** a single bot listens on **all** run channels and routes each incoming human reply to the run that owns that `channel_id`. Maintain a `RUN_ID → channel_id` map; **never** broadcast a reply to the wrong run. The bot tags its own posts with `[RUN_ID]` so a human always knows which run they're answering.

## Run parameters added for parallelism
See [RUN-PROTOCOL](RUN-PROTOCOL.md#run-parameters-human-fills-before-launch):
```
UNITY_MCP_PORT:    <unique per concurrent run>        # e.g. 6401, 6402, …
PULLY_REFRESH_PORT: <unique per concurrent run>       # e.g. 8090, 8091 — headless compile-check server
DISCORD_TARGET:    <channel-id (bot, L1) | webhook-url (L3/L4)>   # the run's own channel; replaces shared DISCORD
VIKING_NAMESPACE:  viking://runs/<RUN_ID>/            # team memory (Config B)
# (work tracking: local tasks/ in each run repo — nothing to namespace)
```
