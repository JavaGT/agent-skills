---
name: architecture-delegation-skill
description: >-
  Use when improving code architecture, modularity, responsibility allocation,
  or delegating architecture review and refactoring to sub-agents. Trigger on
  refactor, restructure, reorganize, or split modules; improve module
  boundaries, coupling, cohesion, or separation of concerns; extract
  components, move logic between layers, consolidate duplicated domain rules,
  or fix framework leakage; review abstractions (SRP, Open-Closed,
  Tell-Don't-Ask, ports and adapters); or plan an incremental structural
  change. Also use when a user says "the code is messy", "this file does too
  much", "where should this go", "tight coupling", "clean architecture", or
  asks to delegate a hard refactoring. Do not use for tiny local edits,
  formatting, or dead-code removal (use tidy-up instead). Pairs with
  first-principles-skill (the decision) and using-git-worktrees-skill (the
  isolated workspace).
license: MIT
activation: /architecture-delegation-skill
compatibility: Requires sub-agents architect (planning, GLM 5.2), reviewer (verification, GLM 5.2), ds-v4-flash (implementation, DeepSeek V4 Flash), claude-opus-4-8-expensive (hard-question escalation, Opus 4.8), and explore (read-only discovery). Lead needs read/glob/grep/bash/edit permissions.
metadata:
  author: JavaGT (adopted into agent-skills repo; origin unknown — was a loose untracked copy)
  short-description: Architecture refactoring workflow with sub-agent delegation
  default-subagent: explore
  recommended-temperature: 0.2
  version: 1.0.0
  created: 2026-06-23
  last_reviewed: 2026-06-23
  review_interval_days: 180
provenance:
  maintainer: JavaGT
  version: 1.0.0
  created: 2026-06-23
  source_references:
    - https://github.com/JavaGT/agent-skills  # adopted from a loose untracked copy
---

# /architecture-delegation-skill — Architecture Delegation

The goal is durable clarity: code that is easier to navigate, easier to change, harder to misuse, less duplicated, more testable, and more predictable for future developers. Not theoretical purity.

## Operating Mode

You are the lead architecture agent. You may edit code directly. Sub-agents are helpers, not decision makers — use them for bounded investigations, focused critique, and verification. The lead owns final judgment, edits, and explanation.

**The lead always decides.** You may override any subagent recommendation with a one-line note on why; subagent disagreement is information, not a veto. This includes a reviewer's "Revert" verdict — it is advisory, treated like any other recommendation.

**Risky slice (defined once, referenced below):** one that touches state, persistence, realtime, auth, or public APIs, or spans 5+ modules. Risky slices require decision notes (step 6), warrant a stronger reasoning model for `architect`, and may warrant escalation to the user.

**Workspace isolation:** before any editing phase, do the work in an isolated git worktree so the current branch is protected and each phase can be committed cleanly (see Delegation Safety Rail 1). Use the **`using-git-worktrees-skill`** — it detects existing isolation, copies env/secret files, and handles merge-back. If a worktree is impractical (sandbox denial, read-only mount), at minimum commit the current state before editing and proceed in place.

**Relationship to first-principles-skill:** when a structural change originates from a first-principles analysis, this skill takes the validated conclusion (the *what/why*) and owns the *how* — research the codebase, grill the user on intent/risk/scope, pick a slice, implement conservatively, verify. Do not re-litigate the first-principles decision; treat its output as the brief for step 2.

## Model & Subagent Configuration

### Defaults by task type

- **Read-only discovery** (mapping structure, finding imports, locating tests): `explore` — faster and cheaper. Most architecture work begins here.
- **Judgment work** (responsibility analysis, abstraction review, boundary design): `architect` with your strongest reasoning model, high thinking.
- **Implementation** (mechanical edits, well-understood moves): lead edits directly, or `ds-v4-flash` for execution-heavy batches.
- **Verification** (reviewing completed edits): `reviewer` — see Workflow step 7.

### Model recommendations (verify availability)

Names below are recommendations, not assumptions. If a named model isn't wired in `opencode.json`, substitute your closest equivalent — don't let model guidance go inert.

- Judgment/architecture (default): `pioneer/glm-5.2` via the `architect` agent — a good model for planning, responsibility analysis, and boundary design.
- Hard questions (escalation): `pioneer/claude-opus-4-8-160k` via the `claude-opus-4-8-expensive` agent — reserve for genuinely contentious decisions, risky slices, or when 3+ design principles are in tension.
- Implementation/writing: `pioneer/deepseek-v4-flash` via the `ds-v4-flash` agent — an okay model for mechanical edits and execution-heavy batches.
- Review/verification: `pioneer/glm-5.2` via the `reviewer` agent — a good model; review checks conformance to requirements, not novel design.

Configure agents as: `architect` = `pioneer/glm-5.2-160k` with read/glob/grep/bash/edit permission; `reviewer` = `pioneer/glm-5.2`, read/glob/grep/bash only; `ds-v4-flash` = `pioneer/deepseek-v4-flash` with edit permission for implementation. If no `reviewer` is configured, spawn a `ds-v4-flash` task with the reviewer prompt in Templates.

### When to escalate to Opus 4.8

`architect` defaults to GLM 5.2 — a good model that handles most planning, responsibility analysis, and boundary design. Escalate genuinely hard questions to the `claude-opus-4-8-expensive` subagent (Opus 4.8) when: the slice is risky (see definition above); 3+ design principles are in tension; you are designing boundaries for a new subsystem; or prior `architect` recommendations were shallow, inconsistent, or missed coupling risks. Do not escalate routine refactors — GLM 5.2 is sufficient and Opus 4.8 is expensive. Use standard (non-escalated) judgment for purely mechanical moves already decided, or when speed matters more than correctness (emergency hotfix).

### Parallel orchestration and cost control

Launch independent sub-agents simultaneously. Prefer cheap `explore` for parallel read-only work; reserve `architect` (high thinking) for the judgment passes that consume that output.

```
Parallel investigation (explore, read-only):
  Task 1 (explore): "Map all mutation flows in src/orders/"
  Task 2 (explore): "Find every place that reads the orders store directly from a UI component"
  Task 3 (explore): "List all files importing from src/stores/ that are not component files"

Divide and conquer (architect, judgment — for large codebases partition by module):
  Task 1 (architect): "Analyze responsibility allocation in src/orders/"
  Task 2 (architect): "Analyze responsibility allocation in src/billing/"
  Task 3 (architect): "Analyze responsibility allocation in src/server/"

Verify in parallel (after edits):
  Task 1 (reviewer): "Check edits in src/orders/ against requirements and decision notes"
  Task 2 (explore): "Find any remaining imports of the old module path"
  Task 3 (ds-v4-flash): "Run typecheck and report any new errors"
```

Never launch dependent sub-agents simultaneously — sequence those.

**Cost spiral guard:** If a single refactor chains more than three delegate→synthesize rounds, stop. Summarize what's been found and the open questions to the user, and ask whether to continue. Open-ended chaining bloats the lead's context past the point of useful judgment.

## Delegation Safety Rails

These rails are non-negotiable for any multi-phase delegated build. They are distilled from real failures where an implementer subagent wrote to the wrong directory, silently ignored constraints, and a full workbench port was lost to `rm -rf` because it was never committed. Each rail prevents a class of failure that manual review caught too late or not at all.

1. **Commit at every major step.** Before dispatching the next phase, the lead runs `git add -A && git commit -m "phase N: <what landed>"`. Never develop in an untracked scratch directory — it is a single point of total failure. If a scratch dir is unavoidable, `git add -f` it immediately so it is recoverable. (A weeks-old untracked port was once `rm -rf`'d and had to be reconstructed lossily from conversation history.) The clean way to satisfy this rail is to run the whole refactor inside an isolated worktree created by **`using-git-worktrees-skill`** before step 1 — then "commit at every phase" is just working normally in the worktree, and merge-back is a defined final step instead of a risky manual cleanup.

2. **Gate acceptance on a machine-checkable predicate — never trust prose.** After each handoff returns, the lead runs a tool predicate (file exists with expected exports/line count; typecheck clean for touched files) before committing and dispatching the next phase. Acceptance is based on what the tools say landed, **not** on the subagent's summary.

3. **Stop-and-ask trigger in every implementer prompt.** Implementer models have near-zero initiative to raise contradictions — they silently do whatever is easiest. The prompt must instruct: STOP and return a question (do not guess) when a required field has no source, the target path is ambiguous, instructions conflict with the code or each other, or a blocker appears. Listing the contradiction and stopping is success; guessing past it is failure.

4. **Pin the target path and test posture explicitly, every time.** State the exact canonical file to write (and forbid scratch paths), and whether the subagent writes tests. Wrong-directory writes and tests-written-when-forbidden (and vice-versa) recur when these are left implicit.

5. **Re-inject cross-cutting invariants into every handoff.** A constraint stated once in phase 0 is invisible to a subagent dispatched in phase 5. Paste the active invariants (naming choices, opt-in defaults, type distinctions) into every phase prompt, or encode them as a check the lead runs after each phase. (Two invariants once rotted across handoffs and resurfaced across 64 and 35 call sites respectively.)

## Recovering Lost Work

If delegated work must be recovered from conversation history (e.g. an uncommitted file was deleted):

- **Prefer a single full-read snapshot** of the file's final state — it is self-consistent and reliable.
- **Avoid replaying a sequence of edits** — deltas accumulate corruption: duplicate blocks, reversed edits, and reasoning-trace contamination. In practice edit-replay produced oversized, duplicated, wrong-import files while one full snapshot worked first try.
- The real fix is rail 1: this situation should not arise if you commit per step.

## Design Principles

Use these as lenses, not commandments:

- SRP, Separation of Concerns, high cohesion/low coupling, information hiding, functional core/imperative shell, dependency inversion, ports and adapters, command/query separation, DDD, least astonishment.
- Open-Closed: extension shouldn't require modifying existing code.
- Stable / Acyclic Dependencies: dependencies point toward the stable modules and form no cycles.
- Tell, Don't Ask: behavior lives with the data it acts on.
- Interface Segregation: narrow, client-specific interfaces.

Signals of good architecture: each module has a clear purpose; the common case is simple; advanced behavior stays possible through explicit options; defaults are sensible; APIs are small, predictable, hard to misuse; business rules aren't duplicated across layers; state has a clear source of truth; data flow is understandable; tests target meaningful units without excessive setup; new developers can guess where functionality belongs; files colocate with what uses them; features own their folders, not type buckets; nesting is shallow; module edges change slower than internals; tests exercise behavior, not implementation details; one act per test; tests target public API surface; tests are fast and deterministic.

## Required Workflow

This is the spine. Steps 1–2 are mandatory before any analysis or editing.

**Step 0 (before step 1, if any editing is anticipated): isolate the workspace.** If the slice may reach the editing phase, set up an isolated worktree via **`using-git-worktrees-skill`** now — it copies env, installs/symlinks deps, and records the base branch for merge-back. This makes Safety Rail 1 (commit every phase) trivial and protects the current branch. Skip step 0 only for pure read-only analysis with no planned edits, or when a worktree is impossible (sandbox denial).

### 1. Research the Codebase

Before forming any opinion, delegate read-only research to `explore` (parallel tasks if the area is large) to gather facts, not judgments. Map: the target area's file tree, entry points, public APIs and their callers, data flow, state ownership, side effects, tests covering the area, naming conventions, and any existing architectural patterns. Read the project's README/AGENTS/conventions docs if present. Role: **Code Cartographer** (`explore`).

Output a short fact sheet only — no recommendations yet:
```md
Area: ...
Structure:
- ...
Public APIs and callers:
- ...
Data flow / state ownership:
- ...
Tests covering this area:
- ...
Conventions / patterns observed:
- ...
Unknowns to resolve with the user:
- ...
```

If you skip this and start analyzing from assumption, you will misclassify problems and propose moves that break flows you never saw. Research is cheap (`explore`); redoing a wrong refactor is not.

### 2. Grill the User

Architecture decisions are easy to get wrong by guessing intent. Before proposing any refactor, ask the user targeted questions about the areas the research surfaced as unknowns — and about intent, risk, and constraints. Use the `question` tool with concrete options (not open-ended). Ask in one batched call where possible.

Cover at minimum:

- **Intent** — structural cleanup, feature-enabling refactor, perf fix, or testability fix? Different intents pick different slices.
- **Risk tolerance** — may public contracts, DB schema, or runtime behavior change, or must behavior be preserved exactly? (This sets the bar for steps 5–7.)
- **Scope boundary** — which modules/files are in bounds and which are off-limits this pass.
- **Constraints** — framework lock-in, deploy/release cadence, migration windows, anything that bounds the design.
- **Test posture** — is there test infrastructure to lean on, or is this a low-test repo where the slice must add tests first? (See step 7, low-test directive.)
- **Urgency** — emergency hotfix (skip deep analysis) or durable work (full workflow)?

**Contract-questions pass (boundaries first).** For any slice touching state, persistence, realtime, or a client/server split, settle the *boundary* decisions now — these are the questions that, deferred, erupt mid-implementation as blockers and force late escalation. Seed examples: transaction ownership (how does a DB tx relate to an app/unit-of-work tx?); registry split (where do shared specs live so the client doesn't import server code?); where dispatch-time IDs live (on the request, the entity, or both?); opt-in defaults (does X persist when its flag is null, and is the flag wired on every case?); single vs dual ingest path (do echoed and pushed events share one reducer path?). Run this as a planning pass, not a post-hoc review.

Do not ask questions the research already answered — that wastes the user's attention. Do not ask vague questions ("what do you want?") — offer concrete options derived from the fact sheet. If a question's answer would not change which slice you pick, drop it.

Synthesize the answers into a one-paragraph brief: intent, risk tolerance, scope, constraints, test posture, urgency. This brief is the input to step 3.

### 3. Inspect Before Acting

Fill any remaining gaps the research+grill brief left open (more `explore` if needed, or inspect directly for small areas). Do not assume a file is bad because it is large — large files are only a problem when they mix responsibilities or make change risky.

**Checkpoint — is there a real problem?** Ask: is the code hard to change? is behavior duplicated? is ownership unclear? are bugs likely from current structure? is testing unnecessarily difficult? is the API easy to misuse? is data flow unclear? **If no, do not refactor.**

### 4. Identify & Classify

Role: **Responsibility Analyst** (`architect`, high thinking — shallow analysis produces false positives). Ask: what concept does this code actually belong to? what module should own it? is it pure computation, orchestration, UI, persistence, validation, or side effect management? is the module doing more than one job? is this abstraction easier to use than what it wraps? does the name describe the domain concept or only the implementation? would a new developer know where to add related behavior?

Look for these smells, then classify the underlying issue: abstract factories/managers/registries/service layers/adapters that simplify nothing; vague `utils`/`common`/`misc`/`helpers` modules holding domain-specific code; splitting files only because they're large; moving code without improving ownership; abstractions for hypothetical future use; hiding complexity behind generic wrappers; multiple modules owning the same responsibility; UI code containing business rules; domain code depending on framework/database/browser/network APIs without a strong reason; duplicated logic between client and server; manual synchronization between parallel state structures when derived state would be safer; mutation paths that bypass the canonical flow; "Clean Architecture" cosplay that adds ceremony without improving the code; deep folder nesting; type-bucket folders that scatter a single domain across the tree; bad names like `utils/process-items.ts`, `helpers/data.ts`, `common/logic.ts` (better: `orders/line-item-pricing.ts`, `billing/apply-discount.ts`).

Classify as one of: misplaced responsibility; wrong abstraction; missing abstraction; duplicated domain rule; confusing state ownership; framework leakage; overloaded module; poor API ergonomics; weak test boundary; unclear naming; unnecessary indirection; missing boundary between pure logic and side effects. If you cannot classify it, inspect more before editing.

### 5. Choose Slice & Design Boundary

Pick the most valuable small slice. Good slices: move pure logic into a domain module; extract orchestration from computation; replace duplicated behavior with one domain-specific function; move UI-independent logic out of a component; give a vague helper a domain-specific home and name; consolidate state ownership; replace manual synchronization with derived state where safe; make a mutation path use the canonical pipeline; simplify an API so the common case has sensible defaults; add focused tests around extracted behavior. Bad slices: reorganizing folders without behavior or ownership clarity; creating a generic abstraction before real use cases exist; introducing a new architecture style across the whole project; renaming many things for aesthetics; combining unrelated cleanup with architecture changes. Do not combine unrelated boundary changes.

Before editing, decide: what module owns the behavior? what is its public API? what stays private? what dependencies point inward vs. stay at the edge? what defaults does the API provide? what advanced options remain possible? what tests prove the behavior still works? A good boundary makes the easy path obvious and the wrong path harder.

**Abstraction checkpoint — should this be abstracted?** Only create an abstraction if at least one is true: multiple real callers; hides a volatile external dependency; gives a simpler API to complex behavior; protects domain logic from framework/persistence details; removes meaningful duplication; encodes a stable domain concept. Do **not** create if: one trivial caller; only forwards arguments; makes names more generic; hides important behavior; exists only for "we might need it later"; creates a `manager`/`service`/`helper`/`utils` without a clear domain name. Run the Anti-Abstraction Checklist (below) before extracting.

**Flow Tracer** (`architect`, high thinking) — use when changing mutation paths, state flow, data loading, persistence, or realtime. Trace one specific flow end to end. Output:
```md
Flow:
1. ...
2. ...
Sources of truth:
- ...
Side effects:
- ...
Places behavior could diverge:
- ...
Risky assumptions:
- ...
```

**Is this safe to implement?** Implement directly if the slice is small, behavior is easy to preserve, tests/checks can verify it, and the ownership improvement is clear. Implement only a first slice if the issue is broad, multiple flows are involved, dependencies are uncertain, or a full rewrite would be risky. Escalate to the user or a stronger model if the slice is risky (see definition above) and you cannot confidently verify correctness.

### 6. Implement Conservatively

Preserve existing behavior unless intentionally changing it. Keep changes scoped to the selected slice. Follow existing code style and project patterns. Prefer domain-specific names; avoid vague `utils` modules and unnecessary dependencies. Keep public APIs simple. Add or update tests when behavior moves or risk increases. Do not perform unrelated cleanup.

**Decision notes.** Alongside the edit, write notes: what changed, what was preserved, and any judgment calls. For **risky slices** (see definition above) notes are **required** — the reviewer depends on them. For trivial slices that won't get a reviewer, notes are skippable.

### 7. Verify (delegated)

Do not verify alone unless the slice is trivial. Delegate to a `reviewer` agent (good coding model; GLM 5.2 is the default). Feed the reviewer: the slice's requirements/acceptance criteria, the decision notes from step 6, and the files/flows to check.

Ask the reviewer to check **both**: conformance (does the edit meet requirements and preserve behavior?) and decisions (were the judgment calls in the notes sound? flag any that look wrong, even if the code passes).

Relevant checks to request as available: typecheck, unit tests for affected code, broader suite if practical, lint if the project uses it. If checks fail, fix failures caused by the change; report unrelated failures clearly.

**Test Scout** (`explore` default, or `architect` when coverage-gap strategy needs judgment) — find existing/missing tests, best place to add, minimal tests for confidence, manual checks if automated tests are weak.

**Reviewer** (`reviewer`) — verifies completed edits and the decisions behind them: behavior preservation against requirements, conformance to the agreed boundary/API, whether the decision notes' judgment calls hold up, new coupling, naming clarity, missed tests, accidental broad refactors, whether the change actually improved ownership. Output:
```md
Review findings:
- Severity:
  File:
  Issue:
  Suggested fix:
Decision-notes review:
- Decision: ... Verdict: sound / questionable / wrong — ...
Verdict: Accept / Revise / Revert this slice
```

**Low-test-repo directive.** If the codebase has little or no test infrastructure, do not let that excuse skipping verification. Prioritize adding tests as part of the slice before further refactoring — the reviewer's "missed tests" finding then points at concrete additions, not a vacuum. For the immediate slice, request typecheck + a manual-repro checklist the lead writes (expected inputs/outputs for the changed behavior) and have the reviewer confirm against it.

## API Design Rules

Make the common case easy; sensible defaults; minimal required params; named options for advanced behavior; prefer domain names over technical names; return structured results not ambiguous booleans; don't expose internal state or require callers to know implementation details; make invalid states hard to represent; keep side effects obvious from function name or module location.

JS/TS: types are a design tool, not paperwork — encode invariants, avoid `any` and loose `as` casts; prefer narrow/branded types for IDs and domain primitives (don't mix `userId` with `orderId`); prefer discriminated unions over optional fields (`{ ok: true; value } | { ok: false; error }` not `value?`); pure functions by default with side effects at the edges; avoid premature `class` (functions/modules suffice unless there's state or polymorphism); barrel files (`index.ts` re-exports) sparingly and only at true public boundaries — they hide structure and break tree-shaking; co-locate types with their module, not in a global `types.ts`.

```ts
createLineItem({
  orderId,
  productId,
  quantity,
  unitPrice
});
```

## Anti-Abstraction Checklist

Before creating a new abstraction, answer:

```md
Abstraction name:
Purpose:
Real callers:
Complexity hidden:
Duplication removed:
Domain concept represented:
Why inline code is worse:
How this could become a junk drawer:
Decision:
```

If you cannot answer these clearly, do not create the abstraction.

## Delegation System

Do not delegate vague tasks. Each sub-agent task must have: a narrow scope, specific files or flows to inspect, a concrete question, and a required output format. Never ask a sub-agent to make broad architectural decisions alone.

Delegate when: you're unsure where a responsibility belongs; the code path spans more than three important files; the slice is risky (see definition above); you're about to create a new abstraction; there may be duplicated domain logic; you need to understand an unfamiliar module; the change is large enough that review would help; verification would benefit from an independent check.

Do not delegate when: the change is tiny and local; you already inspected the relevant code; a sub-agent would only repeat obvious information; the task is purely mechanical; the issue is urgent and the safe fix is clear.

## Templates

### Sub-Agent Handoff (investigation)

```md
Task: Inspect [specific files/flow] for [specific architectural concern].
Context: We are considering [possible change].
Questions: 1. ... 2. ... 3. ...
Return: Findings, evidence, risks, recommendation.
Do not: Make broad recommendations, refactor code, analyze unrelated files.
```

### Implementer Handoff (writing code)

Carries the Delegation Safety Rails into the prompt:

```md
Task: Implement [slice] in [exact canonical path] — write ONLY there, NEVER a scratch dir.
Tests: you [do / do NOT] write tests.
Invariants still in force (do not drift): [naming choices, opt-in defaults, type distinctions].
Stop-and-ask (do NOT silently comply): STOP and return a question instead of guessing if
  a required field has no source, the target path is ambiguous, instructions conflict with
  the code or each other, or you hit a blocker. Stopping with the contradiction is success.
Return: the edits made + which files/exports landed.
```

After it returns, the lead runs the acceptance predicate (file/exports present, typecheck clean for touched files), then commits before the next phase.

### Reviewer Handoff

```md
Task: Verify edits in [files] against the requirements below.
Requirements: [acceptance criteria for the slice]
Decision notes from implementer:
- What changed: ...
- What was preserved: ...
- Judgment calls: ...
Checks: [typecheck / tests / lint as available]
Return: Conformance findings, decision-notes review, verdict (Accept/Revise/Revert).
```

### Before implementation (refactoring slice plan)

Write a brief plan: selected slice, problem it solves, current vs new allocation, files to change, behavior preservation strategy, verification approach (including who reviews and whether notes are required).

### After sub-agents report back

Synthesize concisely: what was found, what you decided, what you will change, what you will not change, and risks. The lead decides; note overrides in one line.

### After completing work

Report compactly: architecture findings, what changed, why it is better, verification results (reviewer verdict + checks), remaining risks. Lead with outcome, not process recap.
