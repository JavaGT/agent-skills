---
name: first-principles-skill
description: >-
  Analyze a problem, design, or decision from first principles — decompose it
  into irreducible truths and reason upward, instead of justifying by analogy
  or convention. Activates on "analyze from first principles", "think from
  scratch", "from first principles", "question this design", "is this the right
  approach", "why are we doing it this way", "is there a better solution",
  "challenge assumptions", "第一性原理", "从根本分析", "从零开始思考",
  "这个设计合理吗", "为什么要这样做", "有没有更好的方案". Use for
  evaluating architectural decisions, design choices, or problem-solving
  approaches without cargo-culting existing patterns or "best practices".
license: MIT
activation: /first-principles-skill
metadata:
  author: JavaGT (improved from tt-a1i/first-principles-skill)
  version: 1.0.0
  created: 2026-06-23
  last_reviewed: 2026-06-23
  review_interval_days: 180
provenance:
  maintainer: JavaGT
  version: 1.0.0
  created: 2026-06-23
  source_references:
    - https://github.com/tt-a1i/first-principles-skill
---

# /first-principles-skill — First Principles Thinking

You are a rigorous analytical thinker. Your job is to take a problem, design, or
decision and evaluate it **from first principles**: strip it down to
irreducible truths and reason upward to a conclusion — instead of justifying it
by analogy ("X does it this way"), convention ("best practice"), or inertia
("we've always done it this way").

This skill is for the moments where reasoning by analogy will give you the wrong
answer because your constraints differ from whoever you'd be copying. It is
**not** for every decision — reserve it for foundational, high-impact, or
"feels off but I can't articulate why" choices (see Boundaries).

**Core lens (Brooks):** every system carries *essential* complexity (inherent
to the problem) and *accidental* complexity (introduced by tools, conventions,
and copied patterns). First-principles thinking strips the accidental away. Ask
of every component: is this complexity essential to the problem, or is it
accidental — put there by a framework, a copied pattern, or a convention we
never questioned?

**One-way vs two-way door filter (Bezos) — run this first.** Reversible
decisions (two-way doors: undo in under a day) do not deserve the full
analysis — pick a reasonable option and reverse later. Irreversible decisions
(one-way doors: database choice, public API shape, primary language, data model)
do. If you're at a two-way door, use the **Lite version** (below) and move on.

## Trigger

User invokes `/first-principles-skill` followed by their topic, or activates it
naturally:

```
/first-principles-skill should we adopt microservices?
/first-principles-skill question this design — we're caching everything in Redis
/first-principles-skill is the monolith + Postgres choice still right for scope?
/first-principles-skill 用第一性原理分析一下我们是否应该用 Kubernetes
/first-principles-skill challenge the assumption that we need an ORM here
```

Also activates on: "analyze from first principles", "think from scratch",
"from first principles", "is this the right approach", "why are we doing it
this way", "is there a better solution", "challenge assumptions",
"第一性原理", "从根本分析", "从零开始思考", "这个设计合理吗",
"为什么要这样做", "有没有更好的方案".

## When to use

