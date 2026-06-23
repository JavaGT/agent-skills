# agent-skills

A small collection of reusable agent skills for LLM coding harnesses (Claude
Code, OpenCode, Cursor, GitHub Copilot CLI). Each skill is a self-contained
directory under `skills/` with a `SKILL.md` and optional helper scripts.

Browse them at **https://skills.javagrant.ac.nz**.

## Skills

| Skill | What it does |
| --- | --- |
| [`github-pages-porkbun-skill`](skills/github-pages-porkbun-skill) | Deploy a static site to GitHub Pages with a Porkbun-managed custom domain, end to end including the HTTPS cert. Includes the clear-and-re-add fix for a cert stuck at `null`. |
| [`porkbun-dns`](skills/porkbun-dns) | Generic Porkbun DNS record CRUD (create / list / delete / ping). |

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
