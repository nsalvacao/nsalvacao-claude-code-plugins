# Walkthrough — idea-auditor Quick Start

> End-to-end example using the `assets/examples_min/IDEA.md` template.
> Follow these steps in sequence on your own project.

---

## Prerequisites

- Claude Code with `idea-auditor` installed
- A project directory with an `IDEA.md` (copy from `assets/examples_min/IDEA.md`)

---

## Step 1 — Create your IDEA.md

Copy the template and fill in your own fields:

```bash
cp plugins/idea-auditor/assets/examples_min/IDEA.md my-project/IDEA.md
# Edit all fields: ICP, job-to-be-done, current alternative, promise, risks
```

Minimum required fields for `idea.schema.json`:
- `mode` (OSS_CLI | B2B_SaaS | Consumer_Viral | Infra_Fork_Standard)
- `icp` section
- `job_to_be_done`

---

## Step 2 — Run the scorecard (no evidence yet)

```
/idea-auditor:score my-project --mode OSS_CLI
```

**Expected output (no STATE/ directory):**
```json
{
  "decision": "INSUFFICIENT_EVIDENCE",
  "score_total": null,
  "confidence_global": null
}
```

This is correct — without evidence, the system cannot score. It will tell you what to collect.

---

## Step 3 — Generate experiment plan

Because the decision is `INSUFFICIENT_EVIDENCE`:

```
/idea-auditor:tests my-project
```

**Expected output:** `EXPERIMENTS/plan-YYYYMMDD.md` with:
- 5+ experiments (one per dimension)
- Each with hypothesis, proxy metric, and stop rules

---

## Step 4 — Run one experiment (wedge smoke test)

From the experiment plan, pick the smoke test for the wedge dimension:

**Experiment:** Post a description of your tool's value proposition in 2 relevant communities (HackerNews, a subreddit, or Discord). Include a waitlist link.

**Stop rules (pre-committed before running):**
- Kill threshold: < 5% click-through on the waitlist link after 200 unique visitors
- Proceed threshold: ≥ 15% waitlist sign-up rate with ≥ 2 messages from users describing their specific pain

**Record results in STATE/**

Create `STATE/wedge_interviews.json`:

```json
[
  {
    "dimension": "wedge",
    "claim": "User spent 3h reconciling tool outputs manually last week",
    "source": "HN comment thread (anonymous)",
    "method": "observation",
    "collected_at": "YYYY-MM-DD",
    "quality_tier": "stated",
    "confidence_components": {
      "source_diversity": 0.5,
      "consistency": 0.7
    }
  }
]
```

---

## Step 5 — Re-score with evidence

```
/idea-auditor:score my-project --mode OSS_CLI
```

Now with `STATE/wedge_interviews.json`, the grader will compute `ConfDim` for wedge and the scorecard will include a partial wedge score.

To supply your qualitative `score_bruto` assessment for wedge (0–5, using `references/rubric.md` anchors):

```bash
python3 plugins/idea-auditor/scripts/calc_scorecard.py \
  --idea my-project/IDEA.md \
  --evidence my-project/REPORTS/evidence-YYYYMMDD.json \
  --scores '{"wedge": {"score_bruto": 2}}' \
  --mode OSS_CLI \
  --out my-project/REPORTS/scorecard-YYYYMMDD.json
```

---

## Step 6 — Interpret the scorecard

Open `REPORTS/scorecard-YYYYMMDD.json`:

```
ITERATE (score 32/100, confidence 0.41)
→ wedge: score_bruto 2, confidence 0.41, score_efetivo 0.82
→ friction/loop/timing/trust: INSUFFICIENT_EVIDENCE
```

**Decision:** ITERATE means: some signal but gaps remain. Collect evidence for the remaining dimensions.

---

## Step 7 — Drill into the weakest dimension

```
/idea-auditor:drill friction
```

This invokes `idea-auditor-friction-analyst` to:
- Identify TTFV measurement gaps
- Suggest 3 experiments with stop rules
- Produce `REPORTS/drill-friction-YYYYMMDD.md`

---

## Step 8 — Iterate until PROCEED or KILL

Continue the loop:
1. Run experiment → record in `STATE/`
2. Re-score → `REPORTS/scorecard-*.json`
3. Drill weakest dimension → `REPORTS/drill-*.md`
4. Repeat until PROCEED (score ≥ 70, confidence ≥ 0.6) or evidence for KILL accumulates

---

## Stop Rule Example (pre-filled)

From `EXPERIMENTS/plan-YYYYMMDD.md`:

```markdown
### Experiment — Waitlist Smoke Test

**Hypothesis:** If we post the tool description in 2 dev communities, ≥15% of visitors will join the waitlist.
**Dimension:** wedge
**Pattern:** smoke_test

**Stop Rules (pre-committed):**
- Kill: < 5% waitlist conversion after 200 visitors → re-examine ICP or value prop framing
- Proceed: ≥ 15% conversion after ≥ 100 visitors → advance to JTBD interviews with waitlist
- Iterate: 5–14% conversion → run 5 JTBD interviews to refine messaging
```

---

## File Summary After Walkthrough

```
my-project/
  IDEA.md                         ← your idea definition
  STATE/
    wedge_interviews.json         ← collected evidence
    .cache/                       ← fetch_oss_metrics.py cache (auto-created)
  REPORTS/
    evidence-YYYYMMDD.json        ← graded evidence (from grade_evidence.py)
    scorecard-YYYYMMDD.json       ← scorecard (from calc_scorecard.py)
    drill-friction-YYYYMMDD.md    ← dimension drill report
  EXPERIMENTS/
    plan-YYYYMMDD.md              ← experiment plan (from /tests)
```
