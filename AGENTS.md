# agent-skills

## Purpose

This repo has two jobs:

1. **Publish** owned skills via GitHub Pages at `skills.javagrant.ac.nz`
2. **Source-of-truth** for skills that get symlinked into `~/.agents/skills/` (the
   active skills directory that OpenCode reads)

Skills come from two places:
- **`skills/`** — owned skills, authored here, published to the site
- **`external/<name>/`** — upstream repos pulled in as git submodules; selected
  skills from them are symlinked into `~/.agents/skills/`

## Directory map

```
~/Code/agent-skills/                # this repo (git)
├── skills/                         # owned skills (published to Pages)
│   ├── github-pages-porkbun-skill/ # deploy to Pages + general Porkbun DNS CRUD
│   ├── first-principles-skill/    # first-principles reasoning for design decisions
│   └── using-git-worktrees-skill/  # isolated workspaces (supersedes obra's)
├── external/                       # git submodules (NOT published)
│   ├── mattpocock-skills/          # submodule → github.com/mattpocock/skills
│   └── obra-superpowers/           # submodule → github.com/obra/superpowers
├── skills.manifest                 # declares which upstream skills → symlink
├── scripts/sync-skills.sh          # pulls submodules + refreshes symlinks
├── index.html                      # published site
├── README.md
└── AGENTS.md                       # this file

~/.agents/skills/                   # active skills directory (OpenCode reads this)
├── <owned-or-symlinked-skills>/
├── grill-me →                     # symlink into external/mattpocock-skills
├── grill-with-docs →              # symlink into external/mattpocock-skills
└── ...

~/.config/opencode/opencode.json    # config: "skills.paths" includes ~/.agents/skills
```

## Adding a new external skill (agent workflow)

When asked to add a skill from someone else's GitHub repo:

### If the repo is already a submodule

1. Read `skills.manifest` to confirm the submodule name (the part before `:`)
2. Check the submodule has the skill by listing it:
   ```bash
   ls external/<submodule-name>/<path-to-skill>/
   ```
3. Verify it has a `SKILL.md` at that path
4. Add a line to `skills.manifest`:
   ```
   <submodule-name>:<path-from-submodule-root>  <target-name>
   ```
   - `<submodule-name>` = directory name under `external/` (e.g. `mattpocock-skills`)
   - `<path-from-submodule-root>` = path to the skill directory inside the submodule
     (e.g. `skills/productivity/grill-me`)
   - `<target-name>` = flat directory name that will appear in `~/.agents/skills/`
     (usually the skill name, e.g. `grill-me`)
5. Run `./scripts/sync-skills.sh --dry-run` to verify
6. Run `./scripts/sync-skills.sh` to apply
7. Run `./scripts/sync-skills.sh --dry-run` again to confirm no warnings
8. Verify the symlink exists and resolves:
   ```bash
   ls -la ~/.agents/skills/<target-name>/SKILL.md
   ```
9. Stage and commit:
   ```bash
   git add skills.manifest && git commit -m "Add external skill: <target-name>"
   ```

### If the repo is NOT already a submodule

1. Determine the repo URL and a short name for it:
   ```bash
   git submodule add <url> external/<name>
   ```
2. Then follow the steps above ("If the repo is already a submodule")
3. Make sure you also commit `.gitmodules` and the submodule pointer:
   ```bash
   git add .gitmodules external/<name> skills.manifest
   ```

## Removing an external skill

1. Remove its line from `skills.manifest`
2. Run `./scripts/sync-skills.sh --dry-run` — the old symlink should show as
   something that needs removing
3. Run `./scripts/sync-skills.sh` — this will NOT auto-remove stale symlinks.
   You must also:
   ```bash
   rm ~/.agents/skills/<target-name>
   ```
4. To clean up the submodule entirely (if no other skills use it):
   ```bash
   git submodule deinit -f external/<name>
   git rm external/<name>
   rm -rf .git/modules/external/<name>
   ```