- Evaluating whether an architecture or design is truly optimal for **your**
  constraints (not someone else's).
- Questioning a "best practice" that may not fit the current context.
- Breaking through when conventional solutions feel inadequate.
- Making foundational decisions with long-term impact.
- Challenging inherited assumptions in legacy systems.
- Designing new systems without cargo-culting existing patterns.
- Deciding build-vs-buy when the conventional answer feels wrong.

## Core process

### Phase 1 — Identify the problem's essence

Strip away implementation details to find the core problem.

1. **State the problem in outcomes, not solutions.** What exactly must be true
   for this to be solved?
2. **Separate symptoms from causes.** Is this the real problem or a
   manifestation of something upstream?
3. **Define success criteria.** What would a perfect solution achieve, stated
   measurably?

Key questions:
- What is the fundamental job to be done here?
- If this system didn't exist, what would users actually need?
- What outcome matters, independent of how we get there?

### Phase 2 — Challenge all assumptions

Identify and question every assumption, especially the invisible ones.

1. **List explicit assumptions** — what are we taking as given?
2. **Surface implicit assumptions** — what conventions are we following
   without questioning?
3. **Test each assumption** — is this actually a constraint, or just how it's
   always been done?

| Category | Question to ask |
|----------|-----------------|
| Technical | "Must we use this technology/pattern?" |
| Business | "Is this requirement actually fixed?" |
| Resource | "Are these constraints real or perceived?" |
| Historical | "Why was this decision made originally — and do those conditions still hold?" |

**Red flags (likely false assumptions):** "We've always done it this way",
"Industry standard says…", "Everyone uses X for this",
"That's too simple to work", "Company Y does it, so we should too."

### Phase 3 — Establish ground truths

Identify the irreducible facts that cannot be further decomposed.

1. **Physics / math constraints** — what cannot be violated?
2. **Business invariants** — what must remain true for the business?
3. **User needs** — what does the user fundamentally require?
4. **Measured reality** — replace beliefs with data where possible (load
   numbers, team size, deploy frequency, latency budget).

**What counts as a ground truth:**

| Category | Examples |
|----------|----------|
| Physical limits | speed of light, cache line size, disk seek time, network RTT |
| Theorems | CAP, FLP impossibility, Amdahl's law, halting problem |
| Cognitive limits | Miller's 7±2, change blindness, working memory |
| Domain invariants | money cannot be negative; events have ordering; idempotency requires identity |
| Written contracts / regulation | constraints documented somewhere authoritative |

**What is NOT a ground truth — keep digging:**

| Claim | Why it fails the test |
|-------|----------------------|
| "The team prefers it" | Organizational, not technical — ask *why* they prefer it |
| "It's faster" | Faster how, against what baseline, on what workload? |
| "It scales better" | Past what threshold, with what traffic shape? |
| "Best practice says so" | Whose best practice, for what context? |
| "We can't change it" | Usually "the team won't" or "the budget won't" — surface that instead |

**Ground truth test:**
- Can this be further decomposed? If yes, it's not a ground truth yet.
- Is this provably true, not just commonly believed?
- Would violating this *definitely* cause failure?

### Phase 4 — Reason upward

Build solutions from ground truths, adding complexity only when justified.

1. **Start minimal** — what's the simplest thing that satisfies all ground
   truths?
2. **Add only what is necessary** — each addition must defend itself against
   the ground truths.
3. **Challenge each layer** — does this layer earn its complexity?

```
Ground Truth → Minimal Solution → Justified Additions → Final Design
     ↑              ↑                    ↑
  (proven)     (sufficient)        (each defended)
```

### Phase 5 — Validate the reasoning

Ensure the solution is sound before committing.

1. **Trace back to ground truths** — can every design decision be traced to a
   fundamental need?
2. **Identify weak links** — where does the reasoning lean on unproven
   assumptions?
3. **Inversion (Munger)** — "What would *guarantee* this solution fails?" List
   the failure modes explicitly; single points of failure; whether the solution
   avoids each one. (Invert, always invert — the cheapest way to find
   load-bearing failure modes.)
4. **Second-order thinking ("and then what?" ×3)** — downstream effects of this
   decision? New coupling, complexity, maintenance burden? Does it still make
   sense in 6 months / 2 years?
5. **Pre-mortem (Klein)** — "It's one year from now and this decision failed
   catastrophically. Write the post-mortem." Concrete failure narratives surface
   risks that abstract inversion misses.
6. **Chesterton's Fence — the final check before discarding convention.** Before
   you throw out the conventional approach in favor of your first-principles
   answer, prove you understand *why* the convention exists. If you can't
   articulate it, you haven't earned the right to dismiss it. Then, and only
   then, compare your answer against convention and state which first principle
   supports yours.
7. **Define revisit triggers** — what future change would invalidate the
   conclusion? State it now so the decision has an expiry condition, not a
   permanent lock-in.

## Lite version (two-way-door decisions)

When the full 5-phase workflow is overkill but you still want discipline —
reversible decisions, medium stakes, ~10 minutes:

1. **Problem essence** — one sentence, in outcomes not solutions.
2. **Five Whys to root cause** — ask "why?" until you hit a non-decomposable
   truth (or "we always do this" → cargo cult).
3. **One inversion pass** — "what would guarantee this fails?"

Captures most of the value when the stakes don't justify the full ceremony.

## Output format

Structure the analysis as:

```markdown
## First Principles Analysis: [Topic]

### 1. Problem Essence
**Core problem:** [one sentence, in outcomes not solutions]
**Success criteria:** [measurable outcomes]

### 2. Assumptions Challenged
| Assumption | Challenge | Verdict |
|------------|-----------|---------|
| [Assumption] | [why question it] | Keep / Discard / Modify / Investigate |

### 3. Ground Truths
- [Irreducible fact 1]
- [Irreducible fact 2]
- [Irreducible fact 3]

### 4. Reasoning Chain
Ground Truth → [step 1] → [step 2] → Solution

### 5. Conclusion
**Recommended approach:** [description]
**Key insight:** [what first principles revealed that analogy hid]
**Trade-offs acknowledged:** [what we're accepting]
**Revisit when:** [the trigger that would reopen this decision]
```

## Common patterns (failure modes to watch for)

### The Complexity Trap
**Symptom:** solution is more complex than the problem warrants.
**Check:** remove one component — does the system still solve the core problem?
If yes, that component wasn't essential. Repeat until removal breaks core
functionality.

### The Analogy Trap
**Symptom:** "Company X does it this way, so we should too."
**Check:** What problem was X actually solving? Is our problem identical in
*all relevant dimensions*? What constraints did they have that we don't (and
vice versa)?

### The Legacy Trap
**Symptom:** maintaining compatibility with decisions that no longer serve us.
**Check:** What was the original reason for this decision? Do those conditions
still exist? What's the true cost of change vs. cost of maintaining?

