#!/usr/bin/env python3
"""Mirror deterministic audit-fleet markdown reports to JSON artifacts."""

from __future__ import annotations

import argparse
import json
import re
import sys
from datetime import datetime, timezone
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


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def fail(message: str, code: int = 1) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(code)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate per-report JSON and audit-bundle.json from fixed audit-fleet markdown reports."
    )
    parser.add_argument(
        "--reports-dir",
        default=".audit-fleet/reports",
        help="Directory containing markdown reports (default: .audit-fleet/reports)",
    )
    parser.add_argument(
        "--out-dir",
        default=".audit-fleet",
        help="Output directory for reports-json and audit-bundle.json (default: .audit-fleet)",
    )
    parser.add_argument(
        "--mode",
        choices=("strict", "balanced"),
        default="balanced",
        help="Validation mode while mirroring (default: balanced)",
    )
    return parser.parse_args()


def normalize_heading(value: str) -> str:
    return re.sub(r"\s+", " ", value.strip().lower())


def normalize_key(value: str) -> str:
    normalized = value.strip().lower().replace("-", "_")
    normalized = re.sub(r"[^a-z0-9_]+", "_", normalized)
    normalized = re.sub(r"_+", "_", normalized).strip("_")
    return normalized


def split_pipe_row(line: str) -> list[str]:
    stripped = line.strip()
    if stripped.startswith("|"):
        stripped = stripped[1:]
    if stripped.endswith("|"):
        stripped = stripped[:-1]
    return [cell.strip() for cell in stripped.split("|")]


def parse_markdown_sections(text: str) -> tuple[str, dict[str, str], list[str]]:
    lines = text.splitlines()
    title = ""

    heading_matches: list[tuple[int, str, int]] = []
    for idx, line in enumerate(lines):
        h1 = re.match(r"^#\s+(.+?)\s*$", line)
        if h1 and not title:
            title = h1.group(1).strip()

        h2 = re.match(r"^##\s+(.+?)\s*$", line)
        if h2:
            heading_matches.append((idx, h2.group(1).strip(), idx))

    sections: dict[str, str] = {}
    section_order: list[str] = []
    expected_map = {normalize_heading(name): name for name in REQUIRED_SECTION_ORDER}

    for i, (_, heading, start_idx) in enumerate(heading_matches):
        norm = normalize_heading(heading)
        if norm not in expected_map:
            continue
        canonical = expected_map[norm]
        end_idx = len(lines)
        if i + 1 < len(heading_matches):
            end_idx = heading_matches[i + 1][0]
        body = "\n".join(lines[start_idx + 1 : end_idx]).strip()
        sections[canonical] = body
        section_order.append(canonical)

    return title, sections, section_order


def parse_json_findings_block(text: str) -> tuple[list[dict[str, Any]] | None, list[str]]:
    warnings: list[str] = []
    blocks = re.findall(r"```json\s*(.*?)```", text, flags=re.DOTALL | re.IGNORECASE)
    if not blocks:
        return None, warnings

    for block in blocks:
        try:
            payload = json.loads(block.strip())
        except json.JSONDecodeError as exc:
            warnings.append(f"invalid JSON findings block: {exc}")
            continue

        if isinstance(payload, dict) and isinstance(payload.get("findings"), list):
            return payload["findings"], warnings
        if isinstance(payload, list):
            return payload, warnings

        warnings.append("JSON findings block must be an array or {'findings': [...]} object")

    return None, warnings


def parse_table_findings(text: str) -> tuple[list[dict[str, Any]] | None, str | None]:
    lines = [line for line in text.splitlines() if line.strip()]
    for idx, line in enumerate(lines):
        if not line.strip().startswith("|"):
            continue
        if idx + 1 >= len(lines):
            continue
        sep_line = lines[idx + 1].strip()
        if not re.match(r"^\|?\s*:?-{3,}:?\s*(\|\s*:?-{3,}:?\s*)+\|?$", sep_line):
            continue

        headers_raw = split_pipe_row(line)
        header_keys = [normalize_key(cell) for cell in headers_raw]

        rows: list[dict[str, Any]] = []
        row_idx = idx + 2
        while row_idx < len(lines):
            row_line = lines[row_idx]
            if not row_line.strip().startswith("|"):
                break
            cells = split_pipe_row(row_line)
            if len(cells) != len(header_keys):
                break
            if all(re.fullmatch(r":?-{3,}:?", cell.replace(" ", "")) for cell in cells):
                row_idx += 1
                continue
            row = {header_keys[col]: cells[col].strip() for col in range(len(header_keys))}
            if any(value for value in row.values()):
                rows.append(row)
            row_idx += 1

        if rows:
            return rows, None
        return [], None

    return None, "no markdown findings table found"


def parse_dependencies(value: Any) -> list[str]:
    if isinstance(value, list):
        output = []
        for item in value:
            if isinstance(item, str) and item.strip():
                output.append(item.strip())
        return sorted(list(set(output)))

    if isinstance(value, str):
        text = value.strip()
        if not text or text.lower() in {"none", "n/a", "-"}:
            return []
        parts = re.split(r"[,;|]", text)
        output = [part.strip() for part in parts if part.strip()]
        return sorted(list(set(output)))

    return []