5. Commit the manifest change (and submodule removal if done)

## Updating upstream skills

```bash
./scripts/sync-skills.sh
```

This does two things:
1. Fetches + fast-forwards every submodule under `external/` to its upstream `main`
2. Re-reads `skills.manifest` and creates/refreshes symlinks in `~/.agents/skills/`

After running, if any submodules were updated, commit the new pins:
```bash
git add external/ && git commit -m "Update submodule pins"
```

## Creating a new owned skill

1. Create the directory under `skills/`:
   ```bash
   mkdir -p skills/<skill-name>
   ```
2. Write a `SKILL.md` in that directory with YAML frontmatter:
   ```yaml
   ---
   name: <skill-name>
   description: <one-line description>
   ---
   ```
3. Add any helper scripts or reference files in the same directory
4. To make it active locally, symlink it into `~/.agents/skills/`:
   ```bash
   ln -s "$(pwd)/skills/<skill-name>" ~/.agents/skills/<skill-name>
   ```
5. Commit the skill and the symlink state: the `skills/` directory is tracked
   by git; the symlink in `~/.agents/skills/` is NOT tracked (it's a local
   installation detail)

## Critical rules

- **Never edit files under `external/`.** Those directories are git submodules
  owned by upstream repos. Changes will be lost on the next pull.
- **Never clobber a real directory in `~/.agents/skills/`.** The sync script
  refuses to overwrite real directories with symlinks. If a skill was copied
  (not symlinked), remove the copy first: `rm -rf ~/.agents/skills/<name>`.
- **Always run `--dry-run` first** before `sync-skills.sh` when modifying the
  manifest, to catch malformed entries or missing source paths.
- **`skills/` is for owned skills only.** External skills never go there.
- **`skills.manifest` format is whitespace-sensitive.** Two fields per line:
  `submodule:path  target-name`. Comment lines start with `#`. No trailing
  whitespace on paths.
- **Symlinks are relative.** They use `../../Code/agent-skills/...` paths so
  they survive if the repo moves within the same home directory. They will
  break if the repo is moved outside `$HOME`.

## `sync-skills.sh` reference

```
scripts/sync-skills.sh [--dry-run]
```

What it does, in order:
1. `cd` to repo root (derives it from the script's own location)
2. For each directory under `external/`: fetch upstream + fast-forward to origin/HEAD
3. Read `skills.manifest`, skip comments/blanks
4. For each entry: validate source exists, refuse to clobber real dirs, create/refresh symlink

Exit codes: 0 on success, non-zero on fatal error.
Non-fatal warnings (missing source, real-dir clobber) print to stderr but don't exit.

## `skills.manifest` reference

```
# comment
<submodule>:<path/inside/submodule>  <symlink-name>
```

- `<submodule>` matches a directory name under `external/`
- `<path/inside/submodule>` is relative to that submodule's root; must point to a
  directory containing a `SKILL.md`
- `<symlink-name>` is a single directory name (no slashes); the symlink is created
  as `~/.agents/skills/<symlink-name>`

Example:
```
mattpocock-skills:skills/productivity/grill-me        grill-me
mattpocock-skills:skills/engineering/grill-with-docs  grill-with-docs
```

## Common footguns

| Problem | Cause | Fix |
| --- | --- | --- |
| "Source does not exist" in sync output | Skill moved/renamed upstream, or wrong path in manifest | Check the submodule with `ls external/<name>/` and update manifest |
| Symlink broken (`ls -la` shows red) | Repo was moved, or submodule not initialized | Re-clone with `--recurse-submodules`, or `git submodule update --init` |
| Script warns "refusing to clobber" | A real directory exists at the target path | `rm -rf ~/.agents/skills/<name>` then re-run sync |
| fast-forward fails on submodule pull | Local changes in submodule (you edited a file in `external/` — don't do that) | `cd external/<name> && git checkout . && git pull` |

## License

MIT
