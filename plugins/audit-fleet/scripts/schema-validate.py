#!/usr/bin/env python3
"""Validate audit-fleet markdown reports and JSON contracts."""

from __future__ import annotations

import argparse
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

REQUIRED_SECTION_ORDER = [
    "Executive Summary",
    "Findings",
    "Quick Wins",
    "High-Impact Expansions",
]

REQUIRED_FINDING_KEYS = [
    "finding_id",
    "severity",
    "dimension",
    "evidence",
    "impact",
    "recommendation",
    "effort",
    "owner",
    "dependencies",
    "confidence",
    "acceptance_criteria",
]

ALLOWED_SEVERITY = {"critical", "warning", "info"}
ALLOWED_CONFIDENCE = {"high", "medium", "low"}
ALLOWED_EFFORT = {"S", "M", "L"}


def fail(message: str, code: int = 1) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(code)


def parse_args() -> argparse.Namespace:
    root = Path(__file__).resolve().parent.parent
    parser = argparse.ArgumentParser(
        description="Validate markdown section contract and JSON report/bundle structure."
    )
    parser.add_argument(
        "--reports-dir",
        default=".audit-fleet/reports",
        help="Directory with markdown reports (default: .audit-fleet/reports)",
    )
    parser.add_argument(
        "--json-dir",
        default=".audit-fleet/reports-json",
        help="Directory with per-report JSON files (default: .audit-fleet/reports-json)",
    )
    parser.add_argument(
        "--bundle",
        default=".audit-fleet/audit-bundle.json",
        help="Path to bundle JSON file (default: .audit-fleet/audit-bundle.json)",
    )
    parser.add_argument(
        "--report-schema",
        default=str(root / "schemas" / "report.schema.json"),
        help="Path to report schema JSON",
    )
    parser.add_argument(
        "--bundle-schema",
        default=str(root / "schemas" / "bundle.schema.json"),
        help="Path to bundle schema JSON",
    )
    parser.add_argument(
        "--mode",
        choices=("strict", "balanced"),
        default="balanced",
        help="Validation mode (default: balanced)",
    )
    parser.add_argument(
        "--output",
        default=".audit-fleet/validation-result.json",
        help="Output JSON path (default: .audit-fleet/validation-result.json)",
    )
    return parser.parse_args()


def normalize_heading(value: str) -> str:
    return re.sub(r"\s+", " ", value.strip().lower())


def load_json(path: Path, label: str) -> dict[str, Any]:
    if not path.exists():
        fail(f"{label} file not found: {path}")
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except OSError as exc:
        fail(f"cannot read {label} file {path}: {exc}")
    except json.JSONDecodeError as exc:
        fail(f"invalid JSON in {label} file {path}: {exc}")

    if not isinstance(payload, dict):
        fail(f"{label} payload must be a JSON object: {path}")
    return payload


def write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    try:
        path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    except OSError as exc:
        fail(f"cannot write output file {path}: {exc}")


def check_markdown_sections(path: Path, mode: str, errors: list[str], warnings: list[str]) -> None:
    try:
        text = path.read_text(encoding="utf-8")
    except OSError as exc:
        errors.append(f"{path.name}: cannot read markdown file: {exc}")
        return

    lines = text.splitlines()
    section_titles: list[str] = []
    for line in lines:
        match = re.match(r"^##\s+(.+?)\s*$", line)
        if match:
            section_titles.append(match.group(1).strip())

    expected_norm = [normalize_heading(section) for section in REQUIRED_SECTION_ORDER]
    found_norm = [normalize_heading(section) for section in section_titles]

    missing_sections = [
        section for section in REQUIRED_SECTION_ORDER if normalize_heading(section) not in found_norm
    ]
    if missing_sections:
        errors.append(f"{path.name}: missing sections: {', '.join(missing_sections)}")

    ordered = [value for value in found_norm if value in expected_norm]
    order_ok = ordered == expected_norm
    if not order_ok:
        message = (
            f"{path.name}: section order mismatch. "
            f"Expected {REQUIRED_SECTION_ORDER}, found {section_titles}"
        )
        if mode == "strict":
            errors.append(message)
        else:
            warnings.append(message)


