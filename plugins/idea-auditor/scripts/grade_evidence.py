#!/usr/bin/env python3
"""grade_evidence.py — Calculates ConfDim per evidence item and per dimension.

Formula (per dimension):
  ConfDim = clamp(0, 1, 0.2*SourceDiversity + 0.3*Recency + 0.3*Commitment + 0.2*Consistency)

Usage:
  python3 grade_evidence.py --evidence <path_to_evidence_json_or_dir>
  python3 grade_evidence.py --evidence STATE/interviews.json --dimension wedge
"""

import argparse
import json
import sys
from datetime import date
from pathlib import Path


def clamp(value: float, lo: float, hi: float) -> float:
    return max(lo, min(hi, value))


def score_recency(collected_at: str) -> float:
    """Score recency: 1.0 = this month, 0.5 = within 6mo, 0.2 = older, 0.0 = unknown."""
    try:
        collected = date.fromisoformat(collected_at)
        delta_days = (date.today() - collected).days
        if delta_days <= 30:
            return 1.0
        elif delta_days <= 180:
            return 0.7
        elif delta_days <= 365:
            return 0.4
        else:
            return 0.2
    except (ValueError, TypeError):
        return 0.0


def score_commitment(quality_tier: str) -> float:
    """Map quality tier to commitment score."""
    mapping = {
        "commitment": 1.0,
        "behavioral": 0.75,
        "stated": 0.5,
        "proxy": 0.3,
        "assumption": 0.0,
    }
    return mapping.get(quality_tier, 0.0)


def grade_single(item: dict) -> dict:
    """Grade a single evidence item and return updated item with confidence_components."""
    components = item.get("confidence_components", {})

    recency = score_recency(item.get("collected_at", ""))
    commitment = score_commitment(item.get("quality_tier", "assumption"))

    # Source diversity and consistency are set by the caller or default to 0.5
    source_diversity = components.get("source_diversity", 0.5)
    consistency = components.get("consistency", 0.5)

    conf_dim = clamp(
        0.2 * source_diversity + 0.3 * recency + 0.3 * commitment + 0.2 * consistency,
        0.0,
        1.0,
    )

    item["confidence_components"] = {
        "source_diversity": source_diversity,
        "recency": recency,
        "commitment": commitment,
        "consistency": consistency,
        "conf_dim": round(conf_dim, 3),
    }
    return item


def grade_file(path: Path, dimension_filter: str | None = None) -> dict:
    if not path.exists():
        print(f"ERROR: file not found: {path}", file=sys.stderr)
        sys.exit(1)

    data = json.loads(path.read_text(encoding="utf-8"))
    items = data if isinstance(data, list) else [data]

    graded = [grade_single(item) for item in items]

    # Aggregate ConfDim per dimension
    dim_scores: dict[str, list[float]] = {}
    for item in graded:
        dim = item.get("dimension", "unknown")
        if dimension_filter and dim != dimension_filter:
            continue
        conf = item.get("confidence_components", {}).get("conf_dim")
        if conf is not None:
            dim_scores.setdefault(dim, []).append(conf)

    aggregated = {
        dim: round(sum(scores) / len(scores), 3)
        for dim, scores in dim_scores.items()
    }

    return {"items": graded, "aggregated_conf_by_dimension": aggregated}


def main():
    parser = argparse.ArgumentParser(description="Grade evidence confidence.")
    parser.add_argument("--evidence", required=True, help="Path to evidence JSON file or dir")
    parser.add_argument("--dimension", required=False, help="Filter by dimension")
    parser.add_argument("--out", required=False, help="Output file (default: stdout)")
    args = parser.parse_args()

    path = Path(args.evidence)
    if path.is_dir():
        all_results: dict = {"files": {}, "aggregated_conf_by_dimension": {}}
        for f in sorted(path.glob("*.json")):
            result = grade_file(f, args.dimension)
            all_results["files"][f.name] = result["items"]
            for dim, score in result["aggregated_conf_by_dimension"].items():
                prev = all_results["aggregated_conf_by_dimension"].get(dim, [])
                all_results["aggregated_conf_by_dimension"][dim] = prev + [score]
        # Average across files
        all_results["aggregated_conf_by_dimension"] = {
            dim: round(sum(v) / len(v), 3) if v else 0.0
            for dim, v in all_results["aggregated_conf_by_dimension"].items()
        }
        output = all_results
    else:
        output = grade_file(path, args.dimension)

    result_json = json.dumps(output, indent=2, ensure_ascii=False)

    if args.out:
        Path(args.out).write_text(result_json, encoding="utf-8")
        print(f"OK: graded evidence written to {args.out}")
    else:
        print(result_json)


if __name__ == "__main__":
    main()
