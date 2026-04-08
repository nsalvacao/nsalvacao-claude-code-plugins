#!/usr/bin/env python3
"""build_report.py — Generates a human-readable Markdown report from scorecard and evidence JSON.

Reads:
  - REPORTS/scorecard-*.json (from calc_scorecard.py)
  - REPORTS/evidence-*.json (from grade_evidence.py, optional)

Writes:
  - REPORTS/report-YYYYMMDD.md

Design:
  - Pure stdlib, no dependencies beyond what's in the venv
  - Never re-computes scores — reads from scorecard JSON (scripts are source of truth)
  - Blockers are derived by ranking dimensions: lowest score_efetivo first;
    dimensions with needs_experiment=True are always listed as blockers

Usage:
  python3 build_report.py --scorecard REPORTS/scorecard-20260408.json
  python3 build_report.py --scorecard REPORTS/scorecard-20260408.json --evidence REPORTS/evidence-20260408.json
  python3 build_report.py --scorecard REPORTS/scorecard-20260408.json --out REPORTS/report-20260408.md
"""

import argparse
import json
import sys
from datetime import date
from pathlib import Path


DECISION_EMOJI = {
    "PROCEED": "✅",
    "ITERATE": "🔄",
    "KILL": "❌",
    "INSUFFICIENT_EVIDENCE": "⚠️",
}

def confidence_label(conf: float | None) -> str:
    if conf is None:
        return "—"
    if conf >= 0.7:
        return "High"
    if conf >= 0.4:
        return "Medium"
    return "Low"



def derive_blockers(dimensions: dict) -> list[dict]:
    """Derive top 3 blockers from scorecard dimensions.

    Priority order:
    1. needs_experiment=True (no evidence → must gather first)
    2. Lowest score_efetivo (most improvable)
    """
    needs_exp = [
        (dim, data) for dim, data in dimensions.items()
        if data.get("needs_experiment") is True
    ]
    has_score = [
        (dim, data) for dim, data in dimensions.items()
        if data.get("needs_experiment") is False and data.get("score_efetivo") is not None
    ]
    # Sort by score_efetivo ascending (weakest first)
    has_score.sort(key=lambda x: x[1].get("score_efetivo", 999))

    blockers = []
    for dim, data in needs_exp:
        blockers.append({
            "dimension": dim,
            "type": "missing_evidence",
            "score_bruto": data.get("score_bruto"),
            "score_efetivo": data.get("score_efetivo"),
        })
    for dim, data in has_score:
        blockers.append({
            "dimension": dim,
            "type": "weak_score",
            "score_bruto": data.get("score_bruto"),
            "score_efetivo": data.get("score_efetivo"),
        })

    return blockers[:3]


def format_dimension_table(dimensions: dict) -> str:
    header = "| Dimension | score_bruto | confidence | score_efetivo | Status |\n"
    header += "|-----------|------------|-----------|--------------|--------|\n"
    rows = []
    for dim, data in dimensions.items():
        sb = data.get("score_bruto")
        conf = data.get("confidence")
        se = data.get("score_efetivo")
        needs_exp = data.get("needs_experiment", True)
        status = "⚠️ needs evidence" if needs_exp and sb is None else (
            "🔴 weak" if se is not None and se < 1.5 else
            "🟡 moderate" if se is not None and se < 3.0 else
            "🟢 strong" if se is not None else "—"
        )
        sb_str = f"{sb:.1f}" if sb is not None else "null"
        conf_str = f"{conf:.2f}" if conf is not None else "null"
        se_str = f"{se:.2f}" if se is not None else "null"
        rows.append(f"| {dim} | {sb_str} | {conf_str} | {se_str} | {status} |")
    return header + "\n".join(rows)


def format_blockers(blockers: list[dict]) -> str:
    if not blockers:
        return "_No blockers identified — all dimensions scored._\n"
    lines = []
    for i, b in enumerate(blockers, 1):
        dim = b["dimension"]
        btype = b["type"]
        se = b.get("score_efetivo")
        if btype == "missing_evidence":
            lines.append(
                f"### {i}. {dim} — No evidence (INSUFFICIENT_EVIDENCE)\n\n"
                f"- **Gap:** No `STATE/{dim}_*.json` evidence found. `score_bruto = null`.\n"
                f"- **Action:** Run `/idea-auditor:drill {dim}` to identify what to collect, "
                f"then run experiments from the drill output.\n"
            )
        else:
            se_str = f"{se:.2f}" if se is not None else "—"
            lines.append(
                f"### {i}. {dim} — Weak score (score_efetivo = {se_str})\n\n"
                f"- **Gap:** Low score_bruto or low confidence on this dimension.\n"
                f"- **Action:** Run `/idea-auditor:drill {dim}` for targeted experiments.\n"
            )
    return "\n".join(lines)


