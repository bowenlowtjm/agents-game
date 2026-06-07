# ADR Process

**When:** at every **major checkpoint** (milestone boundary M1/M2/M3, or any significant architectural fork), capture the *significant architectural* decisions made since the last checkpoint as formal **Architecture Decision Records** in the run repo's **`adr/`** folder.

**Relationship to `docs/decisions.md`:** `docs/decisions.md` is the lightweight *running log* (ADR-lite, append-as-you-go). At a checkpoint, **promote** the significant architectural decisions from that log into formal ADRs here. Not every line in `decisions.md` becomes an ADR — only decisions with real blast radius (see ordering). Trivial/easily-reversible choices stay in the log.

**File naming:** `adr/ADR{NNN}-{slug}.md` (e.g. `adr/ADR001-data-driven-ruleset.md`), plus an `adr/README.md` index. Number by blast radius (most impactful first).

---

Generate Architecture Decision Records from a branch diff, RFC page, or design conversation.

## Input Sources (pick one or more)

1. **Branch** — diff against main to extract what decisions were made
2. **RFC / Confluence page** — extract decisions from a design document
3. **Conversation context** — decisions made during current discussion

## Process

### Step 1: Identify Decisions

Scan the input for architectural choices. A decision exists wherever:
- Multiple implementation approaches were possible
- A trade-off was made (simplicity vs correctness, blast radius vs uniformity, etc.)
- Stakeholders/repos are impacted differently
- Deployment ordering or migration strategy was chosen

### Step 2: For Each Decision — Explore the Codebase