def normalize_finding(
    raw: dict[str, Any],
    source: str,
    mode: str,
    errors: list[str],
    warnings: list[str],
) -> dict[str, Any] | None:
    if not isinstance(raw, dict):
        errors.append(f"{source}: finding entry must be an object")
        return None

    normalized = {normalize_key(str(key)): value for key, value in raw.items()}
    missing = [key for key in REQUIRED_FINDING_KEYS if key not in normalized]
    if missing:
        errors.append(f"{source}: missing finding keys: {', '.join(missing)}")
        return None

    extras = sorted([key for key in normalized.keys() if key not in REQUIRED_FINDING_KEYS])
    if extras:
        message = f"{source}: extra finding keys ignored: {', '.join(extras)}"
        if mode == "strict":
            errors.append(message)
        else:
            warnings.append(message)

    finding_id = str(normalized["finding_id"]).strip()
    severity = str(normalized["severity"]).strip().lower()
    dimension = str(normalized["dimension"]).strip()
    evidence = str(normalized["evidence"]).strip()
    impact = str(normalized["impact"]).strip()
    recommendation = str(normalized["recommendation"]).strip()
    effort = str(normalized["effort"]).strip().upper()
    owner = str(normalized["owner"]).strip()
    confidence = str(normalized["confidence"]).strip().lower()

    acceptance_value = normalized["acceptance_criteria"]
    if isinstance(acceptance_value, list):
        acceptance_criteria = "; ".join([str(item).strip() for item in acceptance_value if str(item).strip()])
    else:
        acceptance_criteria = str(acceptance_value).strip()

    dependencies = parse_dependencies(normalized["dependencies"])

    if not finding_id:
        errors.append(f"{source}: finding_id must be non-empty")
    if severity not in ALLOWED_SEVERITY:
        errors.append(f"{source}: invalid severity '{severity}'")
    if not dimension:
        errors.append(f"{source}: dimension must be non-empty")
    if not evidence:
        errors.append(f"{source}: evidence must be non-empty")
    if not impact:
        errors.append(f"{source}: impact must be non-empty")
    if not recommendation:
        errors.append(f"{source}: recommendation must be non-empty")
    if effort not in ALLOWED_EFFORT:
        errors.append(f"{source}: invalid effort '{effort}'")
    if not owner:
        errors.append(f"{source}: owner must be non-empty")
    if confidence not in ALLOWED_CONFIDENCE:
        errors.append(f"{source}: invalid confidence '{confidence}'")
    if not acceptance_criteria:
        errors.append(f"{source}: acceptance_criteria must be non-empty")

    if errors:
        return None

    return {
        "finding_id": finding_id,
        "severity": severity,
        "dimension": dimension,
        "evidence": evidence,
        "impact": impact,
        "recommendation": recommendation,
        "effort": effort,
        "owner": owner,
        "dependencies": dependencies,
        "confidence": confidence,
        "acceptance_criteria": acceptance_criteria,
    }


def extract_action_items(section_text: str) -> list[str]:
    lines = section_text.splitlines()
    bullets = [
        re.sub(r"^\s*[-*]\s+", "", line).strip()
        for line in lines
        if re.match(r"^\s*[-*]\s+", line)
    ]
    bullets = [item for item in bullets if item]
    if bullets:
        return bullets

    table_items: list[str] = []
    for line in lines:
        if not line.strip().startswith("|"):
            continue
        cells = split_pipe_row(line)
        if not cells:
            continue
        if all(not cell.strip() or re.fullmatch(r":?-{3,}:?", cell.replace(" ", "")) for cell in cells):
            continue
        joined = " | ".join([cell for cell in cells if cell])
        if joined:
            table_items.append(joined)
    return table_items


def compute_severity_totals(findings: list[dict[str, Any]]) -> dict[str, int]:
    totals = {"critical": 0, "warning": 0, "info": 0}
    for finding in findings:
        totals[finding["severity"]] += 1
    return totals


