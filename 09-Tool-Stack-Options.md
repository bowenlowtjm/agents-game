# Tool-Stack Options

Beyond the decided core (Unity + Unity MCP + Hermes native role-agents + Linear + OpenViking), here are the stacks worth considering, by job. Pick one per row and hold constant within a comparison. **No Claude Code / gstack** (dropped).

## 1. 2D sprite / art generation (for the Game Art agent)
| Tool | Strength | Notes |
|------|----------|-------|
| **Scenario.gg** | game-asset-tuned models, sprite sheets, style-locked | API; best for consistent game art |
| **Layer.ai** | game art pipeline, style consistency | team/asset-oriented |
| **PixelLab** | pixel-art sprites + animation, has API/MCP | great if Pully goes pixel |
| **Retro Diffusion** | pixel-art SD model | cheap, local-friendly |
| **Recraft / Ideogram** | clean vector + crisp shapes/UI | good for flat shape targets + icons |
| **GPT-image / Midjourney / SDXL+ControlNet** | general, high quality | needs style-locking effort |
| **TexturePacker** | atlas packing (not generation) | deterministic, agent-callable CLI |
**Lean:** Scenario or PixelLab for sprites (style consistency + API the agent can call) + TexturePacker CLI for atlasing. Style captured in `DESIGN.md`.

## 2. Audio (optional, post-v1)
| Tool | For |
|------|-----|
| **ElevenLabs SFX** | tap/hit/miss/combo sound effects (API) |
| **Suno / Udio / Sonauto** | background loop |
| Unity built-in / freesound | zero-cost placeholder |

## 3. Build & CI
| Tool | For |
|------|-----|
| **Unity batchmode (`Builder.cs`)** | local agent-callable APK — default |
| **GameCI (`game-ci/unity-builder`)** | cloud Unity builds via GitHub Actions; no local Editor needed; great for unattended L3/L4 |
| **Unity Build Automation / DevOps** | managed cloud builds (first-party) |
| **Fastlane** | Android signing/packaging automation |

## 4. Device / play testing
| Tool | For |
|------|-----|
| **Android emulator (AVD)** | agent-driven install + launch, local |
| **Firebase Test Lab** | real-device matrix in cloud |
| **Unity PlayMode tests** | in-engine gesture sim + assertions |
| **adb** | install/launch/log scrape, fully scriptable |

## 5. Gameplay-quality measurement (see [Metrics §C](07-Metrics-and-Evaluation.md#c-gameplay-quality-the-new-headline-metric))
| Tool | For |
|------|-----|
| **Bot player** (scripted/agent) | seeded sessions → score/FPS/latency logs |
| **Unity Recorder** | capture 20s gameplay video/frames for the judge |
| **LLM-as-judge** (Claude/GPT vision) | rate readability + feel on a fixed rubric |
| **GameAnalytics / Unity Analytics** | telemetry if you want live funnels later |

## 6. Orchestration / harness (context — Hermes is chosen)
| Tool | Note |
|------|------|
| **Hermes native role-agents + `git worktree`** | chosen: harness roles + parallel worktrees, no Claude Code |
| crewAI / LangGraph / AutoGen | if you want a dedicated multi-agent framework over Hermes |
| OpenHands | model-agnostic autonomous coding agent (single strong agent) |

## 7. Work tracking (context — Linear is chosen)
| Tool | Note |
|------|------|
| **Linear (SAA) + Linear MCP** | chosen: backlog + autonomy-gating state machine |
| **GitHub Issues/Projects** | alt if you want issues next to code |

## 8. Agent memory backends
Decided pairing: **flat `docs/` for the solo run**, **OpenViking for the team run** (see [Architecture › Memory](04-Agent-Team-Architecture.md#memory)). Alternatives if they underperform:

| Backend | Memory model | Best for | Notes |
|---------|-------------|----------|-------|
| **flat `docs/`** *(chosen, solo)* | human-readable markdown (ADR + GOTCHAS + run-log) | transparency, single agent, auditability | zero infra; you can read exactly what the agent "knows" |
| **OpenViking** *(chosen, team)* | `viking://` filesystem context DB, tiered L0/L1/L2, self-evolving | shared across parallel role worktrees | ByteDance/Volcano Engine OSS; self-host; model-agnostic; filesystem paradigm extends flat-docs |
| **Mem0** | 3-tier (user/session/agent), hybrid vector+graph+KV | drop-in personalization memory | biggest community; graph features gated behind Pro; SOC2/HIPAA |
| **Zep** (Graphiti) | temporal knowledge graph w/ fact-validity windows | "what was true when" / temporal queries | strongest temporal-retrieval benchmarks; async summarization |
| **Letta** (ex-MemGPT) | OS-style memory hierarchy; agent self-manages context | **long-running, multi-day autonomous** agents | most relevant to L4 — agent decides what to keep |
| **Cognee** | GraphRAG over many docs | "why did we choose X over Y" across a doc corpus | local, zero cloud cost; good for decisions traceability |
| **Supermemory / LangMem** | managed / LangChain-native memory | quick managed start / LangChain stacks | LangMem only if you adopt LangChain |
| **MCP `memory` server** | knowledge-graph store over MCP | tool-native, framework-agnostic | first-party reference server; easy to bolt onto Hermes |
| **Vector store** (Chroma, Qdrant, Weaviate, pgvector) | raw embeddings retrieval | DIY episodic recall | you build the memory *policy* on top |
| **Claude memory tool + context editing** | model-native memory files + auto context pruning | keeping long agent runs in-budget | complements, not replaces, a project store |

**Worth testing here:** **Letta** for L4 autonomous runs (agent-managed memory is exactly the autonomy question), and **Zep** if repeated-mistake avoidance ("last time the build failed because…") proves to be the dominant failure mode.

## Minimal recommended starting set
Unity 6 + official Unity MCP + Hermes native role-agents + `git worktree` + Linear MCP + OpenViking (team) + **Scenario (sprites) + TexturePacker** + **batchmode build (→ GameCI for L3/L4)** + **emulator/adb + PlayMode tests + Unity Recorder + LLM judge**. Add audio and Firebase Test Lab only after v1 ships.