Before writing the ADR, explore the codebase to ground the decision in reality:
- Find the actual interfaces, classes, and call sites affected
- Count the real blast radius (e.g., "~32 entities" not "many entities")
- Identify which repos own the affected code
- Verify assumptions about existing patterns
- Understand how migrations are generated and applied (don't assume — check the actual mechanism)

### Step 3: Write the Document

Start with a summary header before any individual ADRs:

```markdown
# ADR: {Title}

{One-line description of what this ADR set covers.}

**Key decision:** {One paragraph describing the most impactful decision — what it chose, what it rejected, and why. Highlight the trade-off, not just the outcome.}
```

This lets readers grasp the most important architectural choice at a glance before diving into individual ADRs.

### Step 4: Write Each ADR

Use this format:

```markdown
## ADR{NNN}: {Concise title — decision outcome, not just topic}

### Status

{Accepted | Proposed | Deprecated | Superseded by ADR{NNN}}

### Context

{1-2 paragraphs: What problem are we solving? What constraints exist?
If this follows from a prior ADR, state it explicitly: "Following Option B in ADR001..."}

### Considered Options

| Option | Pros | Cons | Impact |
|--------|------|------|--------|
| {Option A} | {Why it's attractive} | {Additional negatives beyond the alternative} | {Walk through specific endpoints, services, files affected} |
| **{Chosen option (chosen)}** | {Why it wins} | {Acknowledged trade-offs} | {Same level of detail} |

### Decision

{What we chose and how it works. Include code snippets, actual column names, actual method names. Be specific enough that a developer can implement from this.}

### Consequences

- {How this constrains or enables future decisions}
- {Risks that may surface later}
```

## Key Principles

### Context Must Be Self-Contained
- A reader unfamiliar with the project should understand the problem after reading just the context
- State what preceding decision this ADR follows from — chain decisions explicitly
- Don't repeat project background from earlier ADRs — reference it

### Consistent Terminology
- Define a canonical term for the key concept early in the document (e.g., "user display label" / `user_display_label`)
- Use that term consistently throughout all ADRs instead of synonyms
- State the definition once at the top: what the term means, what value it holds

### Specificity Over Abstraction
- Name actual classes, files, endpoints, column names
- Give real counts ("~89 call sites", not "many places")
- Reference actual repos and team ownership
- Use exact column names (`created_by_name`), not patterns (`*_by_name`)

### Impact Column in Options Table
Every option (including non-chosen) must walk through the specific endpoints, services, and files affected. The reader should understand what implementation would look like for *every* option.
- If different storage targets have different cost profiles (e.g., single audit table vs. 34 entity tables), split Impact into multiple columns
- If an option has no impact on a particular service, omit that service — don't write "N/A"

### Cons Are Strictly Additional Negatives
- A con must be something that is **worse** than the alternative — not a neutral before/after difference
- "Requires implementing X" is NOT a con if the alternative also requires implementing something equivalent
- Ask: "Would this concern disappear if we chose a different option?" If yes, it's a con. If it applies to all options, it's not.

### Consequences Are Downstream Only
Consequences describe how this decision constrains or enables **future** decisions. They do NOT:
- List immediate implementation tasks (those belong in the Impact column)
- Restate what was chosen (that's in the Decision section)

Good: "Formula divergence across .NET and Java becomes a consistency risk for any future changes."
Bad: "We will add 68 columns to the database." (immediate change — belongs in Impact)

### Honest Trade-offs
- The chosen option MUST have a Cons column entry
- Rejected options MUST have a Pros column entry
- No option is all-good or all-bad

### Ordering Reflects Blast Radius
- ADRs ordered from highest blast radius to lowest
- "Blast radius" = the delta between the chosen option and the rejected options. A decision where the alternatives would have led to drastically different architectures ranks higher than one where all options were similar in scope.
- Decisions with the largest consequence-of-being-wrong come first
- Within same importance: earlier decisions that are foundations for later ones come first

### Migration Details
When an ADR involves schema changes, document:
- How the migration is generated (e.g., `dotnet ef migrations add`, Alembic `revision`)
- How it's applied at deployment (init container, startup hook, manual step)
- Whether the framework provides run-once tracking (EF `__EFMigrationsHistory`, Alembic `alembic_version`) or if idempotency must be designed in
- Data volume unknowns and their impact on execution time
- Air-gap / upgrade-path considerations (can a system upgrading from v1.0 to v3.0 still run this migration?)

### Merge Sequential Decisions
- If Decision B is a direct consequence of Decision A (e.g., "where to put fields" + "how to populate those same fields"), merge them into one ADR
- Split only when decisions are independently reversible

## Anti-Patterns

- **Vague titles**: "Database changes" → should be "Add user_display_label columns to all IAuditedEntity2 entities via single EF migration"
- **Missing stakeholders**: If 4 repos are affected, all 4 must appear in Impact
- **No cons for chosen option**: Every decision has downsides — state them
- **Neutral differences listed as cons**: "Requires 89 assignments" is only a con if the alternative requires fewer
- **Implementation plan disguised as ADR**: ADRs record *why*, not *how to deploy step by step*
- **Overly long Context**: Context sets up the decision, not the entire project background
- **Assuming infrastructure**: Don't write "run the migration" without documenting the actual mechanism (init container? K8s Job? startup hook?)
- **Only detailing the chosen option**: Non-chosen options deserve equal implementation detail in the Impact column so the reader understands *why* they were rejected, not just *that* they were

## Verification Checklist

After generating ADRs, verify:
- [ ] Summary highlights the most impactful decision and its trade-off (not a numbered list of all ADRs)
- [ ] Each ADR title states the decision outcome (not just the topic)
- [ ] Context is self-contained and chains to prior ADRs where applicable
- [ ] All options (including non-chosen) have implementation detail in the Impact column
- [ ] Cons are strictly additional negatives, not neutral differences
- [ ] Chosen option's Cons acknowledge real trade-offs
- [ ] Consequences describe only downstream/future impact, not immediate changes
- [ ] ADRs are numbered by blast radius (most impactful first)
- [ ] Sequential decisions are merged where appropriate
- [ ] Code snippets use actual names (columns, methods, files)
- [ ] Migration mechanisms are documented (how generated, how applied, run-once tracking)

---

## Pully-specific notes
- **Checkpoints that warrant an ADR pass:** M1 exit (core-loop architecture: input/gesture recognition, ruleset data model, scoring), M2 exit (scene/prefab structure, art/atlas pipeline, persistence), M3 exit (determinism/replay, balance config), and any mid-milestone architectural fork.
- **Likely Pully ADRs:** data-driven ruleset SO vs hardcoded mapping; gesture recognition approach; deterministic seeded spawn; 3D-engine/2D-sprite rendering choice; memory backend (flat-docs vs OpenViking); local Builder.cs vs GameCI build paths.
- **Migration Details section** rarely applies to Pully (no DB) — use it only if a save-format/PlayerPrefs schema change needs an upgrade path; otherwise omit.
- At **L3/L4**, the agent writes ADRs unprompted at each checkpoint and posts the `adr/` summary to Discord as a significant change. At **L1**, the human reviews the ADR set at the checkpoint.
