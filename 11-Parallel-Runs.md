# Parallel Runs & Discord Routing

Running the [Autonomy Ladder](05-Autonomy-Ladder.md) 3×2 grid (and model phases) means many runs. They can run **in parallel** — each run is already isolated (new repo per `RUN_ID`, git worktrees, own Linear issues). To run N at once, namespace every *shared* resource.

## Isolation checklist (per concurrent run)
| Resource | Collision risk | Isolation |
|----------|---------------|-----------|
| **Repo / filesystem** | shared mutable state | own directory per `RUN_ID` (already the model) |
| **Unity Editor + MCP** | can't open the same project twice; two Editors need distinct projects **and ports** | one Editor process per run; `UNITY_MCP_PORT` unique per run |
| **OpenViking (team mem)** | cross-run contamination | namespace `viking://runs/<RUN_ID>/`; or a separate instance |
| **flat-docs (solo mem)** | — | per-repo already, no action |
| **Linear (SAA)** | one board, many runs | label or sub-project `run:<RUN_ID>` on every issue |
| **Model API keys** | shared rate limits | mind quotas; per-run key or a gateway with per-run budget |
| **CI (GameCI)** | — | naturally parallel on GitHub runners — **push heavy test/build here** |
| **Discord** | interleaved posts | one channel/thread per run (below) |

> Bottleneck: the **local Unity Editor + MCP** is the real contention point, not the agents. Give each concurrent local run its own Editor + `UNITY_MCP_PORT`; parallelize tests/builds in CI where it's free. If you only have one Editor seat, serialize the Editor-bound steps and still parallelize everything else.

## Orchestration (meta-launcher)
A thin launcher starts each run and records it in a **registry**:
1. Scaffold the run repo from `$SPEC_REPO/templates/` (per [RUN-PROTOCOL](RUN-PROTOCOL.md)).
2. Start Unity + MCP on a free `UNITY_MCP_PORT`.
3. Assign the Discord target + Linear label + Viking namespace.
4. Hand the agent its run-parameter block; launch.

Keep a registry mapping `RUN_ID ↔ repo ↔ UNITY_MCP_PORT ↔ discord-target ↔ linear-label` (a simple `runs/registry.md` or a Linear project). The launcher must allocate unique ports and Discord targets so two runs never share.

## Discord disambiguation — pick one pattern
| Pattern | How | Best when |
|---------|-----|-----------|
| **Channel-per-run** *(recommended)* | a "Pully Experiments" category; one channel named `<RUN_ID>`. Each run → its own webhook (L3/L4) or bot scoped to that channel (L1). Add `#pully-control` for cross-run roll-ups. | the grid — clean & skimmable |
| **Thread-per-run** | one parent channel, a thread per run. Webhook posts to a thread via `?thread_id=<id>`; bot tracks `thread_id`. | keep it all in one place |
| **Forum-per-run** | a forum channel, one post/thread per run via webhook `thread_name`. | tidy archive |

**Always:** prefix every message `[RUN_ID]`, set webhook `username=<RUN_ID>`, and store the channel/thread id in run params.

### Mechanism by rung
- **L3/L4 (post-only):** one webhook per channel/thread → `DISCORD_TARGET` holds the webhook URL (append `?thread_id=` for threads). Fire-and-forget; no routing needed.
- **L1 (two-way):** a single bot listens on **all** run channels and routes each incoming human reply to the run that owns that `channel_id`. Maintain a `RUN_ID → channel_id` map; **never** broadcast a reply to the wrong run. The bot tags its own posts with `[RUN_ID]` so a human always knows which run they're answering.

## Run parameters added for parallelism
See [RUN-PROTOCOL](RUN-PROTOCOL.md#run-parameters-human-fills-before-launch):
```
UNITY_MCP_PORT:  <unique per concurrent run>          # e.g. 6401, 6402, …
DISCORD_TARGET:  <channel-id | webhook-url | thread-id>   # per run; replaces shared DISCORD
VIKING_NAMESPACE: viking://runs/<RUN_ID>/             # team memory (Config B)
LINEAR_LABEL:    run:<RUN_ID>                          # on every SAA issue
```