def parse_report(path: Path, mode: str, errors: list[str], warnings: list[str]) -> dict[str, Any] | None:
    try:
        text = path.read_text(encoding="utf-8")
    except OSError as exc:
        errors.append(f"{path.name}: cannot read report: {exc}")
        return None

    title, sections, section_order = parse_markdown_sections(text)
    if not title:
        errors.append(f"{path.name}: missing top-level heading")

    for section in REQUIRED_SECTION_ORDER:
        if section not in sections:
            errors.append(f"{path.name}: missing section '{section}'")

    if section_order != REQUIRED_SECTION_ORDER:
        message = (
            f"{path.name}: required section order is {REQUIRED_SECTION_ORDER}, "
            f"found {section_order or 'none'}"
        )
        if mode == "strict":
            errors.append(message)
        else:
            warnings.append(message)

    findings_section = sections.get("Findings", "")
    raw_findings, block_warnings = parse_json_findings_block(findings_section)
    warnings.extend([f"{path.name}: {item}" for item in block_warnings])

    if raw_findings is None:
        raw_findings, table_error = parse_table_findings(findings_section)
        if raw_findings is None:
            errors.append(f"{path.name}: {table_error}")
            raw_findings = []

    if not isinstance(raw_findings, list):
        errors.append(f"{path.name}: findings payload must be a list")
        raw_findings = []

    findings: list[dict[str, Any]] = []
    for idx, raw in enumerate(raw_findings):
        local_errors: list[str] = []
        finding = normalize_finding(
            raw,
            source=f"{path.name}.findings[{idx}]",
            mode=mode,
            errors=local_errors,
            warnings=warnings,
        )
        if local_errors:
            errors.extend(local_errors)
            continue
        if finding is not None:
            findings.append(finding)

    if not findings:
        message = f"{path.name}: findings section produced no valid findings"
        if mode == "strict":
            errors.append(message)
        else:
            warnings.append(message)

    quick_wins = extract_action_items(sections.get("Quick Wins", ""))
    expansions = extract_action_items(sections.get("High-Impact Expansions", ""))

    if not quick_wins:
        message = f"{path.name}: Quick Wins section is empty"
        if mode == "strict":
            errors.append(message)
        else:
            warnings.append(message)

    if not expansions:
        message = f"{path.name}: High-Impact Expansions section is empty"
        if mode == "strict":
            errors.append(message)
        else:
            warnings.append(message)

    report = {
        "schema_version": "1.0.0",
        "report_id": path.stem,
        "mode": mode,
        "generated_at": utc_now(),
        "source_markdown": str(path),
        "title": title,
        "section_order": REQUIRED_SECTION_ORDER,
        "sections": {
            "Executive Summary": sections.get("Executive Summary", ""),
            "Findings": sections.get("Findings", ""),
            "Quick Wins": sections.get("Quick Wins", ""),
            "High-Impact Expansions": sections.get("High-Impact Expansions", ""),
        },
        "findings": findings,
        "quick_wins": quick_wins,
        "high_impact_expansions": expansions,
        "finding_count": len(findings),
        "totals": {
            "by_severity": compute_severity_totals(findings),
        },
    }
    return report


def write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    try:
        path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    except OSError as exc:
        fail(f"cannot write JSON file {path}: {exc}")


def main() -> None:
    args = parse_args()
    reports_dir = Path(args.reports_dir).expanduser()
    out_dir = Path(args.out_dir).expanduser()
    reports_json_dir = out_dir / "reports-json"
    bundle_path = out_dir / "audit-bundle.json"

    if not reports_dir.exists():
        fail(f"reports directory not found: {reports_dir}")
    if not reports_dir.is_dir():
        fail(f"reports path is not a directory: {reports_dir}")

    present_reports = sorted([path.name for path in reports_dir.glob("*.md")])
    required_set = set(REQUIRED_REPORT_FILES)
    present_set = set(present_reports)

    missing_reports = sorted(list(required_set - present_set))
    unexpected_reports = sorted(list(present_set - required_set))

    errors: list[str] = []
    warnings: list[str] = []

    if missing_reports:
        errors.append("missing required reports: " + ", ".join(missing_reports))

    if unexpected_reports:
        message = "unexpected report files: " + ", ".join(unexpected_reports)
        if args.mode == "strict":
            errors.append(message)
        else:
            warnings.append(message)

    reports_payload: list[dict[str, Any]] = []
    for report_name in REQUIRED_REPORT_FILES:
        path = reports_dir / report_name
        if not path.exists():
            continue
        report = parse_report(path, args.mode, errors, warnings)
        if report is not None:
            reports_payload.append(report)
            write_json(reports_json_dir / f"{path.stem}.json", report)

    reports_payload.sort(key=lambda item: item["report_id"])

    bundle_totals = {"critical": 0, "warning": 0, "info": 0}
    for report in reports_payload:
        for key, value in report["totals"]["by_severity"].items():
            bundle_totals[key] += int(value)

    bundle = {
        "schema_version": "1.0.0",
        "mode": args.mode,
        "generated_at": utc_now(),
        "required_reports": REQUIRED_REPORT_FILES,
        "report_count": len(reports_payload),
        "reports": reports_payload,
        "totals": {
            "findings_total": sum(bundle_totals.values()),
            "by_severity": bundle_totals,
        },
    }
    write_json(bundle_path, bundle)

    ok = not errors and (args.mode == "balanced" or not warnings)
    result = {
        "ok": ok,
        "mode": args.mode,
        "reports_dir": str(reports_dir),
        "reports_json_dir": str(reports_json_dir),
        "bundle": str(bundle_path),
        "required_reports": REQUIRED_REPORT_FILES,
        "present_reports": present_reports,
        "missing_reports": missing_reports,
        "unexpected_reports": unexpected_reports,
        "reports_written": len(reports_payload),
        "errors": errors,
        "warnings": warnings,
    }

    print(json.dumps(result, indent=2, sort_keys=True))
    if not ok:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
