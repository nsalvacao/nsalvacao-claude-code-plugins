# Worked Example — Phase 1 Contract: Customer Support AI

This worked example shows a fully populated Phase Contract for Phase 1
(Opportunity and Feasibility) of a real-world AI product delivery.

Project: **Customer Support AI — Automated Ticket Triage**

---

## Phase Contract

```yaml
phase_id: 1
phase_name: "Opportunity and Feasibility"
status: ready_for_gate
owner: "Sarah Chen (Product Manager)"
start_date: "2026-01-15"
target_end_date: "2026-02-12"

project:
  name: "Customer Support AI — Automated Ticket Triage"
  product_type: SaaS
  ai_component: "LLM-based ticket classification and routing"
  ai_justification: >
    Manual triage takes 8 minutes per ticket on average; target <30 seconds with AI;
    estimated 70% cost reduction in triage labor.
  fallback_scenario: >
    If AI model accuracy falls below 85%, route all tickets to manual queue with
    priority flags; AI component is additive, not critical path.

entry_criteria:
  - criterion: "Business problem identified and validated by Customer Support Director"
    status: YES
    evidence: "kickoff meeting 2026-01-10"
  - criterion: "Initial stakeholder list confirmed"
    status: YES
    evidence: "6 stakeholders identified"
  - criterion: "No conflicting initiative in current roadmap"
    status: YES
    evidence: "roadmap review completed"

exit_criteria:
  - criterion: "Problem statement reviewed and approved by sponsor"
    status: met
    date: "2026-01-22"
  - criterion: "Feasibility verdict documented"
    status: met
    verdict: "feasible with conditions"
  - criterion: "AI justification with fallback documented"
    status: met
    evidence: "section 4 of project charter"
  - criterion: "Initial risk register with >=3 risks"
    status: met
    evidence: "7 risks identified"
  - criterion: "Project charter approved by sponsor"
    status: met
    date: "2026-02-08"

evidence_required:
  - .waterfall-lifecycle/artefacts/phase-1/problem-statement.md
  - .waterfall-lifecycle/artefacts/phase-1/vision-statement.md
  - .waterfall-lifecycle/artefacts/phase-1/stakeholder-map.md
  - .waterfall-lifecycle/artefacts/phase-1/feasibility-assessment.md
  - .waterfall-lifecycle/artefacts/phase-1/data-feasibility-note.md
  - .waterfall-lifecycle/artefacts/phase-1/ai-feasibility-note.md
  - .waterfall-lifecycle/artefacts/phase-1/initial-risk-register.md
  - .waterfall-lifecycle/artefacts/phase-1/assumption-register.md
  - .waterfall-lifecycle/artefacts/phase-1/clarification-log.md
  - .waterfall-lifecycle/artefacts/phase-1/project-charter.md
  - .waterfall-lifecycle/artefacts/phase-1/initiation-gate-pack.md

sign_off_authority: "VP Engineering (James Torres) and Customer Support Director (Maria Santos)"

assumptions:
  - id: A-001
    text: >
      Zendesk API access will be granted within 2 weeks of phase start.
    validation_status: "validated 2026-01-25 — access confirmed"
    owner: "Engineering Lead"
  - id: A-002
    text: >
      GDPR compliance review will be completed by external counsel before Gate A.
    validation_status: "validated 2026-02-01 — review completed"
    owner: "Legal Counsel"
  - id: A-003
    text: >
      Training data from last 18 months is sufficient for model training.
    validation_status: "open — awaiting data engineer confirmation"
    owner: "Data Engineer"

clarifications:
  - id: CL-001
    question: "Can the AI component be deployed on existing infrastructure?"
    resolution: "Yes, confirmed by CTO on 2026-01-18. Deploy on existing AWS stack."
    resolved_by: "CTO"
    resolved_date: "2026-01-18"
  - id: CL-002
    question: "What is the acceptable false-positive rate for ticket routing?"
    resolution: "<5% false positives, confirmed by CS Director on 2026-01-20."
    resolved_by: "Customer Support Director"
    resolved_date: "2026-01-20"

mandatory_questions:
  - question: "What problem are we solving?"
    answer: >
      Reducing ticket triage time from 8 min to <30 sec using LLM classification.

  - question: "What does success look like?"
    answer: >
      70% reduction in triage labor cost; <30 sec average classification time; >85% accuracy.

  - question: "Why AI and not a simpler solution?"
    answer: >
      Rule-based systems tested in 2025, achieved only 60% accuracy; LLM approach
      validated by POC reaching 88%.

  - question: "What happens if AI fails?"
    answer: >
      Graceful degradation to manual queue; AI is enhancement, not critical path.

  - question: "What data and legal constraints apply?"
    answer: >
      GDPR applies (EU customer data); data processing agreement required with LLM
      provider; no PII in training data.

  - question: "Who has authority to approve the project charter?"
    answer: >
      VP Engineering with Customer Support Director co-sign.
```

---

## Notes for Practitioners

- All entry criteria must be YES before Gate A can be called.
- All exit criteria must be `met` before submitting for gate review.
- `sign_off_authority` maps to the gate review panel defined in `references/role-accountability-model.md`.
- Risk scores use the 5×5 matrix in `skills/risk-management/references/risk-patterns.md`.
- Clarifications should be resolved before gate; unresolved ones become open risks.
- Assumption A-003 is open — it must be resolved or escalated before Gate A closes.
