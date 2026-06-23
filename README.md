# agent-skills

A small collection of reusable agent skills for LLM coding harnesses (Claude
Code, OpenCode, Cursor, GitHub Copilot CLI). Each skill is a self-contained
directory under `skills/` with a `SKILL.md` and optional helper scripts.

Browse them at **https://skills.javagrant.ac.nz**.

## Owned Skills

| Skill | What it does |
| --- | --- |
| [`github-pages-porkbun-skill`](skills/github-pages-porkbun-skill) | Deploy a static site to GitHub Pages with a Porkbun-managed custom domain, end to end including the HTTPS cert. Includes the clear-and-re-add fix for a cert stuck at `null`. Also covers general Porkbun DNS record CRUD (list / create any type / delete) via its `porkbun.py` wrapper. |
| [`first-principles-skill`](skills/first-principles-skill) | Evaluate a problem, design, or decision from first principles — decompose into irreducible truths and reason upward, instead of justifying by analogy or convention. For foundational / high-impact choices where "best practice" may not fit your constraints. Owns the *what/why*; hands structural changes off to architecture-delegation-skill. |
| [`architecture-delegation-skill`](skills/architecture-delegation-skill) | Durable structural clarity via sub-agent delegation: the lead researches, grills the user, picks a slice, implements conservatively, and verifies with a reviewer. Owns the *how* of a structural change once first-principles has confirmed the *what/why*. Pairs with using-git-worktrees-skill for an isolated workspace. |
| [`using-git-worktrees-skill`](skills/using-git-worktrees-skill) | Create an isolated git worktree before feature work — detect existing isolation, prefer native harness tools, fall back to `git worktree add`. Goes beyond obra/superpowers by copying env/secret files, symlinking or installing deps, recording base-branch metadata, and defining the merge-back + cleanup step. |

## External Skills (symlinked from upstream repos)

This repo can symlink 3rd-party skills into your active skills directory
(`~/.agents/skills/`). Upstream repos live as **git submodules** under
`external/`. The manifest at `skills.manifest` declares which skills
to symlink, and `scripts/sync-skills.sh` does the work.

```bash
# One-time: clone with submodules
git clone --recurse-submodules https://github.com/JavaGT/agent-skills

# Pull upstream updates + refresh symlinks
./scripts/sync-skills.sh
```

### Adding a new external skill

1. Add the upstream repo as a git submodule:
   ```bash
   git submodule add <url> external/<name>
   ```
2. Add a line to `skills.manifest`:
   ```
   <name>:<path-to-skill-in-submodule>  <target-name>
   ```
3. Run `./scripts/sync-skills.sh`

### Current external skills

| Skill | Source |
| --- | --- |
| `grill-me` | [mattpocock/skills](https://github.com/mattpocock/skills) `→ skills/productivity/grill-me` |
| `grill-with-docs` | [mattpocock/skills](https://github.com/mattpocock/skills) `→ skills/engineering/grill-with-docs` |
| `improve-codebase-architecture` | [mattpocock/skills](https://github.com/mattpocock/skills) `→ skills/engineering/improve-codebase-architecture` |
| `systematic-debugging` | [obra/superpowers](https://github.com/obra/superpowers) `→ skills/systematic-debugging` |

## Install

```bash
# OpenCode / universal (~/.config/opencode or ~/.agents)
git clone https://github.com/JavaGT/agent-skills ~/.config/opencode/skills/agent-skills

# Claude Code
git clone https://github.com/JavaGT/agent-skills ~/.claude/skills/agent-skills

# Cursor (project-local)
git clone https://github.com/JavaGT/agent-skills .cursor/skills/agent-skills
```

## Credentials

Skills read secrets from `~/.secrets/*.env` (dotenv format, `chmod 600`),
never from the repo. Keeping them outside the project directory means apps
don't auto-load them and harnesses are more likely to prompt before reading.

```bash
# ~/.secrets/porkbun.env  (chmod 600)
PORKBUN_API_KEY=pk1_...
PORKBUN_SECRET_KEY=sk1_...
```

Generate Porkbun API keys at https://porkbun.com/account/api.

## This site is self-hosting

`skills.javagrant.ac.nz` is served from this repo's `main` branch via GitHub
Pages, and was deployed using `github-pages-porkbun-skill` — including the
Porkbun CNAME and the HTTPS cert.

## License

MIT
