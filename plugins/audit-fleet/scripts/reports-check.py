#!/usr/bin/env python3
"""Preflight inventory checks for deterministic audit-fleet report files."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path
from typing import Any

REQUIRED_REPORT_FILES = [
    "00-executive-summary.md",
    "01-solution-auditor.md",
    "02-coherence-analyzer.md",
    "03-architect-review.md",
    "04-security-auditor.md",
    "05-test-engineer.md",
    "06-devops.md",
    "07-deployment-engineer.md",
    "08-ux-reviewer.md",
    "09-business-analyst.md",
    "10-architect-roadmap.md",
    "11-evolution-audit.md",
    "12-documentation-auditor.md",
    "13-cost-efficiency-auditor.md",
]
REQUIRED_SECTIONS = [
    "Executive Summary",
    "Findings",
    "Quick Wins",
    "High-Impact Expansions",
]


def fail(message: str, code: int = 1) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(code)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Check deterministic audit-fleet report inventory and section contract."
    )
    parser.add_argument(
        "--reports-dir",
        default=".audit-fleet/reports",
        help="Directory containing markdown report files (default: .audit-fleet/reports)",
    )
    parser.add_argument(
        "--mode",
        choices=("strict", "balanced"),
        default="balanced",
        help="Validation mode (default: balanced)",
    )
    parser.add_argument(
        "--output",
        default=".audit-fleet/reports-check.json",
        help="Output JSON file (default: .audit-fleet/reports-check.json)",
    )
    return parser.parse_args()


def sha256_text(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def normalize_heading(value: str) -> str:
    return re.sub(r"\s+", " ", value.strip().lower())


def extract_level2_sections(lines: list[str]) -> list[str]:
    sections: list[str] = []
    for line in lines:
        match = re.match(r"^##\s+(.+?)\s*$", line)
        if match:
            sections.append(match.group(1).strip())
    return sections


def write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    try:
        path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    except OSError as exc:
        fail(f"cannot write output file {path}: {exc}")


def main() -> None:
    args = parse_args()
    reports_dir = Path(args.reports_dir).expanduser()
    output_path = Path(args.output).expanduser()

    if not reports_dir.exists():
        fail(f"reports directory not found: {reports_dir}")
    if not reports_dir.is_dir():
        fail(f"reports path is not a directory: {reports_dir}")

    markdown_files = sorted(reports_dir.glob("*.md"))
    present_names = {path.name for path in markdown_files}
    required_names = set(REQUIRED_REPORT_FILES)

    missing_reports = sorted(list(required_names - present_names))
    unexpected_reports = sorted(list(present_names - required_names))

    errors: list[str] = []
    warnings: list[str] = []
    checks: list[dict[str, Any]] = []

    if missing_reports:
        errors.append("missing required reports: " + ", ".join(missing_reports))

    if unexpected_reports:
        message = "unexpected report files: " + ", ".join(unexpected_reports)
        if args.mode == "strict":
            errors.append(message)
        else:
            warnings.append(message)

    expected_section_norm = [normalize_heading(name) for name in REQUIRED_SECTIONS]

    for report_name in REQUIRED_REPORT_FILES:
        report_path = reports_dir / report_name
        item: dict[str, Any] = {
            "file": report_name,
            "exists": report_path.exists(),
        }

        if not report_path.exists():
            checks.append(item)
            continue

        try:
            text = report_path.read_text(encoding="utf-8")
        except OSError as exc:
            errors.append(f"{report_name}: cannot read file: {exc}")
            checks.append(item)
            continue

        lines = text.splitlines()
        sections = extract_level2_sections(lines)
        sections_norm = [normalize_heading(section) for section in sections]

        missing_sections = [
            section for section in REQUIRED_SECTIONS if normalize_heading(section) not in sections_norm
        ]
        if missing_sections:
            errors.append(f"{report_name}: missing sections: {', '.join(missing_sections)}")

        recognized_order = [
            section for section in sections_norm if section in expected_section_norm
        ]
        order_ok = recognized_order == expected_section_norm
        if not order_ok:
            message = (
                f"{report_name}: section order mismatch. "
                f"Expected {REQUIRED_SECTIONS}, found {sections}"
            )
            if args.mode == "strict":
                errors.append(message)
            else:
                warnings.append(message)

        item.update(
            {
                "size_bytes": len(text.encode("utf-8")),
                "sha256": sha256_text(text),
                "sections": sections,
                "missing_sections": missing_sections,
                "section_order_ok": order_ok,
            }
        )
        checks.append(item)

    ok = not errors and (args.mode == "balanced" or not warnings)
    result = {
        "ok": ok,
        "mode": args.mode,
        "reports_dir": str(reports_dir),
        "required_reports": REQUIRED_REPORT_FILES,
        "present_reports": sorted(list(present_names)),
        "missing_reports": missing_reports,
        "unexpected_reports": unexpected_reports,
        "checks": checks,
        "errors": errors,
        "warnings": warnings,
    }

    write_json(output_path, result)
    print(json.dumps(result, indent=2, sort_keys=True))

    if not ok:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
