# IDEA — Local CLI Evidence Auditor

> Minimal example for idea-auditor. Mode: OSS_CLI.
> Replace all fields with your own content.

---

## Metadata

- **mode:** OSS_CLI
- **version:** 0.1.0

---

## ICP (Ideal Customer Profile)

- **Role:** Senior software engineer, product engineer, or indie developer
- **Context:** Working on CLI tools, developer libraries, or open-source projects
- **Trigger event:** Spent time on a side project or fork, unsure if it has real traction
- **Company size:** 1–20 people (startup or solo)

---

## Job to Be Done

> "When I've built a CLI tool and invested weeks in it, I want to know if real people have the pain I'm solving — before I spend more months on it — so I can decide to double down or pivot."

**Job statement:** Validate whether a CLI tool addresses a real pain before scaling investment.

---

## Current Alternative

- Read GitHub issues and stars casually (proxy-tier evidence, no structured scoring)
- Ask friends on Discord/Slack (stated-tier, biased sample)
- Estimated cost: 5–10h/month of unstructured research, high cognitive overhead, no audit trail

---

## Promise

An evidence-driven scorecard that separates "sounds plausible" from "validated by real signals" — with a structured decision (PROCEED / ITERATE / KILL) and a next-step experiment plan.

---

## Assumptions (to be tested)

1. Developers feel guilty guessing instead of measuring → they will use a structured tool if it's low-friction
2. The 0–5 rubric anchors are interpretable without training
3. JTBD frameworks apply to open-source tool validation (not just SaaS)

---

## Risks

1. LLM hallucination risk: agent invents scores not supported by evidence
2. Adoption risk: developers don't document IDEA.md; tool requires discipline
3. Competition: existing product validation frameworks (Strategyzer, Lean Canvas) may cover this adequately

---

## Modes

- **OSS_CLI** — primary mode for this idea (CLI developer tools)
- **B2B_SaaS** — applicable if pivoting to team/enterprise licensing
