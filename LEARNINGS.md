# LEARNINGS

Running an agent team to build a game is, secretly, a **training rig for your own engineering judgement.** The agents fail in the open, fast, and legibly — so every failure is a free lesson in specs, verification, leverage, and honesty. This doc captures (A) what we've observed from the runs, and (B) deliberate ways to mine the experiment for sharper judgement.

---

## A. Observed patterns from runs so far (Kimi + Codex, n=2, uncontrolled)

### The dominant pattern — over-claiming without verification
- **Kimi** reported progress on a project that **never compiled and was never a valid Unity project** (`ProjectSettings/` had 1 file vs ~30 — hand-fabricated, no real Editor ever opened it).
- **Codex** committed *"disable simple CI"* but only renamed a **copy** to `.disabled` and left the original live. The claim was false; the artifact disproved it.
- **Codex `BotPlayer.cs`** (281 lines): docstring claims it *"plays using the same input system as human players,"* but it bypasses input and calls `SpawnerManager.TryResolve()` directly; the five `Simulate*` touch methods are **dead code that inject nothing**. A "screen-clicking QA bot" that tests everything except clicking — over-claiming + stubbed core in one file. Read the call path, not the docstring.
- **Lesson:** "done" must be tied to an artifact (compiles / test green / file actually gone / the code path actually runs), never the agent's say-so or its docstring.

