---
layout: post
title: "The Tests Are Green. The Architecture Is Not: Why I Built Archfit"
date: 2026-08-23T12:00:00+03:00
published: true
tags:
  - ai
  - coding-agents
  - software-architecture
  - ddd
  - coupling
  - devops
  - ci/cd
  - golang
categories:
  - Development
  - DevOps
  - Architecture
  - AI
---

An AI coding agent gets a small feature request. It reads the relevant files, writes the code, adds tests, runs the test suite, and reports success.

Everything is green.

It also made `pricing` import `billing/persistence/postgres` because the function it needed was conveniently sitting there. The feature works. The tests pass. The pull request is small. The architecture is now slightly worse.

This is the old problem of **architecture erosion**, now running at agent speed.

Humans created bad shortcuts long before LLMs arrived. Coding agents did not invent the big ball of mud. They made it possible to add locally reasonable shortcuts in parallel, all day, with clean test output and a cheerful summary.

I built [Archfit](https://github.com/alexei-led/archfit) as an attempt to put architecture governance into the same feedback loop as tests and linters. It is not an AI architect, and it is definitely not proof that a repository has "good architecture." It is a way to define some architectural intent, measure whether the code still follows it, and give both humans and agents a deterministic reason to stop when it does not.

## The Problem Is Governance, Not Code Generation

Architecture governance sounds like something invented to justify a committee. I mean something simpler:

1. **Define intent.** Which modules exist? What do they own? Which APIs are public? Which dependencies and layer directions are allowed?
2. **Observe reality.** What dependencies, cycles, boundary leaks, and cross-module relationships actually exist in the code?
3. **Manage change.** Decide which drift is a defect, which debt is temporarily accepted, and when the intended architecture itself should change.

Without the first step, there is nothing to govern. A diagram in an old presentation is not architecture intent. Neither is the folder structure if nobody can explain whether it is deliberate.

Without the second step, intent becomes documentation that slowly diverges from the repository. The code always wins this argument.

Without the third step, governance becomes a frozen list of rules that prevents useful evolution. Good architecture is not architecture that never changes. It changes deliberately rather than one convenient import at a time.

This was already difficult with human teams. A 2022 [systematic mapping study of architecture erosion](https://arxiv.org/abs/2112.10934) reviewed 73 studies and found both technical and non-technical causes. Erosion appears not only as structural violations, but also as lower software quality and harder evolution. AI agents did not create the phenomenon. They changed its speed and review economics.

The number of changed lines is no longer scarce. My ability to understand every structural consequence still is.

## I Tried the Obvious Things

I did not start by deciding that the world needed another CLI.

I wrote project-level `CLAUDE.md` and `AGENTS.md` files. I described the architecture, important boundaries, coding rules, build commands, and tests. I created focused skills for architecture review. I placed instructions closer to subprojects so an agent would see the relevant rules instead of reading one enormous constitution at the repository root.

This helps. I still do it.

Anthropic's documentation says each Claude Code session starts with a fresh context window and loads `CLAUDE.md` as persistent project context. It also says this explicitly: Claude treats those instructions as **context, not enforced configuration**. OpenAI's `AGENTS.md` mechanism similarly builds a hierarchy of project guidance for Codex.

Instructions can explain why a boundary exists. They cannot guarantee that the current task, current context, and current model will respect it. A Markdown file can ask politely. It cannot fail CI.

Most of my projects also have high test coverage and strict lint rules. That is necessary, but it is not enough.

- Tests answer questions about behavior that somebody thought to assert. They usually do not ask whether `pricing` reached into `billing` internals.
- Coverage says code executed. It does not say the dependency was allowed.
- General linters are good at syntax, common defects, complexity, and local conventions. They do not know which bounded context owns a discount policy.
- Code review can catch architecture drift, but agent output can now arrive faster than a human can review it deeply.

An agent can therefore produce code that is correct, tested, formatted, secure enough for the current checks, and architecturally wrong. No individual signal is broken. The set of signals is incomplete.

## This Discussion Is Already Public

The industry is converging on the idea that faster generation needs stronger feedback, although the evidence is still young and sometimes wrapped in impressive marketing.

The official [2025 DORA report announcement](https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report) describes AI as an amplifier. DORA observed a positive relationship between AI adoption and delivery throughput, but a negative relationship with delivery stability. Teams with loosely coupled architectures and fast feedback loops benefited more than teams constrained by tightly coupled systems and slow processes. These are survey relationships, not proof that an LLM caused a particular outage, but the direction is useful: faster change exposes weak control systems.

Birgitta Böckeler's [maintainability sensors for coding agents](https://martinfowler.com/articles/sensors-for-coding-agents.html) explores deterministic dependency rules and other sensors that let agents correct their own work. The important word is *sensor*: a guide tells the agent what we want; a sensor reports what happened.

This continues the [architectural fitness-function](https://www.thoughtworks.com/en-us/insights/books/building-evolutionaryarchitectures-second-edition) idea developed by Neal Ford, Rebecca Parsons, Patrick Kua, and Pramod Sadalage: important architectural properties should be checked continuously, not remembered during occasional reviews.

Vlad Khononov makes a related point in his posts about the [golden age of modularity](https://www.linkedin.com/pulse/golden-age-modularity-vlad-khononov-swjbf) and [context engineering for coding agents](https://www.linkedin.com/posts/vladikk_software-architecture-superstream-optimizing-activity-7465382571103903744-pOOe). Good modular design narrows the context required for a task. In another discussion about maintainability sensors, he notes that counting dependencies tells us how many dependencies exist, but not whether the design is sound. One relationship that leaks the wrong knowledge can be worse than many dependencies through stable contracts.

There is also early academic work. In the April 2026 preprint [*Architecture Without Architects: How AI Coding Agents Shape Software Architecture*](https://arxiv.org/abs/2604.04990v1), Phongsakon Mark Konrad, Tim Lukas Adam, Riccardo Terrenzi, and Serkan Ayvaz identify mechanisms by which agents make implicit architectural choices. Their demonstration shows prompt wording producing different structures for the same task. The authors are clear that the demonstration is illustrative and that several proposed patterns still need empirical validation. It is a useful framing, not a settled law of software engineering.

The common thread is not "AI writes bad code." The common thread is that coding agents make design decisions, often inside a local task context, while architecture is a system-level property maintained over time.

## Modularity Is Context Engineering for Code

A well-designed module hides decisions that another module does not need to know.

That helps humans. It also helps agents. If the `pricing` module has a coherent model and a small public contract, an agent changing a pricing rule needs less repository context. If every module shares database tables, framework types, and one universal `Customer` object, the agent must understand half the system before making a safe change. It usually will not, and to be fair, neither will I on Friday afternoon.

This is where strategic Domain-Driven Design matters:

- identify the core, supporting, and generic subdomains;
- define where one model and language are consistent;
- stop that model at a bounded-context boundary;
- integrate contexts through explicit contracts.

DDD here does not mean surrounding CRUD with fourteen factories. It means that two types named `Product` do not automatically represent the same concept, and that business ownership should shape code boundaries.

Microservices do not create those boundaries automatically. A distributed big ball of mud is still mud, only with TLS and a larger cloud bill.

## Coupling Is Not the Enemy

A lot of architecture advice can be reduced to "decouple everything." That produces systems where two related lines of code communicate through three interfaces and an event bus.

Archfit is based on Vlad Khononov's [Balanced Coupling](https://coupling.dev/) model and [*Balancing Coupling in Software Design*](https://www.informit.com/store/balancing-coupling-in-software-design-universal-design-9780137353484). The model asks three questions about a relationship:

1. **Integration strength:** how much knowledge crosses the boundary?
2. **Distance:** how expensive is it to change both sides?
3. **Volatility:** how likely is the upstream component to change?

Strong coupling at low distance can be healthy cohesion. Weak coupling at high distance can be a good contract. The expensive case is strong coupling across distant, independently changing components—especially in a volatile core domain.

Archfit uses the model's per-edge balance formula, `max(|strength - distance|, 10 - volatility) + 1`, to make this reasoning reproducible. The result is an estimate based on declared and observed evidence, not an objective architecture grade. The important output is still the explanation of what crosses the boundary and why that relationship is risky.

## I Looked for an Existing Solution

There are good architecture-conformance tools already. ArchUnit checks Java structures. dependency-cruiser validates JavaScript and TypeScript dependencies. Import Linter provides Python import contracts. CodeScene, NDepend, Sonargraph, Structure101, Semgrep, and language-specific linters cover other parts of the problem.

Vlad has also released [modularity skills for Claude Code](https://www.linkedin.com/posts/vladikk_modularity-skills-for-claude-code-activity-7446905386512711680-CZS0), and Böckeler's sensor work explores a broader maintainability harness. I do not claim that Archfit invented architecture checks or is the only AI-focused attempt.

What I could not find was the exact loop I wanted:

- one architecture-intent file with modules, public surfaces, layers, owners, deploy units, and DDD metadata;
- deterministic facts across Go, TypeScript/JavaScript, Python, and Rust;
- explicit reporting when evidence is missing instead of a confident green score;
- a CI gate that protects the declared boundaries;
- structured repair tasks that an agent can consume and validate.

Archfit is my attempt to build that loop.

## Archfit: Intent, Evidence, Gate

Archfit reads architecture intent from `.archfit.yaml`. A small fragment can describe more than folder names:

```yaml
version: 1
languages:
  typescript:
    enabled: true
layers: [domain, application]

modules:
  pricing:
    paths: [src/pricing/**]
    public: [src/pricing/api/**]
    layer: domain
    subdomain: core
    owner: pricing-team
  billing:
    paths: [src/billing/**]
    public: [src/billing/api/**]
    internal: [src/billing/persistence/**]
    layer: application
    subdomain: supporting
    owner: billing-team

rules:
  - id: contexts_via_contract
    type: public_api_only
    gate: fail
```

This says that `pricing` and `billing` are separate modules, only named surfaces are public, they have different domain roles, and cross-module access must use contracts. Real configurations can add deploy units, forbidden dependencies, layer direction, cycles, metric budgets, and coupling policy. The [configuration guide](https://github.com/alexei-led/archfit/blob/main/docs/guide/configuration.md) has the details; a blog post should not become an alternative reference manual.

The runtime separates three concerns:

1. **Facts:** embedded adapters such as `go/packages`, plus external analyzers such as dependency-cruiser, grimp, ast-grep, SCIP indexers, and clone detection where configured.
2. **Decision:** deterministic rules, metrics, coverage, verdicts, and repair tasks.
3. **Narration:** optional AI summaries and draft semantic labels.

AI does not participate in a gate run. Some commands can draft or directly apply AI-generated configuration, so teams should review that configuration before making it gate input. Once the config and approved labels are fixed, the gate itself is deterministic.

When a gate rule fails, `agent_tasks[]` can give an agent a goal, constraints, resolved repository files when available, and a validation command. With `--base`, Archfit can also classify current repair tasks as introduced, pre-existing, or unknown when the evidence permits. It does not pretend that every historical finding was created by the current pull request.

Missing evidence is visible. An optional analyzer that is absent normally produces a coverage gap and an `n/a` metric. Teams can make that absence blocking with analyzer policy or `--require-tools`. Unknown is not success, but it is also not silently converted into a fact.

## A Small CI Loop, Not Another Architecture Ceremony

On macOS, Homebrew installs the released binary without requiring a Go SDK. The commands below match Archfit v1.7:

```bash
brew install alexei-led/tap/archfit
archfit doctor
archfit config init --root .
archfit analyze -c .archfit.yaml
```

Review the generated modules and policy before using them. Discovery can find structure; it cannot infer your business strategy or team ownership reliably.

After review, `archfit baseline -c .archfit.yaml` records accepted current debt. Commit `.archfit-baseline.json`; do not regenerate it inside the validation job. Then put `archfit check -c .archfit.yaml` in CI and in the agent's repair loop.

`check` returns `0` for pass, `1` for violations, `2` for warning-level policy results, and `3` for configuration or tool errors. A repair loop should distinguish those states: repair violations, review warnings, and stop on execution errors. Not every non-zero result has an `agent_tasks` entry.

If you consume `--json`, preserve Archfit's process status. A plain `archfit check --json | jq ...` pipeline can return `jq`'s success code after Archfit failed. Use shell `pipefail` or capture the JSON and exit status separately. The [CI guide](https://github.com/alexei-led/archfit/blob/main/docs/guide/ci.md) shows the safe patterns.

That is enough for the blog. Installation variants, SARIF, GitHub Actions, enrichment workflows, and every configuration key belong in the documentation.

## What Archfit Cannot Govern

Archfit can check declared module boundaries, public APIs, forbidden dependencies, layer direction, cycles, metric regressions, and configured Balanced Coupling policy. It can produce text, JSON, Markdown, scorecard, and SARIF output.

It cannot understand your whole architecture.

- **The configuration can lie.** Incorrect module paths, owners, subdomains, or public surfaces produce incorrect conclusions, only more consistently.
- **Static analysis has a ceiling.** Runtime and lifecycle coupling, dynamic behavior, and duplicated business rules can be hard to see.
- **Language coverage differs.** Go, TypeScript/JavaScript, Python, and Rust do not expose identical facts or precision.
- **A coupling score is not a quality certificate.** It says nothing by itself about security, performance, data correctness, or whether the business model makes sense.
- **Rules can create noise.** Gate architectural invariants. Review advisories. Do not force an agent to build an abstraction pyramid because one metric looked lonely.
- **Human judgment remains part of governance.** A tool can detect drift from declared intent. Humans must decide when the intent should change.

These are not temporary disclaimers until enough AI is added. They are boundaries of the problem.

## Try It Without Trusting It

The project is open source under Apache-2.0 at [github.com/alexei-led/archfit](https://github.com/alexei-led/archfit).

I want concrete disagreement and ugly repositories:

- configurations that fail to represent real systems;
- false positives and, more importantly, false confidence;
- better evidence for integration strength, distance, and volatility;
- runtime or organizational signals that static code misses;
- agent feedback that is actionable without causing refactoring hysteria;
- language adapters and integrations with existing architecture tools.

If another tool solves part of this better, point me to it. If the Balanced Coupling mapping is wrong, bring an example. If architecture governance cannot be reduced to useful deterministic checks, I want to know exactly where it breaks.

Coding agents will keep generating more changes than humans can inspect line by line. The answer is not a larger prompt asking them to "please respect the architecture." The answer is to make the important intent explicit, make violations observable, and make architectural change deliberate.

The tests should stay green. The architecture should get a check of its own.

---

## Further Reading

- Vlad Khononov, [*Balancing Coupling in Software Design*](https://www.informit.com/store/balancing-coupling-in-software-design-universal-design-9780137353484)
- Vlad Khononov, [*Learning Domain-Driven Design*](https://www.oreilly.com/library/view/learning-domain-driven-design/9781098100124/)
- Neal Ford, Rebecca Parsons, Patrick Kua, and Pramod Sadalage, [*Building Evolutionary Architectures*](https://www.thoughtworks.com/en-us/insights/books/building-evolutionaryarchitectures-second-edition)
- Birgitta Böckeler, [Maintainability sensors for coding agents](https://martinfowler.com/articles/sensors-for-coding-agents.html)
- DORA, [2025 State of AI-Assisted Software Development announcement](https://cloud.google.com/blog/products/ai-machine-learning/announcing-the-2025-dora-report)
- Ruiyin Li, Peng Liang, Mohamed Soliman, and Paris Avgeriou, [*Understanding Software Architecture Erosion*](https://arxiv.org/abs/2112.10934)
