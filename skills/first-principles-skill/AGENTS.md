# first-principles-skill

## Purpose

Evaluate a problem, design, or decision **from first principles** — decompose
it into irreducible truths and reason upward — instead of justifying by
analogy, convention, or inertia. Use when "best practice" may not fit your
actual constraints, when a design feels off but you can't articulate why, or
when making a foundational decision with long-term impact.

## When to activate

- "analyze from first principles" / "think from scratch" / "from first
  principles"
- "question this design" / "is this the right approach" / "challenge
  assumptions"
- "why are we doing it this way" / "is there a better solution"
- "第一性原理" / "从根本分析" / "从零开始思考" / "这个设计合理吗" /
  "为什么要这样做" / "有没有更好的方案"
- Evaluating architecture / design / build-vs-buy decisions where cargo-culting
  a popular pattern might give the wrong answer

Do **not** activate for trivial or reversible decisions — first-principles
analysis has a cost; reserve it for foundational, high-impact choices.

## How to use

Open the full skill: `SKILL.md` in this directory. It defines a 5-phase process:

1. **Identify the problem's essence** (outcomes, not solutions)
2. **Challenge all assumptions** (explicit + implicit, each given a verdict)
3. **Establish ground truths** (irreducible, provable facts — prefer measured
   data over belief)
4. **Reason upward** (minimal solution → justified additions)
5. **Validate the reasoning** (trace to ground truths, pre-mortem, define a
   revisit trigger)

The skill ships a structured output format (Problem Essence → Assumptions
table → Ground Truths → Reasoning Chain → Conclusion with revisit trigger).

## The one thing to remember

First principles earns its keep when the conventional answer is **~10x wrong**,
not 1.5x. If an existing solution is within ~2x of optimal and the team knows
it, use it — don't rebuild the database from scratch. Add the ground truth
*"development time is finite and expensive"* to every analysis.

## Companion references

- `references/software-examples.md` — database, microservices, auth, caching,
  API design worked end-to-end
- `references/elon-musk-examples.md` — SpaceX/Tesla material-vs-finished
  breakdowns with software parallels
- `examples/architecture-review.md` — full microservices decision review,
  including the cost of skipping the analysis

## License

MIT. Improved from `tt-a1i/first-principles-skill`.
