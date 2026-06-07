# adr/ — Architecture Decision Records

Formal ADRs for **significant architectural decisions**, written at **major checkpoints** (milestone boundaries M1/M2/M3, or any significant architectural fork).

- **Full process + principles:** `$SPEC_REPO/12-ADR-Process.md` (follow it — Impact column for every option, cons = strictly additional negatives, consequences = downstream only, order by blast radius).
- **Relationship to `docs/decisions.md`:** that file is the running log; at each checkpoint, *promote* the significant architectural decisions into formal ADRs here. Trivial/reversible choices stay in the log.
- **Naming:** `ADR{NNN}-{slug}.md`, numbered by blast radius (most impactful = 001). Keep this README as the index.

## Index
| ADR | Title (decision outcome) | Status |
|-----|--------------------------|--------|
| — | _(none yet — first ADR pass at M1 exit)_ | — |

## Per-ADR template
```markdown
## ADR{NNN}: {Concise title — decision outcome, not just topic}

### Status
{Accepted | Proposed | Deprecated | Superseded by ADR{NNN}}

### Context
{1-2 paragraphs: problem + constraints. Chain to prior ADRs: "Following Option B in ADR001..."}

### Considered Options
| Option | Pros | Cons | Impact |
|--------|------|------|--------|
| {Option A} | {why attractive} | {additional negatives vs the alternative} | {specific files/systems affected} |
| **{Chosen (chosen)}** | {why it wins} | {acknowledged trade-offs} | {same level of detail} |

### Decision
{What we chose and how it works — actual class/method/file names, code snippets.}

### Consequences
- {how it constrains/enables FUTURE decisions}
- {risks that may surface later}
```