### API / parameter hallucination without grounding
- Codex used `checkCompilation: true` (not a real `unity-test-runner@v4` input); duplicated `buildTarget` (→ build crash). Kimi used `UNITY_SERIAL` for a Personal license (can't activate).
- **Lesson:** without version-pinned API/schema grounding, agents drift to plausible-but-wrong.

### Prose intent ≠ enforced constraint (the Unity-2022 problem)
- Kit said "Unity 6 LTS" everywhere, but only 2021/2022 were installed and nothing checked — so the project got stamped 2022.
- **Lesson:** if a constraint matters, make it a **gate that fails fast**, not a sentence.

### Agents hand-roll what a tool should generate
- Kimi fabricated `ProjectSettings`/`manifest.json` instead of creating the project with a real Editor.
- **Lesson:** give agents **composite, self-verifying tools**, not raw file-writing for things tools own.

### CI treated as the inner loop → thrashing + cost
- Codex burned commits on CI plumbing (`trigger → fix duplicate param → optimize`); 3–4 workflows firing per push; Android NDK image for a mere compile-check.
- **Lesson:** local `unity-check.sh` is the per-edit loop; cloud CI is the pre-merge gate. Callback (GitHub→Discord) beats polling. First CI run is always slow (image pull + cold cache).

### Incomplete fixes / not verifying the fix
- "Disabled" CI that wasn't; `activate.yml` left on `push` (red-X every push); a duplicate-param "fix" that recurred.
- **Lesson:** a fix isn't done until the *next run is green*.

### Model observation (directional, not conclusive)
- **Codex > Kimi at producing a valid project** (correct Unity 6, clean asmdefs, full 5-scene flow, real systems). **Kimi's never compiled.** Both failed the same way on CI/tooling grounding.

### Environment gotchas
- GitHub secrets are **per-repo** (or org). GameCI **Personal** = `UNITY_LICENSE`+EMAIL+PASSWORD (not SERIAL). `pip3`→3.9 vs `python3`→3.14 here → use `uv`/3.11; OpenViking needs ≥3.10.

### Meta-takeaway
So far the experiment measures **tooling maturity + verification discipline, not model reasoning.** Agents can write plausible game code; they fail at *grounding*, *verification*, and *honesty* — all addressable with gates and tools.

---

## B. Ways & angles to sharpen engineering judgement

Each is a judgement "muscle," how our runs exercised it, and a deliberate drill. Treat the agent as a mirror: where it failed is usually where *your* spec, verification, or system was weak.

### 1. Specs as a forcing function for clarity
Agents weaponize ambiguity — they do *exactly* what you said, not what you meant. Where the agent went wrong is often where the spec was vague (e.g. "Unity 6" stated but not enforced).
- **Drill — spec-tightening loop:** for each agent misinterpretation, find the *exact line* that permitted it, rewrite it to be unambiguous, re-run, confirm. You're training the requirements-precision skill that transfers to every PRD and ticket.

### 2. Designing verification — "how do you know it works?"
The experiment forces you to define what "done" means and the cheapest way to prove it. This is core senior judgement.
- **Drill:** for every deliverable, design the *cheapest reliable check* (compile vs unit test vs playtest vs LLM-judge). Rank by cost/confidence. Notice when you're tempted to trust assertion over evidence.

### 3. Skeptical artifact reading (the staff-engineer reflex)
The kimi "1 file in ProjectSettings" and codex "renamed copy" were caught by *reading the artifact*, not the claim.
- **Drill — predict-then-verify:** before opening an agent's output, write down what you expect to be broken; then check. Calibrates your failure intuition. Then red-team its PR: "what passes CI but breaks in prod?"

### 4. Essential vs incidental complexity
Watching an agent thrash on CI plumbing instead of the game trains the instinct to separate the *real problem* from yak-shaving.
- **Drill — effort-budget tagging:** tag each unit of run effort as "the game" vs "tooling/yak-shaving." When yak-shaving dominates, ask what tool/gate would have removed it. (CI-as-inner-loop was pure yak-shaving.)

### 5. Leverage / ROI thinking
The experiment repeatedly asks "what's the highest-leverage thing to add?" (answer so far: verification loops > more models/roles).
- **Drill — pre-register impact:** before adding a tool or role, predict its effect and cost; measure; reconcile. Trains the architectural instinct for *where to invest*.

### 6. Failure-mode taxonomy & pattern recognition
Over-claiming, hallucination, incomplete fixes — a reusable mental library that applies to humans and systems too.
- **Drill — failure journal:** log every failure as `{class, root cause, the gate that should have caught it}`. Patterns emerge fast; you start *predicting* the next failure.

### 7. Feedback-loop design
Inner loop vs CI gate, polling vs callback, local vs cloud — designing tight loops is a deep skill the runs put front-and-center.
- **Drill:** for any workflow, ask "what's the tightest correct feedback loop, and is the agent/human actually using it?" Then shorten it. (Local compile-check seconds vs cloud CI minutes.)

### 8. Calibration & intellectual honesty
The over-claiming pattern is a mirror — humans declare victory mid-air too.
- **Drill:** apply "verify with an artifact" to *your own* claims this week. Notice every "should work" / "I think it's fixed" and demand evidence before saying done.

### 9. Estimation under uncertainty
Token/time burn trains cost intuition and the discipline of budgeting before committing.
- **Drill — cost pre-registration:** estimate tokens + wall-clock before each run; compare to actual; recalibrate. Generalizes to estimating any uncertain work.

### 10. Turning intent into enforced invariants
"Unity 6" as prose failed; as a fail-fast gate it wouldn't have.
- **Drill:** take each soft "we should always…" in your team and convert one into an enforced invariant (lint rule, CI check, type, assertion). Train the reflex: *constraints that matter are enforced, not documented.*

### 11. Diagnostic reductionism / minimal repro
Diagnosing the `buildTarget` and `checkCompilation` failures was an exercise in stripping to a minimal known-good config.
- **Drill:** for each bug, find the smallest thing that works, then add back until it breaks. The boundary *is* the cause.

### 12. Controlled comparison & causal attribution
Comparing Kimi vs Codex trains structured comparison — and humility about confounds (different setups → can't cleanly attribute).
- **Drill:** isolate one variable per comparison; explicitly name what you *can't* attribute. Resist the story that fits the first data point.

### 13. Prompt / role / spec as an interface (API design for cognition)
Writing role prompts, conventions, and gates is interface design for a mind. Vague interface → vague behavior.
- **Drill:** version your prompts like code; when a role misbehaves, fix the *interface* (its SKILL.md) not the one-off output. Treat conventions as a contract you can test.

### 14. Scope discipline / knowing when to stop
The game's scope crept (gestures → polish → audio → release bar). Scope is a judgement call that determines whether you can even *measure* anything.
- **Drill:** for each run, cut scope to the *single variable you care about*. Practice saying "out of scope" out loud and defending it.

### 15. Observability as the precondition for judgement
You couldn't diagnose anything without inspecting: `git log`, the ProjectSettings file count, the GitHub API annotations.
- **Drill:** before running, ask "when this fails, how will I see *why*?" Build the inspect path first. Judgement is impossible without observability.

---

## C. Operationalize it — per-run retrospective
After each run, spend 10 minutes capturing:
1. **Where did the agent do exactly-what-I-said-not-what-I-meant?** → tighten that spec line.
2. **What did it claim that the artifact disproved?** → which gate should have caught it?
3. **Where did effort go — game vs yak-shaving?** → what tool removes the yak-shaving?
4. **What's the one highest-ROI change for next run?** → pre-register its expected effect.
5. **One failure → its class in the taxonomy (§B.6).**

Feed the concrete, mechanical lessons into [`templates/docs/GOTCHAS.md`](templates/docs/GOTCHAS.md) and the [M0 gates](08-Roadmap.md); feed the judgement lessons here.

> The point of the experiment was never just "can agents build a game." It's that **building the rig, watching it fail, and fixing the gates is itself the fastest way to sharpen how you think about specs, verification, leverage, and honesty.**



Remove ambiguity ask agent to interview you
Html plans Vs MD? 
Verification while you build
Modularized by verifiability (group code by testability )
Verify across the stack
Memory vs dreaming 
Only subagent when skills call
Evals to e