def validate_finding_payload(
    finding: Any,
    source: str,
    mode: str,
    errors: list[str],
    warnings: list[str],
) -> None:
    if not isinstance(finding, dict):
        errors.append(f"{source}: finding must be an object")
        return

    keys = set(finding.keys())
    required = set(REQUIRED_FINDING_KEYS)

    missing = sorted(list(required - keys))
    extras = sorted(list(keys - required))

    if missing:
        errors.append(f"{source}: missing finding keys: {', '.join(missing)}")
    if extras:
        message = f"{source}: unexpected finding keys: {', '.join(extras)}"
        if mode == "strict":
            errors.append(message)
        else:
            warnings.append(message)

    if missing:
        return

    for key in REQUIRED_FINDING_KEYS:
        if key == "dependencies":
            continue
        value = finding.get(key)
        if not isinstance(value, str) or not value.strip():
            errors.append(f"{source}: '{key}' must be a non-empty string")

    dependencies = finding.get("dependencies")
    if not isinstance(dependencies, list):
        errors.append(f"{source}: 'dependencies' must be an array")
    elif not all(isinstance(item, str) and item.strip() for item in dependencies):
        errors.append(f"{source}: dependencies entries must be non-empty strings")

    severity = finding.get("severity")
    if isinstance(severity, str) and severity not in ALLOWED_SEVERITY:
        errors.append(f"{source}: invalid severity '{severity}'")

    confidence = finding.get("confidence")
    if isinstance(confidence, str) and confidence not in ALLOWED_CONFIDENCE:
        errors.append(f"{source}: invalid confidence '{confidence}'")

    effort = finding.get("effort")
    if isinstance(effort, str) and effort not in ALLOWED_EFFORT:
        errors.append(f"{source}: invalid effort '{effort}'")


def validate_report_payload(
    payload: Any,
    source: str,
    required_fields: list[str],
    mode: str,
    errors: list[str],
    warnings: list[str],
) -> str | None:
    if not isinstance(payload, dict):
        errors.append(f"{source}: report payload must be an object")
        return None

    for field in required_fields:
        if field not in payload:
            errors.append(f"{source}: missing required field '{field}'")

    report_id = payload.get("report_id")
    if not isinstance(report_id, str) or not report_id.strip():
        errors.append(f"{source}: report_id must be a non-empty string")
        report_id = None

    mode_value = payload.get("mode")
    if mode_value not in ("strict", "balanced"):
        errors.append(f"{source}: mode must be strict or balanced")

    section_order = payload.get("section_order")
    if section_order != REQUIRED_SECTION_ORDER:
        message = (
            f"{source}: section_order must equal {REQUIRED_SECTION_ORDER}, "
            f"found {section_order}"
        )
        if mode == "strict":
            errors.append(message)
        else:
            warnings.append(message)

    sections = payload.get("sections")
    if not isinstance(sections, dict):
        errors.append(f"{source}: sections must be an object")
    else:
        for required in REQUIRED_SECTION_ORDER:
            if required not in sections:
                errors.append(f"{source}: sections missing '{required}'")

    findings = payload.get("findings")
    if not isinstance(findings, list):
        errors.append(f"{source}: findings must be an array")
    else:
        for idx, finding in enumerate(findings):
            validate_finding_payload(
                finding,
                source=f"{source}.findings[{idx}]",
                mode=mode,
                errors=errors,
                warnings=warnings,
            )

    for list_field in ("quick_wins", "high_impact_expansions"):
        value = payload.get(list_field)
        if not isinstance(value, list):
            errors.append(f"{source}: {list_field} must be an array")
        elif not all(isinstance(item, str) and item.strip() for item in value):
            errors.append(f"{source}: {list_field} entries must be non-empty strings")

    finding_count = payload.get("finding_count")
    if isinstance(findings, list):
        if not isinstance(finding_count, int):
            errors.append(f"{source}: finding_count must be an integer")
        elif finding_count != len(findings):
            errors.append(
                f"{source}: finding_count ({finding_count}) does not match findings length ({len(findings)})"
            )

    totals = payload.get("totals")
    if not isinstance(totals, dict):
        errors.append(f"{source}: totals must be an object")
    else:
        by_severity = totals.get("by_severity")
        if not isinstance(by_severity, dict):
            errors.append(f"{source}: totals.by_severity must be an object")
        else:
            for key in ("critical", "warning", "info"):
                value = by_severity.get(key)
                if not isinstance(value, int) or value < 0:
                    errors.append(f"{source}: totals.by_severity.{key} must be a non-negative integer")

    return report_id


