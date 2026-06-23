---
name: using-git-worktrees-skill
description: >-
  Create an isolated git worktree before starting feature work that needs
  isolation from the current workspace, or before executing an implementation
  plan. Detects existing isolation first, prefers native harness worktree
  tools, falls back to `git worktree add`. Beyond obra/superpowers: copies
  env/secret files into the new worktree, optionally symlinks heavy build
  dirs (node_modules / target / .next) to skip reinstall, records base-branch
  metadata for clean merge-back, and defines the merge-back + cleanup steps.
  Activates on "create a worktree", "set up an isolated workspace",
  "spin up a worktree for <branch>", "start feature work in isolation", or
  before executing a multi-step implementation plan that would benefit from
  isolation.
license: MIT
activation: /using-git-worktrees-skill
metadata:
  author: JavaGT (supersedes obra/superpowers:using-git-worktrees)
  version: 1.0.0
  created: 2026-06-23
  last_reviewed: 2026-06-23
  review_interval_days: 180
provenance:
  maintainer: JavaGT
  version: 1.0.0
  created: 2026-06-23
  source_references:
    - https://github.com/obra/superpowers  # original detection + native-tool flow
    - https://github.com/marioxe301/super-worktree  # env-copy + symlink + metadata ideas
---

# /using-git-worktrees-skill — Isolated Workspaces

Ensure work happens in an isolated workspace before risky or long-running
feature work. Prefer your platform's native worktree tool. Fall back to
manual `git worktree add` only when no native tool exists. Then — the part
most worktree skills skip — make the worktree actually runnable (env files,
deps) and remember how to merge it back and clean up.

**Core principle:** Detect existing isolation first. Then use native tools.
Then fall back to git. Never fight the harness. Never hand the user a
worktree that can't build because `.env` didn't come along.

**Announce at start:** "I'm using the using-git-worktrees-skill to set up an
isolated workspace."

## When to use

- Starting feature work that would clutter or conflict with the current branch.
- Before executing a multi-step implementation plan (especially delegated
  refactors) where an untracked scratch directory is a single point of total
  failure.
- Parallel work on multiple branches without stashing.
- Checking out a PR into an isolated tree for review.

Do **not** use for: a one-line edit, a hotfix you'll ship in 5 minutes, or any
change where isolation adds ceremony without value.

## Trigger

```
/using-git-worktrees-skill feature/payment-split
/using-git-worktrees-skill set up an isolated workspace for the auth refactor
/using-git-worktrees-skill spin up a worktree for PR 1234
```

Also activates on: "create a worktree", "set up an isolated workspace",
"start feature work in isolation", "spin up a worktree for <branch>", or when
an implementation plan is about to start and isolation would protect the
current branch.

## Step 0 — Detect existing isolation (run first, always)

Before creating anything, check whether you are already in an isolated
workspace. Creating a nested worktree is the #1 mistake.

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

**Submodule guard:** `GIT_DIR != GIT_COMMON` is also true inside git
submodules. Verify you are not in a submodule before concluding "already in a
worktree":

```bash
# If this prints a path, you're in a submodule, not a worktree — treat as normal repo
git rev-parse --show-superproject-working-tree 2>/dev/null
```

