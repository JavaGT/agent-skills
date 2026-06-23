# first-principles-skill

Evaluate a problem, design, or decision **from first principles** — decompose
it into irreducible truths and reason upward, instead of justifying by analogy,
convention, or inertia.

A cross-platform agent skill. Once installed, invoke it with
`/first-principles-skill` in any tool that reads skills.

## When to use it

- A "best practice" may not fit your actual constraints.
- A design feels off but you can't articulate why.
- A foundational decision with long-term impact.
- Cargo-culting a popular pattern (microservices, Kubernetes, an ORM, a cache)
  might give the wrong answer at your scale.
- Build-vs-buy where the conventional answer feels wrong.

Reserve it for foundational / high-impact choices — not every reversible
decision.

## Install

This skill lives in the [agent-skills](https://github.com/JavaGT/agent-skills)
repo. To install standalone:

```bash
git clone https://github.com/JavaGT/agent-skills
cd agent-skills/skills/first-principles-skill
./install.sh                 # auto-detect platform
./install.sh --platform opencode
./install.sh --all           # every detected tool
```

Or, if you manage skills via the agent-skills repo + `sync-skills.sh`, it is
symlinked into `~/.agents/skills/` automatically (owned skill).

### Manual

```bash
# OpenCode / universal
ln -s "$(pwd)" ~/.agents/skills/first-principles-skill

# Claude Code
ln -s "$(pwd)" ~/.claude/skills/first-principles-skill
```

## Usage

```
/first-principles-skill should we adopt microservices?
/first-principles-skill question this design — we're caching everything in Redis
/first-principles-skill is the monolith + Postgres choice still right?
/first-principles-skill challenge the assumption that we need an ORM here
/first-principles-skill 用第一性原理分析一下我们是否应该用 Kubernetes
```

Also triggers on natural language: "analyze from first principles", "think from
scratch", "challenge assumptions", "第一性原理", "从根本分析", etc.

## The 5-phase process

1. **Identify the problem's essence** — state it in outcomes, not solutions.
2. **Challenge all assumptions** — explicit + implicit; each gets a verdict
   (Keep / Discard / Modify / Investigate).
3. **Establish ground truths** — irreducible, provable facts; prefer measured
   data over belief.
4. **Reason upward** — minimal solution → justified additions only.
5. **Validate** — trace to ground truths, pre-mortem, define a revisit trigger.

Output is a structured analysis: Problem Essence → Assumptions table → Ground
Truths → Reasoning Chain → Conclusion (with revisit trigger).

## The one rule

First principles earns its keep when the conventional answer is **~10x wrong**,
not 1.5x. If an existing solution is within ~2x of optimal and the team knows
it, use it. Add the ground truth *"development time is finite and expensive"*
to every analysis.

## Structure

```
first-principles-skill/
├── SKILL.md                          # Skill definition (slash-invocable)
├── AGENTS.md                         # Companion for cross-tool reach
├── install.sh                        # Cross-platform installer
├── README.md
├── LICENSE                           # MIT
├── references/
│   ├── software-examples.md          # DB / microservices / auth / cache / API
│   └── elon-musk-examples.md         # SpaceX / Tesla material-vs-finished
└── examples/
    └── architecture-review.md        # Full microservices decision review
```

## Provenance

Improved (Level 5: slash-trigger, full frontmatter, AGENTS.md, installer) from
[`tt-a1i/first-principles-skill`](https://github.com/tt-a1i/first-principles-skill).
MIT license retained.

## License

MIT.
