#!/usr/bin/env python3
"""diff_scorecards.py — Compare two scorecard JSONs and surface meaningful deltas.

Compares a 'before' scorecard against an 'after' scorecard produced by
calc_scorecard.py, reporting:
  - Score delta per dimension (score_bruto, confidence, score_efetivo)
  - Global score_total and confidence_global delta
  - Decision change (e.g. ITERATE → PROCEED)
  - Blockers resolved (needs_experiment True→False) vs newly introduced
  - Regression warning when score_total drops > REGRESSION_THRESHOLD points

Usage:
  python3 diff_scorecards.py --before STATE/scorecard_v1.json --after STATE/scorecard_v2.json
  python3 diff_scorecards.py --before old.json --after new.json --format json
  python3 diff_scorecards.py --before old.json --after new.json --format markdown

Output formats:
  markdown (default) — human-readable Markdown summary
  json               — machine-readable delta object
"""

import argparse
import json
import sys
from pathlib import Path

REGRESSION_THRESHOLD = 10  # points drop in score_total that triggers a warning (strictly > threshold)


def load(path: str) -> dict:
    p = Path(path)
    if not p.exists():
        sys.exit(f"File not found: {path}")
    try:
        data = json.loads(p.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        sys.exit(f"Invalid JSON in {path}: {exc}")
    if not isinstance(data, dict):
        sys.exit(f"Expected a JSON object in {path}")
    return data


def _delta(before: float | None, after: float | None) -> float | None:
    if before is None or after is None:
        return None
    return round(after - before, 4)


def _fmt_delta(val: float | None, precision: int = 2) -> str:
    if val is None:
        return "n/a"
    sign = "+" if val >= 0 else ""
    return f"{sign}{val:.{precision}f}"


def _fmt_val(val: float | None, precision: int = 2) -> str:
    if val is None:
        return "null"
    return f"{val:.{precision}f}"


def compute_diff(before: dict, after: dict) -> dict:
    dims_before: dict = before.get("dimensions", {})
    dims_after: dict = after.get("dimensions", {})

    dim_deltas: dict[str, dict] = {}
    blockers_resolved: list[str] = []
    blockers_new: list[str] = []

    all_dims = sorted(set(dims_before.keys()) | set(dims_after.keys()))
    for dim in all_dims:
        b = dims_before.get(dim)
        a = dims_after.get(dim)
        if b is None and a is None:
            continue

        b = b or {}
        a = a or {}

        sb_before = b.get("score_bruto")
        sb_after = a.get("score_bruto")
        conf_before = b.get("confidence")
        conf_after = a.get("confidence")
        se_before = b.get("score_efetivo")
        se_after = a.get("score_efetivo")
        ne_before = b.get("needs_experiment", False)
        ne_after = a.get("needs_experiment", False)

        if ne_before and not ne_after:
            blockers_resolved.append(dim)
        elif not ne_before and ne_after:
            blockers_new.append(dim)

        dim_deltas[dim] = {
            "score_bruto": {
                "before": sb_before,
                "after": sb_after,
                "delta": _delta(sb_before, sb_after),
            },
            "confidence": {
                "before": conf_before,
                "after": conf_after,
                "delta": _delta(conf_before, conf_after),
            },
            "score_efetivo": {
                "before": se_before,
                "after": se_after,
                "delta": _delta(se_before, se_after),
            },
            "needs_experiment": {
                "before": ne_before,
                "after": ne_after,
                "changed": ne_before != ne_after,
            },
        }

    st_before = before.get("score_total")
    st_after = after.get("score_total")
    cg_before = before.get("confidence_global")
    cg_after = after.get("confidence_global")
    dec_before = before.get("decision", "unknown")
    dec_after = after.get("decision", "unknown")

    st_delta = _delta(st_before, st_after)
    regression = st_delta is not None and st_delta < -REGRESSION_THRESHOLD

    return {
        "before_file": before.get("_source", "before"),
        "after_file": after.get("_source", "after"),
        "mode": after.get("mode", before.get("mode", "unknown")),
        "scored_at": {"before": before.get("scored_at"), "after": after.get("scored_at")},
        "score_total": {
            "before": st_before,
            "after": st_after,
            "delta": st_delta,
        },
        "confidence_global": {
            "before": cg_before,
            "after": cg_after,
            "delta": _delta(cg_before, cg_after),
        },
        "decision": {
            "before": dec_before,
            "after": dec_after,
            "changed": dec_before != dec_after,
        },
        "blockers_resolved": blockers_resolved,
        "blockers_new": blockers_new,
        "regression": regression,
        "dimensions": dim_deltas,
    }


def render_markdown(diff: dict) -> str:
    lines: list[str] = []
    lines.append("# Scorecard Diff")
    lines.append("")

    st = diff["score_total"]
    cg = diff["confidence_global"]
    dec = diff["decision"]

    if diff["regression"]:
        lines.append(
            f"> **REGRESSION WARNING** — score_total dropped "
            f"{_fmt_delta(st['delta'])} points (threshold: -{REGRESSION_THRESHOLD})"
        )
        lines.append("")

    lines.append("## Summary")
    lines.append("")
    lines.append(f"| Metric | Before | After | Delta |")
    lines.append(f"|--------|--------|-------|-------|")
    lines.append(
        f"| score_total | {_fmt_val(st['before'])} | {_fmt_val(st['after'])} "
        f"| **{_fmt_delta(st['delta'])}** |"
    )
    lines.append(
        f"| confidence_global | {_fmt_val(cg['before'], 3)} | {_fmt_val(cg['after'], 3)} "
        f"| {_fmt_delta(cg['delta'], 3)} |"
    )
    lines.append(
        f"| decision | `{dec['before']}` | `{dec['after']}` "
        f"| {'**changed**' if dec['changed'] else '—'} |"
    )
    lines.append("")

    if diff["blockers_resolved"] or diff["blockers_new"]:
        lines.append("## Blocker Changes")
        lines.append("")
        for dim in diff["blockers_resolved"]:
            lines.append(f"- **Resolved**: `{dim}` no longer needs an experiment")
        for dim in diff["blockers_new"]:
            lines.append(f"- **New blocker**: `{dim}` now requires an experiment")
        lines.append("")

    lines.append("## Dimension Deltas")
    lines.append("")
    lines.append(
        "| Dimension | score_bruto (Δ) | confidence (Δ) | score_efetivo (Δ) | experiment? |"
    )
    lines.append("|-----------|-----------------|----------------|-------------------|-------------|")

    for dim, d in diff["dimensions"].items():
        sb = d["score_bruto"]
        conf = d["confidence"]
        se = d["score_efetivo"]
        ne_after = d["needs_experiment"]["after"]
        ne_changed = d["needs_experiment"]["changed"]
        ne_cell = ("⚠️ yes" if ne_after else "no") + (" *(changed)*" if ne_changed else "")

        lines.append(
            f"| {dim} "
            f"| {_fmt_val(sb['before'])} → {_fmt_val(sb['after'])} ({_fmt_delta(sb['delta'])}) "
            f"| {_fmt_val(conf['before'], 3)} → {_fmt_val(conf['after'], 3)} ({_fmt_delta(conf['delta'], 3)}) "
            f"| {_fmt_val(se['before'])} → {_fmt_val(se['after'])} ({_fmt_delta(se['delta'])}) "
            f"| {ne_cell} |"
        )

    lines.append("")
    lines.append(
        f"_Diff: `{diff['before_file']}` → `{diff['after_file']}` "
        f"({diff['scored_at']['before']} → {diff['scored_at']['after']})_"
    )
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--before", required=True, help="Path to the earlier scorecard JSON")
    parser.add_argument("--after", required=True, help="Path to the later scorecard JSON")
    parser.add_argument(
        "--format",
        choices=["markdown", "json"],
        default="markdown",
        help="Output format (default: markdown)",
    )
    args = parser.parse_args()

    before = load(args.before)
    before["_source"] = args.before
    after = load(args.after)
    after["_source"] = args.after

    diff = compute_diff(before, after)

    if args.format == "json":
        print(json.dumps(diff, indent=2, ensure_ascii=False))
    else:
        print(render_markdown(diff))

    if diff["regression"]:
        sys.exit(2)


if __name__ == "__main__":
    main()
