# architecture-delegation-skill

Durable structural clarity via sub-agent delegation. The lead agent researches,
grills the user, picks a slice, implements conservatively, and verifies with a
reviewer subagent. Code that is easier to navigate, change, test, and predict —
not theoretical purity.

A cross-platform agent skill. Invoke with `/architecture-delegation-skill` in
any tool that reads skills.

## The three-skill stack

This skill is the middle of a deliberate stack of owned skills:

| Skill | Owns | Question |
|-------|------|----------|
| `first-principles-skill` | the **what/why** | "Is this structural change actually right for our constraints?" |
| **`architecture-delegation-skill`** (this) | the **how** | "How do we refactor it safely, in slices, with verification?" |
| `using-git-worktrees-skill` | the **where** | "In an isolated workspace so the current branch is protected." |

A first-principles analysis produces the brief that seeds step 2 (grill the
user) here. This skill does not re-litigate that decision — it takes the
validated conclusion and owns research → slice → implement → verify. The
worktree skill is invoked at step 0 so "commit every phase" (Safety Rail 1) is
trivial.

## The workflow

- **Step 0** — isolate the workspace (worktree)
- **Step 1** — research the codebase (delegate to `explore`; facts only, no recommendations)
- **Step 2** — grill the user on intent / risk / scope / constraints / test posture / urgency (concrete options, batched)
- **Step 3** — inspect; checkpoint "is there a real problem?"
- **Step 4** — identify & classify the issue
- **Step 5** — choose a slice & design the boundary
- **Step 6** — implement conservatively (+ decision notes for risky slices)
- **Step 7** — verify (delegate to `reviewer`)

## Delegation safety rails

1. **Commit at every major step** — never develop in an untracked scratch
   directory (single point of total failure). Cleanest: do the whole refactor in
   a worktree from `using-git-worktrees-skill`.
2. **Gate acceptance on a machine-checkable predicate** — not on a subagent's prose.
3. **Stop-and-ask in every implementer prompt** — implementer models silently
   do whatever's easiest; stopping with the contradiction is success.
4. **Pin target path + test posture** every time.
5. **Re-inject cross-cutting invariants** into every handoff.

## Install

```bash
git clone https://github.com/JavaGT/agent-skills
cd agent-skills/skills/architecture-delegation-skill
./install.sh                 # auto-detect platform
./install.sh --platform opencode
./install.sh --all
```

Or, if you manage skills via the agent-skills repo + `sync-skills.sh`, it is
symlinked into `~/.agents/skills/` automatically (owned skill).

## Sub-agents required

`explore` (read-only discovery), `architect` (judgment, GLM 5.2), `reviewer`
(verification, GLM 5.2), `ds-v4-flash` (implementation), and
`claude-opus-4-8-expensive` (hard-question escalation). If a named model isn't
wired in `opencode.json`, substitute the closest equivalent — don't let model
guidance go inert.

## License

MIT. Adopted into the agent-skills repo from a loose untracked copy.
