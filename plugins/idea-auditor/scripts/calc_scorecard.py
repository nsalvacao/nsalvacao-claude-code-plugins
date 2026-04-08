#!/usr/bin/env python3
"""calc_scorecard.py — Applies rubric weights and gates to produce a scorecard.

Rules:
  ScoreTotal = 100 * sum(weight_dim * score_efetivo_dim) for each dimension
  score_efetivo = score_bruto * confidence  (if either is None → null)
  Gates:
    PROCEED: ScoreTotal >= 70 AND confidence_global >= 0.6
    ITERATE: ScoreTotal >= 40 OR confidence_global < 0.6
    KILL/PAUSE: ScoreTotal < 40 AND no strong timing catalyst
    INSUFFICIENT_EVIDENCE: any required dimension has score=null

Usage:
  python3 calc_scorecard.py --idea IDEA.json --evidence evidence.json [--mode OSS_CLI]
  python3 calc_scorecard.py --scores '{"wedge":{"score_bruto":3,"confidence":0.8},...}' --mode B2B_SaaS
"""

import argparse
import json
import sys
from datetime import date
from pathlib import Path

WEIGHTS: dict[str, dict[str, float]] = {
    "OSS_CLI": {
        "wedge": 0.25,
        "friction": 0.20,
        "loop": 0.15,
        "timing": 0.15,
        "trust": 0.25,
    },
    "B2B_SaaS": {
        "wedge": 0.30,
        "friction": 0.25,
        "loop": 0.10,
        "timing": 0.15,
        "trust": 0.20,
    },
    "Consumer_Viral": {
        "wedge": 0.20,
        "friction": 0.20,
        "loop": 0.30,
        "timing": 0.20,
        "trust": 0.10,
    },
    "Infra_Fork_Standard": {
        "wedge": 0.20,
        "friction": 0.20,
        "loop": 0.10,
        "timing": 0.15,
        "trust": 0.20,
        "migration": 0.15,
    },
}

GATES = {
    "PROCEED": {"score_min": 70, "confidence_min": 0.6},
    "ITERATE": {"score_min": 40},
    "KILL": {"score_max": 40},
}


def decide(score_total: float | None, confidence_global: float | None, any_null: bool) -> str:
    if any_null:
        return "INSUFFICIENT_EVIDENCE"
    if score_total is None or confidence_global is None:
        return "INSUFFICIENT_EVIDENCE"
    if score_total >= 70 and confidence_global >= 0.6:
        return "PROCEED"
    if score_total >= 40:
        return "ITERATE"
    return "KILL"


def calc(dim_scores: dict[str, dict], mode: str) -> dict:
    weights = WEIGHTS.get(mode, WEIGHTS["OSS_CLI"])
    dimensions_out: dict = {}
    weighted_sum = 0.0
    total_weight = 0.0
    confidence_values: list[float] = []
    any_null = False

    for dim, w in weights.items():
        raw = dim_scores.get(dim, {})
        score_bruto = raw.get("score_bruto")
        confidence = raw.get("confidence")
        needs_experiment = score_bruto is None or confidence is None

        if needs_experiment or score_bruto is None or confidence is None:
            any_null = True
            score_efetivo = None
        else:
            score_efetivo = round(float(score_bruto) * float(confidence), 3)
            weighted_sum += w * score_efetivo
            total_weight += w
            confidence_values.append(float(confidence))

        dimensions_out[dim] = {
            "score_bruto": score_bruto,
            "confidence": confidence,
            "score_efetivo": score_efetivo,
            "needs_experiment": needs_experiment,
            "evidence_refs": raw.get("evidence_refs", []),
            "metrics": raw.get("metrics", []),
        }

    if total_weight > 0 and not any_null:
        score_total = round((weighted_sum / total_weight) * 20, 1)  # scale 0-5 → 0-100
        confidence_global = round(sum(confidence_values) / len(confidence_values), 3)
    else:
        score_total = None
        confidence_global = None

    decision = decide(score_total, confidence_global, any_null)

    return {
        "dimensions": dimensions_out,
        "score_total": score_total,
        "confidence_global": confidence_global,
        "decision": decision,
        "blockers": [],
        "next_tests": [],
    }


def main():
    parser = argparse.ArgumentParser(description="Calculate idea scorecard.")
    parser.add_argument("--scores", required=False, help="JSON string with dimension scores")
    parser.add_argument("--mode", required=False, default="OSS_CLI",
                        choices=list(WEIGHTS.keys()), help="Scoring mode")
    parser.add_argument("--idea", required=False, help="Path to IDEA.json")
    parser.add_argument("--evidence", required=False, help="Path to graded evidence JSON")
    parser.add_argument("--out", required=False, help="Output scorecard JSON path")
    args = parser.parse_args()

    # Resolve mode from IDEA if available
    mode = args.mode
    idea_path = None
    if args.idea:
        idea_path = args.idea
        try:
            idea_data = json.loads(Path(args.idea).read_text(encoding="utf-8"))
            mode = idea_data.get("mode", mode)
        except (json.JSONDecodeError, FileNotFoundError) as e:
            print(f"WARN: could not read IDEA file: {e}", file=sys.stderr)

    # Build dim_scores from --scores arg or evidence file
    dim_scores: dict = {}
    if args.scores:
        try:
            dim_scores = json.loads(args.scores)
        except json.JSONDecodeError as e:
            print(f"ERROR: invalid --scores JSON: {e}", file=sys.stderr)
            sys.exit(1)
    elif args.evidence:
        try:
            evidence_data = json.loads(Path(args.evidence).read_text(encoding="utf-8"))
            # Expect aggregated_conf_by_dimension from grade_evidence.py output
            agg = evidence_data.get("aggregated_conf_by_dimension", {})
            for dim, conf in agg.items():
                dim_scores[dim] = {"score_bruto": None, "confidence": conf}
        except (json.JSONDecodeError, FileNotFoundError) as e:
            print(f"ERROR: could not read evidence file: {e}", file=sys.stderr)
            sys.exit(1)

    result = calc(dim_scores, mode)
    scorecard = {
        "idea_path": idea_path or "unknown",
        "mode": mode,
        "scored_at": date.today().isoformat(),
        **result,
    }

    output_json = json.dumps(scorecard, indent=2, ensure_ascii=False)

    if args.out:
        out_path = Path(args.out)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(output_json, encoding="utf-8")
        print(f"OK: scorecard written to {args.out}")
    else:
        print(output_json)


if __name__ == "__main__":
    main()