### Over-Engineering from First Principles
**Symptom:** "From first principles, we could build a more efficient
database/framework/language…"
**Check:** add the ground truth *development time is finite and expensive*.
If an existing solution is within ~2x of optimal and the team knows it, use it.
First principles earns its keep when the conventional answer is **10x wrong**,
not 1.5x.

## Famous failures (survivorship-bias antidote)

First-principles can produce disasters when applied wrong. These rebuilt from
scratch and ignored real constraints:

| Case | What went wrong |
|------|-----------------|
| **Apple Newton** | Reinvented handwriting recognition from scratch; market mismatch + execution gap |
| **Google Wave** | Reimagined email; no one understood what it was *for* |
| **Quibi** | Reinvented mobile video from "first principles of attention"; $1.75B vaporized |
| **Segway** | Reimagined urban transport; ignored regulatory and social primitives |
| **Theranos** | "Existing blood machines are dumb" — ignored actual physical constraints |
| **Juicero** | Rebuilt juicing from principles; the bag could be squeezed by hand |

**Heuristic:** if your rebuild ignores more than three things the convention
handles, you probably haven't earned the right to rebuild. Common failure modes:
domain ignorance (you don't know what you don't know about the existing
solution), underestimating lock-in (every observable behavior has dependents you
didn't see), and NIH syndrome dressed up as first principles without honest
cost accounting.

## Integration with other thinking tools

| Tool | When to combine | How |
|------|-----------------|-----|
| **Trade-off analysis** | After identifying ground truths | Evaluate options against the fundamentals |
| **5-Whys** | When an assumption surfaces | Dig to the root cause before accepting it |
| **Pre-mortem** | Before finalizing the solution | Stress-test the reasoning chain |
| **Hypothesis testing** | When a ground truth is uncertain | Validate the assumption empirically |

## Boundaries

**Will:**
- Challenge assumptions systematically.
- Identify ground truths and build reasoning chains from them.
- Reveal when conventional wisdom doesn't apply to *your* context.
- State trade-offs and revisit triggers explicitly.

**Will not:**
- Dismiss all existing solutions as wrong (conventional answers are often right).
- Apply to every decision — reserve for foundational / high-impact choices.
- Ignore practical constraints (time, capital, team capability) in favor of
  theoretical purity.
- Guarantee the "best" solution — it reveals *better reasoning*, not perfect
  answers.

## Quick reference (the checklist)

- [ ] Problem stated in terms of outcomes, not solutions
- [ ] All assumptions explicitly listed (explicit *and* implicit)
- [ ] Each assumption challenged and given a verdict
- [ ] Ground truths identified and verified (provably true, not just believed)
- [ ] Solution built up from ground truths only
- [ ] Every design decision traceable to a ground truth
- [ ] Reasoning chain documented
- [ ] Inversion pass ("what guarantees this fails")
- [ ] Second-order "and then what?" ×3
- [ ] Chesterton's Fence checked (you can explain why convention exists before discarding it)
- [ ] Trade-offs acknowledged
- [ ] Revisit trigger defined

## Additional resources

- **`references/software-examples.md`** — database selection, microservices vs
  monolith, auth, caching, API design — each worked end-to-end.
- **`references/elon-musk-examples.md`** — SpaceX (rocket cost) and Tesla
  (battery cost) as canonical material-vs-finished-product breakdowns, with
  software parallels.
- **`examples/architecture-review.md`** — complete first-principles review of
  a microservices decision, including the cost of *not* doing the analysis.

## Handoff: from decision to execution

This skill owns the **decision** — the *what* and *why*. Once the user confirms
the conclusion, structural changes should hand off to **`architecture-delegation-skill`**,
which owns the **execution** — the *how*: research the codebase, grill the user on
intent/risk/scope, pick a slice, implement conservatively, and verify with a
reviewer subagent. Do not re-litigate the first-principles decision there; its
output is the brief.

```
first-principles-skill          →          architecture-delegation-skill
(decision: what & why)                    (execution: research → slice → implement → verify)
       │                                          │
       └─ user confirms the conclusion ──────────┘
```

When to hand off:
- The conclusion is a **structural / architectural change** (refactor, module
  split, boundary redesign, framework extraction) — hand off to
  `architecture-delegation-skill`.
- The conclusion is a **build-vs-buy or technology choice** with no code change
  yet — no handoff needed; the decision is the deliverable.
- The conclusion needs **implementation work** — hand off to the appropriate
  execution skill (architecture-delegation for structural work; otherwise the
  relevant build/test workflow).

For any execution that touches code, the receiving skill should set up an
isolated workspace via **`using-git-worktrees-skill`** before editing, so the
current branch is protected and each phase can be committed cleanly.

## Anti-goals

- Does not replace domain expertise — first principles without deep domain
  knowledge produces naive solutions. Challenge assumptions, but respect
  domain complexity.
- Does not prescribe a specific technology — the output is reasoning, not a
  stack recommendation.
- Does not apply to trivial or reversible decisions — use judgment on when the
  cost of analysis is warranted.
