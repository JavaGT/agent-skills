# using-git-worktrees-skill

Create an isolated git worktree before feature work that needs isolation —
detect existing isolation first, prefer native harness tools, fall back to
`git worktree add`, then **make the worktree actually runnable** (copy env,
install or symlink deps) and **merge it back cleanly when done**.

A cross-platform agent skill. Invoke with `/using-git-worktrees-skill` in any
tool that reads skills.

## Why this exists

The popular `obra/superpowers:using-git-worktrees` skill gets the detection +
native-tool flow right. It skips what makes worktrees painful in practice:

- A fresh worktree has no `.env` — the app crashes on first run.
- Deps aren't installed — `npm install` from scratch every time.
- There's no merge-back story — worktrees accumulate and disks fill.

This owned skill absorbs those gaps (env-copy + dep-symlink + metadata +
merge-back, kept scriptless) so it can be edited in-repo without touching the
obra submodule.

## The 5 steps

0. **Detect existing isolation** — run first, always. Avoid nesting; guard
   against the submodule false-positive.
1. **Create the workspace** — native tool preferred (`EnterWorktree` /
   `/worktree` / `--worktree`), else `git worktree add` fallback into
   `.worktrees/` (verify gitignored).
2. **Record metadata** — base branch + creation time, so merge-back is
   unambiguous.
3. **Make it runnable** — copy env/secret files from the source worktree
   (`.env`, `.envrc`, `credentials.json`, never `.env.example`); then
   symlink heavy build dirs (`node_modules`/`target`/`.next`) **or** install
   fresh.
4. **Verify a clean baseline** — run tests so new bugs are distinguishable
   from pre-existing ones.
5. **Merge back & clean up** — merge into the base branch, remove the
   worktree, prune.

## Install

```bash
git clone https://github.com/JavaGT/agent-skills
cd agent-skills/skills/using-git-worktrees-skill
./install.sh                 # auto-detect platform
./install.sh --platform opencode
./install.sh --all
```

Or, if you manage skills via the agent-skills repo + `sync-skills.sh`, it is
symlinked into `~/.agents/skills/` automatically (owned skill).

### Manual

```bash
ln -s "$(pwd)" ~/.agents/skills/using-git-worktrees-skill   # OpenCode / universal
ln -s "$(pwd)" ~/.claude/skills/using-git-worktrees-skill   # Claude Code
```

## Usage

```
/using-git-worktrees-skill feature/payment-split
/using-git-worktrees-skill set up an isolated workspace for the auth refactor
/using-git-worktrees-skill spin up a worktree for PR 1234
```

## The two things to remember

1. **Step 3 is the part most worktree skills skip.** A fresh worktree has no
   `.env` and no deps. Copy env from the source worktree, then symlink heavy
   build dirs or install fresh.
2. **Every worktree you create should end in Step 5.** Merge into base, remove
   the worktree, prune. Otherwise worktrees accumulate and disks fill.

## Boundaries

Will not replace a native worktree session manager (Grove, forestui, crow,
factoryfloor) — those are apps. This is a skill. Will not `direnv allow`
without asking (it runs code). Will not `git worktree remove --force` a dirty
worktree without user confirmation.

## Provenance

Supersedes `obra/superpowers:using-git-worktrees` (detection + native-tool flow
preserved in Steps 0–1). Env-copy, dep-symlink, and metadata ideas adapted
from `marioxe301/super-worktree`, kept scriptless. MIT.
