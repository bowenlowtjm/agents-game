# SETUP-CREDENTIALS

Secrets/accounts needed to run Pully. **Decision: not using Claude Code** → no gstack, no GBrain, no Conductor; the role layer + team memory + parallelism use non-Claude substitutes (see [Architecture](04-Agent-Team-Architecture.md)). Anthropic auth is therefore **not required** (Claude is optional, only if you later add it as a *model*).

Legend: 🔴 required to run any rung · 🟡 required for a specific feature/rung · ⚪ optional/stretch · ✅ no credential needed.

## 1. Models — phased (🔴 Kimi now, Codex later)
**Phase 1 = Kimi-only.** Codex is added in Phase 2 (see [Architecture › Model placement](04-Agent-Team-Architecture.md#model-placement-to-test-phased)).
| Cred | Var | Where | Notes |
|------|-----|-------|-------|
| 🔴 Kimi K2.5 API key | `MOONSHOT_API_KEY` | platform.moonshot.ai | **the only model key needed to start** (orchestrator + workers both Kimi) |
| 🟡 Codex key | `OPENAI_API_KEY` | platform.openai.com | **Phase 2 only.** Assumes OpenAI Codex — confirm provider before then |

## 2. Agent framework / harness (🔴 — decided: native Hermes roles)
The role layer (orchestrator + game-pm + game-art + eng/qa/release) runs as **native Hermes role-agents** (system prompt + tools per role), parallelized with native **`git worktree`**. **No extra credential** — roles drive Kimi/Codex via the keys in §1. (crewAI / OpenHands remain fallback options, also using §1 keys.)

## 3. Unity (🔴)
| Cred | Var | Where | Notes |
|------|-----|-------|-------|
| 🔴 Unity account + activated license | `UNITY_EMAIL`,`UNITY_PASSWORD`,`UNITY_LICENSE` | unity.com (Personal=free) | **batchmode/CI need an activated license file (.ulf) or serial — not just a login** |
| ✅ Unity MCP (community server) | — | — | free; needs the Editor running |

## 4. Work tracking — Linear (🔴)
| Cred | Var | Where | Notes |
|------|-----|-------|-------|
| 🔴 Linear API key | `LINEAR_API_KEY` | Linear → Settings → API → Personal API key | scope to team **SAA** |

## 5. Comms — Discord (🟡)
| Cred | Var | Where | For |
|------|-----|-------|-----|
| 🟡 Webhook URL | `DISCORD_WEBHOOK_URL` | Channel → Integrations → Webhooks | **L3/L4** post-only feed (no app) |
| 🟡 Bot token | `DISCORD_BOT_TOKEN` | Discord Developer Portal → app → Bot | **L1** two-way channel |
| 🟡 (bot) Message Content intent + invite | — | Dev Portal → Bot → intents; OAuth invite | required for the bot to read replies |

## 6. Art generation — Game Art agent (🟡, from M2)
| Cred | Var | Where | Notes |
|------|-----|-------|-------|
| 🟡 Scenario **or** PixelLab API key | `SCENARIO_API_KEY` / `PIXELLAB_API_KEY` | scenario.gg / pixellab.ai | paid plan; pick one |
| ⚪ TexturePacker license | — | codeandweb.com | free alt: Unity built-in 2D Atlas (✅) |

## 7. Build / CI (🟡)
| Cred | Var | Where | Notes |
|------|-----|-------|-------|
| 🟡 GitHub account + repo | — | github.com | per-run repos, PRs |
| 🟡 GitHub PAT | `GITHUB_TOKEN` | GitHub → Settings → Developer settings | only if agents push/PR |
| 🟡 Unity license secrets (GameCI) | (as §3) | GH Actions secrets | unattended cloud builds at L3/L4 |
| ⚪ Android **release** keystore + passwords | `ANDROID_KEYSTORE*` | you generate | **debug builds need none** — spec is debug-only, skip for v1 |

## 8. Memory — team run (🟡 — OpenViking, replaces GBrain)
Solo run = flat `docs/` (✅ no cred). Team run = **OpenViking** (`viking://` filesystem context DB, self-hosted):
| Item | Var | Notes |
|------|-----|-------|
| 🟡 OpenViking server endpoint | `VIKING_ENDPOINT` | self-host the OSS server (Docker/OpenShift); local = ✅ no key |
| ⚪ OpenViking auth (if server secured) | `VIKING_API_KEY` | only if you put auth in front of it |
| ⚪ Embeddings (if its retrieval needs it) | `OPENAI_API_KEY` | reuses §1; check your OpenViking config |
| ⚪ Volcano Engine creds (managed option) | `VOLC_ACCESSKEY`/`VOLC_SECRETKEY` | only if you use a managed deployment instead of self-host |

## 9. Optional / stretch (⚪)
| Cred | For |
|------|-----|
| Supabase URL+key | only if a memory backend uses it |
| Firebase / GCP service acct | Firebase Test Lab device matrix (local emulator/adb is ✅) |
| LLM judge | reuse §1 keys — no new cred |

## Needs **no** credential (✅)
Unity MCP (community), Android emulator + adb, PlayMode tests, Unity Recorder, bot player, flat-docs memory, Discord webhooks, git worktrees.

---

## `.env.example` (copy into each run repo, fill, never commit)
```dotenv
# Models — Phase 1: Kimi only (required now)
MOONSHOT_API_KEY=
# OPENAI_API_KEY=         # Phase 2 (Codex) — confirm provider; not needed to start

# Unity (required; batchmode/CI)
UNITY_EMAIL=
UNITY_PASSWORD=
UNITY_LICENSE=            # contents of the .ulf, or use serial

# Linear (required)
LINEAR_API_KEY=

# Discord (L3/L4 webhook; L1 bot)
DISCORD_WEBHOOK_URL=
DISCORD_BOT_TOKEN=

# Art gen (M2; pick one)
SCENARIO_API_KEY=
PIXELLAB_API_KEY=

# Build/CI (if pushing / GameCI)
GITHUB_TOKEN=

# Team memory backend (OpenViking, self-hosted)
VIKING_ENDPOINT=          # e.g. http://localhost:8080
VIKING_API_KEY=           # only if server is secured
```

## Quick checklist (minimum to launch a first L1 run, solo config)
- [ ] `MOONSHOT_API_KEY` (Phase 1 = Kimi only; Codex/`OPENAI_API_KEY` deferred to Phase 2)
- [ ] Unity account + **activated** license
- [ ] `LINEAR_API_KEY` (team SAA)
- [ ] `DISCORD_BOT_TOKEN` (L1) **or** `DISCORD_WEBHOOK_URL` (L3/L4)
- [ ] Native Hermes role-agents defined (§2) — pointed at the model keys
- [ ] (Solo run) flat-docs memory — no cred. (Team run) OpenViking server up (§8)
