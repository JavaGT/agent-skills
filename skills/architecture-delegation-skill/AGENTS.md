# architecture-delegation-skill

## Purpose

Durable structural clarity via sub-agent delegation: the lead agent researches,
grills the user, picks a slice, implements conservatively, and verifies with a
reviewer subagent. Not theoretical purity — code that is easier to navigate,
change, test, and predict.

## When to activate

- "refactor" / "restructure" / "reorganize" / "split modules"
- "the code is messy" / "this file does too much" / "where should this go"
- "tight coupling" / "clean architecture" / boundary / cohesion / SRP
- Delegating a hard refactoring to a sub-agent
- Planning an incremental structural change

Do **not** activate for tiny local edits, formatting, or dead-code removal — use
`tidy-up` instead.

## How it fits with the other owned skills

- **`first-principles-skill`** owns the *what/why*: it confirms a structural
  decision with the user via a first-principles analysis. Its output is the
  brief that seeds step 2 (grill the user) here. This skill does not re-litigate
  that decision.
- **`architecture-delegation-skill`** (this one) owns the *how*: research →
  grill → slice → implement → verify.
- **`using-git-worktrees-skill`** owns the *where*: an isolated workspace so
  "commit every phase" (Safety Rail 1) is trivial and the current branch is
  protected. Step 0 of the workflow sets this up before any editing.

## How to use

Open `SKILL.md`. The spine:

- **Step 0** — isolate the workspace (worktree)
- **Step 1** — research the codebase (delegate to `explore`; facts only)
- **Step 2** — grill the user on intent / risk / scope / constraints (concrete
  options, batched)
- **Step 3** — inspect; checkpoint "is there a real problem?"
- **Step 4** — identify & classify the issue
- **Step 5** — choose a slice & design the boundary
- **Step 6** — implement conservatively (+ decision notes for risky slices)
- **Step 7** — verify (delegate to `reviewer`)

Plus: Delegation Safety Rails (commit every phase; tool-predicate acceptance;
stop-and-ask in implementer prompts; pin target path + test posture; re-inject
invariants), Anti-Abstraction Checklist, API design rules, and templates for
sub-agent / implementer / reviewer handoffs.

## Sub-agents required

`explore` (read-only discovery), `architect` (judgment, GLM 5.2),
`reviewer` (verification, GLM 5.2), `ds-v4-flash` (implementation),
`claude-opus-4-8-expensive` (hard-question escalation). If a named model isn't
wired in `opencode.json`, substitute the closest equivalent.

## License

MIT. Adopted into the agent-skills repo from a loose untracked copy.