def build_report(scorecard: dict, evidence: dict | None, scorecard_filename: str = "scorecard.json") -> str:
    idea_path = scorecard.get("idea_path", "unknown")
    mode = scorecard.get("mode", "unknown")
    scored_at = scorecard.get("scored_at", date.today().isoformat())
    score_total = scorecard.get("score_total")
    conf_global = scorecard.get("confidence_global")
    decision = scorecard.get("decision", "INSUFFICIENT_EVIDENCE")
    dimensions = scorecard.get("dimensions", {})

    emoji = DECISION_EMOJI.get(decision, "❓")
    score_str = f"{score_total:.1f}/100" if score_total is not None else "—"
    conf_str = f"{conf_global:.2f}" if conf_global is not None else "—"
    conf_lbl = confidence_label(conf_global)

    blockers = derive_blockers(dimensions)

    lines = [
        f"# idea-auditor Report",
        f"",
        f"**Idea:** `{idea_path}`  ",
        f"**Mode:** {mode}  ",
        f"**Scored at:** {scored_at}  ",
        f"**Report generated:** {date.today().isoformat()}",
        f"",
        f"---",
        f"",
        f"## Decision: {emoji} {decision}",
        f"",
        f"| ScoreTotal | Confidence | Confidence Level |",
        f"|-----------|-----------|-----------------|",
        f"| {score_str} | {conf_str} | {conf_lbl} |",
        f"",
        f"---",
        f"",
        f"## Dimension Scores",
        f"",
        format_dimension_table(dimensions),
        f"",
        f"---",
        f"",
        f"## Top {len(blockers)} Blocker{'s' if len(blockers) != 1 else ''}",
        f"",
        format_blockers(blockers),
        f"",
        f"---",
        f"",
        f"## Next Steps",
        f"",
    ]

    if decision in ("ITERATE", "INSUFFICIENT_EVIDENCE"):
        lines += [
            f"1. Run `/idea-auditor:drill <weakest_dimension>` to design targeted experiments.",
            f"2. Run the experiments and record results in `STATE/`.",
            f"3. Re-run `/idea-auditor:score {idea_path} --mode {mode}` to update the scorecard.",
        ]
    elif decision == "PROCEED":
        lines += [
            f"Score and confidence meet PROCEED thresholds. Consider:",
            f"1. Reviewing blockers above for residual risk.",
            f"2. Defining your next-stage success criteria.",
            f"3. Committing to a 30-day build/launch plan.",
        ]
    else:  # KILL
        lines += [
            f"Score is below KILL threshold. Consider:",
            f"1. Re-examining the ICP — is there a narrower segment where wedge is stronger?",
            f"2. Running `/idea-auditor:drill wedge` to confirm if the pain is real.",
            f"3. Pivoting to a different problem framing.",
        ]

    # Evidence summary (if available)
    if evidence:
        lines += [
            f"",
            f"---",
            f"",
            f"## Evidence Summary",
            f"",
            f"Evidence graded from `STATE/`. Items per dimension:",
            f"",
        ]
        agg = evidence.get("aggregated_conf_by_dimension", {})
        for dim, conf in agg.items():
            conf_s = f"{conf:.2f}" if conf is not None else "—"
            lines.append(f"- **{dim}**: ConfDim = {conf_s} ({confidence_label(conf)} confidence)")

    lines.append(f"")
    lines.append(f"---")
    lines.append(f"_Report generated by `build_report.py`. Source of truth: `{scorecard_filename}`._")

    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate Markdown report from scorecard.")
    parser.add_argument("--scorecard", required=True, help="Path to scorecard JSON")
    parser.add_argument("--evidence", required=False, help="Path to graded evidence JSON (optional)")
    parser.add_argument("--out", required=False, help="Output report path (default: stdout)")
    args = parser.parse_args()

    scorecard_path = Path(args.scorecard)
    if not scorecard_path.exists():
        print(f"ERROR: scorecard not found: {args.scorecard}", file=sys.stderr)
        sys.exit(1)

    try:
        scorecard = json.loads(scorecard_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        print(f"ERROR: invalid scorecard JSON: {e}", file=sys.stderr)
        sys.exit(1)

    evidence = None
    if args.evidence:
        ev_path = Path(args.evidence)
        if ev_path.exists():
            try:
                evidence = json.loads(ev_path.read_text(encoding="utf-8"))
            except json.JSONDecodeError as e:
                print(f"WARN: could not parse evidence JSON: {e}", file=sys.stderr)
        else:
            print(f"WARN: evidence file not found: {args.evidence}", file=sys.stderr)

    report_md = build_report(scorecard, evidence, scorecard_filename=scorecard_path.name)

    if args.out:
        out_path = Path(args.out)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(report_md, encoding="utf-8")
        print(f"OK: report written to {args.out}")
    else:
        print(report_md)


if __name__ == "__main__":
    main()