def main() -> None:
    args = parse_args()

    reports_dir = Path(args.reports_dir).expanduser()
    json_dir = Path(args.json_dir).expanduser()
    bundle_path = Path(args.bundle).expanduser()
    output_path = Path(args.output).expanduser()

    report_schema = load_json(Path(args.report_schema).expanduser(), "report schema")
    bundle_schema = load_json(Path(args.bundle_schema).expanduser(), "bundle schema")

    report_required = report_schema.get("required")
    bundle_required = bundle_schema.get("required")
    if not isinstance(report_required, list) or not all(isinstance(item, str) for item in report_required):
        fail("report schema must contain a 'required' string array")
    if not isinstance(bundle_required, list) or not all(isinstance(item, str) for item in bundle_required):
        fail("bundle schema must contain a 'required' string array")

    errors: list[str] = []
    warnings: list[str] = []

    if not reports_dir.exists() or not reports_dir.is_dir():
        fail(f"reports directory not found: {reports_dir}")
    if not json_dir.exists() or not json_dir.is_dir():
        fail(f"json directory not found: {json_dir}")

    markdown_names = sorted([path.name for path in reports_dir.glob("*.md")])
    json_names = sorted([path.name for path in json_dir.glob("*.json")])

    required_set = set(REQUIRED_REPORT_FILES)
    markdown_set = set(markdown_names)
    json_expected = set([f"{Path(name).stem}.json" for name in REQUIRED_REPORT_FILES])
    json_set = set(json_names)

    missing_markdown = sorted(list(required_set - markdown_set))
    unexpected_markdown = sorted(list(markdown_set - required_set))
    missing_json = sorted(list(json_expected - json_set))
    unexpected_json = sorted(list(json_set - json_expected))

    if missing_markdown:
        errors.append("missing markdown reports: " + ", ".join(missing_markdown))
    if missing_json:
        errors.append("missing JSON report mirrors: " + ", ".join(missing_json))

    if unexpected_markdown:
        message = "unexpected markdown reports: " + ", ".join(unexpected_markdown)
        if args.mode == "strict":
            errors.append(message)
        else:
            warnings.append(message)

    if unexpected_json:
        message = "unexpected JSON reports: " + ", ".join(unexpected_json)
        if args.mode == "strict":
            errors.append(message)
        else:
            warnings.append(message)

    for report_name in REQUIRED_REPORT_FILES:
        report_path = reports_dir / report_name
        if report_path.exists():
            check_markdown_sections(report_path, args.mode, errors, warnings)

    json_report_ids: list[str] = []
    for report_name in REQUIRED_REPORT_FILES:
        report_id = Path(report_name).stem
        report_json = json_dir / f"{report_id}.json"
        if not report_json.exists():
            continue
        payload = load_json(report_json, f"report JSON {report_json.name}")
        parsed_report_id = validate_report_payload(
            payload,
            source=report_json.name,
            required_fields=report_required,
            mode=args.mode,
            errors=errors,
            warnings=warnings,
        )
        if parsed_report_id is not None:
            if parsed_report_id != report_id:
                errors.append(
                    f"{report_json.name}: report_id '{parsed_report_id}' must match filename stem '{report_id}'"
                )
            json_report_ids.append(parsed_report_id)

    bundle_payload = load_json(bundle_path, "bundle")
    for field in bundle_required:
        if field not in bundle_payload:
            errors.append(f"bundle: missing required field '{field}'")

    bundle_reports = bundle_payload.get("reports")
    if not isinstance(bundle_reports, list):
        errors.append("bundle.reports must be an array")
        bundle_reports = []

    bundle_report_ids: list[str] = []
    for idx, report in enumerate(bundle_reports):
        parsed_id = validate_report_payload(
            report,
            source=f"bundle.reports[{idx}]",
            required_fields=report_required,
            mode=args.mode,
            errors=errors,
            warnings=warnings,
        )
        if parsed_id is not None:
            bundle_report_ids.append(parsed_id)

    required_reports_value = bundle_payload.get("required_reports")
    if required_reports_value != REQUIRED_REPORT_FILES:
        message = "bundle.required_reports must match fixed contract list exactly"
        if args.mode == "strict":
            errors.append(message)
        else:
            warnings.append(message)

    report_count = bundle_payload.get("report_count")
    if not isinstance(report_count, int):
        errors.append("bundle.report_count must be an integer")
    elif report_count != len(bundle_reports):
        errors.append(
            f"bundle.report_count ({report_count}) does not match reports length ({len(bundle_reports)})"
        )

    totals = bundle_payload.get("totals")
    if not isinstance(totals, dict):
        errors.append("bundle.totals must be an object")
    else:
        by_severity = totals.get("by_severity")
        findings_total = totals.get("findings_total")
        if not isinstance(by_severity, dict):
            errors.append("bundle.totals.by_severity must be an object")
        else:
            expected_counts = {"critical": 0, "warning": 0, "info": 0}
            for report in bundle_reports:
                if isinstance(report, dict):
                    report_totals = report.get("totals", {})
                    if isinstance(report_totals, dict):
                        report_by_sev = report_totals.get("by_severity", {})
                        if isinstance(report_by_sev, dict):
                            for key in expected_counts:
                                value = report_by_sev.get(key, 0)
                                if isinstance(value, int):
                                    expected_counts[key] += value

            for key in expected_counts:
                value = by_severity.get(key)
                if not isinstance(value, int) or value < 0:
                    errors.append(f"bundle.totals.by_severity.{key} must be a non-negative integer")
                elif value != expected_counts[key]:
                    errors.append(
                        f"bundle.totals.by_severity.{key} ({value}) does not match aggregated value ({expected_counts[key]})"
                    )

            expected_total = sum(expected_counts.values())
            if not isinstance(findings_total, int):
                errors.append("bundle.totals.findings_total must be an integer")
            elif findings_total != expected_total:
                errors.append(
                    f"bundle.totals.findings_total ({findings_total}) does not match aggregated value ({expected_total})"
                )

    expected_ids = sorted([Path(name).stem for name in REQUIRED_REPORT_FILES])
    if sorted(json_report_ids) != expected_ids:
        errors.append(
            "JSON report IDs do not match required IDs: "
            f"expected={expected_ids}, got={sorted(json_report_ids)}"
        )
    if sorted(bundle_report_ids) != expected_ids:
        errors.append(
            "Bundle report IDs do not match required IDs: "
            f"expected={expected_ids}, got={sorted(bundle_report_ids)}"
        )

    ok = not errors and (args.mode == "balanced" or not warnings)

    result = {
        "ok": ok,
        "mode": args.mode,
        "reports_dir": str(reports_dir),
        "json_dir": str(json_dir),
        "bundle": str(bundle_path),
        "required_reports": REQUIRED_REPORT_FILES,
        "missing_markdown": missing_markdown,
        "missing_json": missing_json,
        "unexpected_markdown": unexpected_markdown,
        "unexpected_json": unexpected_json,
        "errors": errors,
        "warnings": warnings,
    }

    write_json(output_path, result)
    print(json.dumps(result, indent=2, sort_keys=True))

    if not ok:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
