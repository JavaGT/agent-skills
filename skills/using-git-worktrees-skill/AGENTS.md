# using-git-worktrees-skill

## Purpose

Create an isolated git worktree before feature work that needs isolation from
the current workspace, or before executing a multi-step implementation plan.
Detects existing isolation first, prefers native harness tools, falls back to
`git worktree add`, then makes the worktree actually runnable (env + deps) and
remembers how to merge it back.

## When to activate

- "create a worktree" / "set up an isolated workspace" / "spin up a worktree
  for <branch>"
- "start feature work in isolation"
- Before executing a multi-step implementation plan where an untracked scratch
  directory would be a single point of total failure
- Checking out a PR into an isolated tree for review

Do **not** activate for one-line edits, 5-minute hotfixes, or changes where
isolation adds ceremony without value.

## How to use

Open `SKILL.md` in this directory. Five steps:

0. **Detect existing isolation** (run first, always — avoid nesting; submodule guard)
1. **Create the workspace** (native tool preferred → `git worktree add` fallback)
2. **Record metadata** (base branch + creation time, for merge-back)
3. **Make it runnable** — copy env/secret files from source; symlink or install deps
4. **Verify a clean baseline** (run tests so new bugs are distinguishable)
5. **Merge back & clean up** (merge into base, remove worktree, prune)

## The two things to remember

1. **Step 3 is the part most worktree skills skip** — a fresh worktree has no
   `.env` and no deps. Copy env from the source worktree, then symlink heavy
   build dirs (`node_modules`/`target`/`.next`) or install fresh.
2. **Every worktree you create should end in Step 5** — merge into base, remove
   the worktree, prune. Otherwise worktrees accumulate and disks fill.

## Why this exists (supersedes obra/superpowers)

The obra `using-git-worktrees` skill has the detection + native-tool flow
right (Steps 0–1 here preserve it). It skips what makes worktrees painful in
practice: env files don't come along, deps aren't installed, and there's no
merge-back story. This owned skill absorbs those (env-copy + dep-symlink +
metadata + merge-back, kept scriptless) so it can be edited in-repo without
touching the obra submodule.

## License

MIT. Supersedes `obra/superpowers:using-git-worktrees`; env-copy / symlink /
metadata ideas adapted from `marioxe301/super-worktree`.
