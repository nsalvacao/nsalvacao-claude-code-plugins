---
description: Run the idea-auditor scoring pipeline on an IDEA.md or IDEA.json file. Validates inputs, grades evidence from STATE/, and produces a PROCEED/ITERATE/KILL scorecard with top blockers and next tests. Usage: /idea-auditor:score <path> [--mode OSS_CLI|B2B_SaaS|Consumer_Viral|Infra_Fork_Standard]
argument-hint: "<path> [--mode OSS_CLI|B2B_SaaS|Consumer_Viral|Infra_Fork_Standard]"
allowed-tools: Bash, Read, Write
---

Run the `idea-auditor` scoring pipeline.

## Steps

1. Parse `<path>` argument (directory containing `IDEA.md` or `IDEA.json`) and optional `--mode` flag (default: `OSS_CLI`).
2. Validate inputs:
   ```bash
   python3 plugins/idea-auditor/scripts/validate_inputs.py --idea <path>/IDEA.md [--state <path>/STATE]
   ```
   Stop and report errors if validation fails.
3. Grade evidence (if `STATE/` exists):
   ```bash
   python3 plugins/idea-auditor/scripts/grade_evidence.py --evidence <path>/STATE --out <path>/REPORTS/evidence-$(date +%Y%m%d).json
   ```
4. Calculate scorecard:
   ```bash
   python3 plugins/idea-auditor/scripts/calc_scorecard.py \
     --idea <path>/IDEA.md \
     [--evidence <path>/REPORTS/evidence-<DATE>.json] \
     --mode <MODE> \
     --out <path>/REPORTS/scorecard-$(date +%Y%m%d).json
   ```
5. Present results: decision, score per dimension, top blockers (from weak dimensions), and suggested next tests.

## Output

- `REPORTS/scorecard-YYYYMMDD.json` — machine-readable scorecard
- `REPORTS/evidence-YYYYMMDD.json` — graded evidence (if STATE/ present)

## Notes

- `score_bruto` per dimension must be supplied via `--scores` if specialist agents (v0.2.0) are not yet available.
- Top blockers are derived from dimensions with `needs_experiment=true` or lowest `score_efetivo`.
- If decision is `ITERATE` or `INSUFFICIENT_EVIDENCE`, suggest running `/idea-auditor:tests`.