- **If `GIT_DIR != GIT_COMMON` (and not a submodule):** already in a linked
  worktree. Skip to Step 3 (Make it runnable). Do NOT create another worktree.
  Report: "Already in isolated workspace at `<path>` on branch `<name>`."
  (Detached HEAD → "externally managed; branch creation needed at finish
  time.")
- **If `GIT_DIR == GIT_COMMON` (or in a submodule):** normal repo checkout.
  Has the user declared a worktree preference in instructions? If not, ask
  consent: "Would you like me to set up an isolated worktree? It protects
  your current branch." Honor any declared preference without asking. If the
  user declines, work in place and skip to Step 3.

## Step 1 — Create the isolated workspace

Two mechanisms, tried in this order.

### 1a. Native worktree tool (preferred)

Do you have a harness tool named like `EnterWorktree`, `WorktreeCreate`, a
`/worktree` command, or a `--worktree` flag? If yes, **use it** and skip to
Step 3. Native tools handle directory placement, branch creation, and
cleanup automatically. Using `git worktree add` when a native tool exists
creates phantom state your harness can't manage.

Only proceed to 1b if no native tool is available.

### 1b. Git worktree fallback (only when 1a doesn't apply)

#### Directory selection (priority order)

1. Explicit user preference in instructions → use it, don't ask.
2. Existing project-local worktree dir:
   ```bash
   ls -d .worktrees 2>/dev/null   # preferred (hidden)
   ls -d worktrees 2>/dev/null    # alternative
   ```
   If both exist, `.worktrees` wins.
3. Default: `.worktrees/` at project root.

#### Safety verification (project-local dirs only)

**MUST verify the directory is gitignored before creating a worktree in it:**

```bash
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

If **NOT** ignored: add to `.gitignore`, commit, then proceed. This prevents
accidentally committing worktree contents into the repo.

#### Create it

```bash
path="$LOCATION/$BRANCH_NAME"
git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```

**Sandbox fallback:** if `git worktree add` fails with a permission error
(sandbox denial), tell the user the sandbox blocked worktree creation and
you're working in the current directory instead. Then run Step 3 in place.

## Step 2 — Record metadata (so merge-back knows where to return)

Write a tiny metadata file so the merge-back and cleanup steps (Step 5) know
the base branch and creation time. This is the single idea worth taking from
super-worktree's JSON metadata.

```bash
mkdir -p .worktrees/.metadata 2>/dev/null
cat > ".worktrees/.metadata/${BRANCH_NAME}.json" <<EOF
{ "baseBranch": "${BASE_BRANCH:-main}", "createdAt": "$(date -u +%FT%TZ)", "path": "${path}" }
EOF
```

(If you're in a native-tool worktree or a non-`.worktrees` location, skip the
file and just remember the base branch in your report — Step 5 only needs the
base branch, not the file.)

**`BASE_BRANCH`** = the branch you branched from (`git rev-parse
--abbrev-ref HEAD` before creating, or `origin/HEAD`). State it explicitly in
the final report regardless.

## Step 3 — Make it runnable (env + deps)

This is the step most worktree skills skip, and the reason worktrees feel
painful. A fresh worktree has no `.env` and no installed deps.

### 3a. Copy env / secret files from the source worktree

The new worktree needs the same local config the source had. Copy these from
the **source** worktree root (the one you ran `git worktree add` from) into
the new worktree root:

```bash
SRC="<source worktree root>"
DST="<new worktree root>"
for f in .env .envrc .dev.vars \
         .env.* !.env.example !.env.sample !.env.template \
         credentials.json credentials.yml credentials.env \
         auth.json .secrets.* *.key; do
  [ -f "$SRC/$f" ] && cp "$SRC/$f" "$DST/$f"
done
```

Rules:
- **Never** copy `.env.example` / `.env.sample` / `.env.template` — those are
  committed and already in the worktree.
- **Never** copy into git — these files must remain gitignored. Verify with
  `git check-ignore` before copying if unsure.
- If the project uses `direnv`, the user may want `direnv allow` run in the
  new worktree — ask rather than assume (it executes code).

### 3b. Install or link dependencies

Two strategies, in order of preference:

1. **Symlink heavy build dirs from the source worktree** (fast, saves disk):
   ```bash
   for d in node_modules target .next build dist .turbo; do
     [ -d "$SRC/$d" ] && [ ! -e "$DST/$d" ] && ln -s "$SRC/$d" "$DST/$d"
   done
   ```
   Safe for toolchains that don't write into `node_modules` during build
   (most JS/TS projects). **Not safe** for toolchains that mutate the build
   dir per-target (some Rust `target/` setups when cross-compiling) — if
   unsure, install fresh instead.

2. **Install fresh** (safe default) — auto-detect:
   ```bash
   [ -f package.json ] && { [ -f pnpm-lock.yaml ] && pnpm install --frozen-lockfile || npm install; }
   [ -f Cargo.toml ] && cargo build
   [ -f requirements.txt ] && pip install -r requirements.txt
   [ -f pyproject.toml ] && { [ -f poetry.lock ] && poetry install || pip install -e .; }
   [ -f go.mod ] && go mod download
   ```

If you symlinked, skip the install. If you installed fresh, skip the symlink.

## Step 4 — Verify a clean baseline

Run the project's test command to ensure the workspace starts clean —
otherwise you can't distinguish new bugs from pre-existing ones.

```bash
# Detect: package.json "test" script / cargo test / pytest / go test ./...
```

- **Tests fail:** report failures, ask whether to proceed or investigate.
- **Tests pass:** report ready.

## Step 5 — Merge back & clean up (the step obra's skill lacks)

When the feature work is done and verified:

```bash
# From inside the worktree
cd "<new worktree>"
git add -A && git commit -m "feature: <what>"   # if not already committed

# Merge into the base branch
cd "<base worktree>"
git checkout <BASE_BRANCH>
git merge --no-ff <BRANCH_NAME> -m "Merge <BRANCH_NAME>"

# Remove the worktree and its branch
git worktree remove "<new worktree path>"
git branch -d <BRANCH_NAME>      # -d refuses if not merged; safe
git worktree prune               # clean any orphan metadata
```

Read the metadata file from Step 2 to get `BASE_BRANCH` if you recorded it.
If the merge is fast-forward only and you want history, `--no-ff` keeps the
branch topology; drop it for linear history.

**If the worktree is dirty or has uncommitted work when you try to remove
it:** `git worktree remove` will refuse. Either commit first, or, if
abandoning, `git worktree remove --force` (destructive — confirm with the
user first).

## Quick reference

| Situation | Action |
|-----------|--------|
| Already in linked worktree | Skip creation (Step 0) |
| In a submodule | Treat as normal repo (Step 0 guard) |
| Native worktree tool available | Use it (Step 1a), skip to Step 3 |
| No native tool | Git worktree fallback (Step 1b) |
| `.worktrees/` exists | Use it (verify ignored) |
| Both `.worktrees/` and `worktrees/` | Use `.worktrees/` |
| Neither exists | Default `.worktrees/` |
| Dir not ignored | Add to `.gitignore` + commit |
| Permission error on create | Sandbox fallback, work in place |
| New worktree can't build | You skipped Step 3 — copy env, install/symlink deps |
| Tests fail during baseline | Report failures + ask |
| Done with feature | Step 5: merge into base, remove worktree, prune |
| `worktree remove` refuses (dirty) | Commit first, or `--force` after user confirm |

## Common mistakes

### Fighting the harness
- **Problem:** using `git worktree add` when the platform already provides
  isolation.
- **Fix:** Step 0 detects existing isolation; Step 1a defers to native tools.

### Skipping detection
- **Problem:** creating a nested worktree inside an existing one.
- **Fix:** always run Step 0 before creating anything.

### Skipping ignore verification
- **Problem:** worktree contents get tracked, polluting `git status`.
- **Fix:** always `git check-ignore` before creating in a project-local dir.

### Shipping a worktree that can't build
- **Problem:** worktree created, user switched into it, `npm install` fails
  or app crashes on missing `.env`.
- **Fix:** Step 3 is mandatory — copy env files, then symlink or install
  deps. This is the #1 pain worktree skills create by omitting it.

### Symlinking a dir the toolchain mutates
- **Problem:** symlinked `target/` corrupts across cross-compile targets.
- **Fix:** if unsure whether the toolchain writes into the build dir
  per-target, install fresh instead of symlinking.

### Proceeding with failing tests
- **Problem:** can't distinguish new bugs from pre-existing issues.
- **Fix:** report failures, get explicit permission to proceed.

### Abandoning the worktree
- **Problem:** worktrees accumulate, disks fill, branches pile up.
- **Fix:** Step 5 is part of the workflow, not optional. Every worktree you
  create should end in a merge-back + remove.

## Red flags

**Never:**
- Create a worktree when Step 0 detects existing isolation.
- Use `git worktree add` when you have a native worktree tool.
- Skip Step 1a by jumping straight to `git worktree add`.
- Create a worktree without verifying the dir is gitignored.
- Hand the user a worktree without copying env / installing deps (Step 3).
- Skip baseline test verification.
- Proceed with failing tests without asking.
- `git worktree remove --force` without user confirmation when there's
  uncommitted work.

**Always:**
- Run Step 0 detection first.
- Prefer native tools over git fallback.
- Follow directory priority: explicit instructions > existing project-local
  dir > default.
- Verify dir is ignored for project-local.
- Copy env files (Step 3a) — never assume the worktree inherits them.
- Install or symlink deps (Step 3b).
- Verify a clean test baseline.
- Record the base branch (Step 2 / report) so merge-back is unambiguous.
- Finish with merge-back + cleanup (Step 5).

## Boundaries

**Will:**
- Detect existing isolation and avoid nesting.
- Defer to native harness worktree tools when present.
- Make the new worktree runnable (env + deps).
- Verify a clean test baseline.
- Merge back and clean up when the work is done.

**Will not:**
- Force `git worktree add` when a native tool exists.
- Copy `.env.example` or other committed sample files.
- Execute `direnv allow` without asking (it runs code).
- `--force` remove a dirty worktree without user confirmation.
- Replace a real native worktree session manager (Grove, forestui, crow,
  factoryfloor) — those are apps, this is a skill.

## Provenance

Supersedes `obra/superpowers:using-git-worktrees` (detection + native-tool
flow preserved verbatim in Steps 0–1). Absorbs env-copy, dep-symlink, and
metadata ideas from `marioxe301/super-worktree`, kept scriptless. MIT.
