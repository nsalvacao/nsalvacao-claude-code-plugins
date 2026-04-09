#!/usr/bin/env python3
"""normalize_interviews.py — Transform JTBD interview notes into evidence.schema.json items.

Parses markdown interview notes (structured or free-form) and produces a JSON array
conforming to evidence.schema.json. Fields without evidence are left null — never inferred.

Supported input formats:
  1. Structured markdown with JTBD sections (---interview--- delimiters or ## headers)
  2. Free-form markdown (single interview, extracts what it can)

Structure hints the parser looks for:
  - `---interview---` or `## Interview N` — starts a new interview record
  - `Interviewee:` / `Role:` / `Company:` — source metadata
  - `Date:` / `Collected:` — collected_at
  - `Dimension:` — wedge / friction / loop / timing / trust / migration
  - `Pain:` / `Claim:` / `Quote:` — evidence claim text
  - `Commitment:` — sets quality_tier to "commitment"
  - `Behavioral:` — sets quality_tier to "behavioral"
  - `Frequency:` / `Severity:` — captured in normalized field
  - Any unstructured text → goes into raw, claim extracted from first sentence

Usage:
  python3 scripts/normalize_interviews.py --input STATE/interviews.md
  python3 scripts/normalize_interviews.py --input notes.md --dimension wedge --output STATE/wedge_interviews.json
  python3 scripts/normalize_interviews.py --input notes.md --validate
"""

import argparse
import json
import re
import sys
from datetime import date
from pathlib import Path


VALID_DIMENSIONS = {"wedge", "friction", "loop", "timing", "trust", "migration"}
VALID_QUALITY_TIERS = ["commitment", "behavioral", "stated", "proxy", "assumption"]
VALID_METHODS = ["interview", "survey", "analytics", "oss_metrics", "market_data",
                 "observation", "experiment", "desk_research"]

# Patterns that imply higher quality tiers from interview content
COMMITMENT_PATTERNS = [
    r"\b(signed|LOI|letter of intent|deposit|paid|pre-?paid|waitlist.{0,20}sign)\b",
    r"\b(gave.{0,15}API key|shared.{0,15}credentials|accepted.{0,15}risk)\b",
    r"\b(referred|referral|introduced.{0,15}colleague)\b",
]
BEHAVIORAL_PATTERNS = [
    r"\b(installed|downloaded|using|uses|started using|switched to)\b",
    r"\b(workaround|built.{0,20}own|wrote.{0,20}script|manual.{0,20}process)\b",
    r"\b(returned|came back|logs in|daily|weekly).{0,30}(use|usage|using)\b",
]


def today_iso() -> str:
    return date.today().isoformat()


def infer_quality_tier(text: str) -> str:
    """Infer quality tier from text signals. Returns most conservative tier."""
    text_lower = text.lower()
    for pattern in COMMITMENT_PATTERNS:
        if re.search(pattern, text_lower, re.IGNORECASE):
            return "commitment"
    for pattern in BEHAVIORAL_PATTERNS:
        if re.search(pattern, text_lower, re.IGNORECASE):
            return "behavioral"
    # Interview method is at minimum "stated"
    return "stated"


def extract_field(lines: list[str], key: str) -> str | None:
    """Extract value for a key like 'Field: value' from a list of lines."""
    pattern = re.compile(rf"^\s*{re.escape(key)}\s*:?\s*(.+)$", re.IGNORECASE)
    for line in lines:
        m = pattern.match(line)
        if m:
            return m.group(1).strip()
    return None


def extract_first_sentence(text: str) -> str:
    """Extract first non-trivial sentence as a claim summary."""
    text = text.strip()
    # Remove markdown headers and bullet markers
    text = re.sub(r"^#+\s*|^[-*]\s*", "", text, flags=re.MULTILINE)
    sentences = re.split(r"(?<=[.!?])\s+", text)
    for s in sentences:
        s = s.strip()
        if len(s) > 20:
            return s[:500]  # cap claim length
    return text[:500] if text else ""


def parse_structured_interview(block: str, default_dimension: str | None) -> dict:
    """Parse a single structured interview block into an evidence item."""
    lines = block.strip().splitlines()
    raw_text = block.strip()

    item: dict = {
        "claim": None,
        "source": None,
        "method": "interview",
        "collected_at": None,
        "raw": raw_text if raw_text else None,
        "normalized": None,
        "quality_tier": "stated",
        "dimension": default_dimension,
        "confidence_components": {},
    }

    # --- Metadata extraction ---
    interviewee = extract_field(lines, "Interviewee") or extract_field(lines, "Name")
    role = extract_field(lines, "Role") or extract_field(lines, "Title")
    company = extract_field(lines, "Company") or extract_field(lines, "Org")
    collected_at = extract_field(lines, "Date") or extract_field(lines, "Collected") or extract_field(lines, "collected_at")
    dimension_field = extract_field(lines, "Dimension")
    claim_field = extract_field(lines, "Claim") or extract_field(lines, "Pain") or extract_field(lines, "Quote")
    tier_field = extract_field(lines, "Tier") or extract_field(lines, "quality_tier")
    severity = extract_field(lines, "Severity")
    frequency = extract_field(lines, "Frequency")

    # --- Source ---
    source_parts = [p for p in [interviewee, role, company] if p]
    item["source"] = ", ".join(source_parts) if source_parts else None

    # --- Collected at ---
    if collected_at:
        # Attempt ISO date normalization
        try:
            parsed = date.fromisoformat(collected_at)
            item["collected_at"] = parsed.isoformat()
        except ValueError:
            item["collected_at"] = None  # non-ISO format — null per schema contract
    else:
        item["collected_at"] = None  # null — not inferred

    # --- Dimension ---
    if dimension_field and dimension_field.lower() in VALID_DIMENSIONS:
        item["dimension"] = dimension_field.lower()
    # else: keep default_dimension (may be None)

    # --- Claim ---
    if claim_field:
        item["claim"] = claim_field[:500]
    else:
        # Fall back: extract from raw text, skip metadata lines
        body_lines = [
            l for l in lines
            if not re.match(r"^\s*(Interviewee|Role|Company|Date|Dimension|Severity|Frequency|Tier|Name|Org|Title|Collected|collected_at)\s*:", l, re.IGNORECASE)
            and l.strip() and not l.startswith("#") and not l.startswith("---")
        ]
        body = " ".join(body_lines)
        item["claim"] = extract_first_sentence(body) if body.strip() else None

    # --- Quality tier ---
    if tier_field and tier_field.lower() in VALID_QUALITY_TIERS:
        item["quality_tier"] = tier_field.lower()
    elif item["claim"]:
        item["quality_tier"] = infer_quality_tier(item["claim"] + " " + raw_text)

    # --- Explicit tier overrides from dedicated fields ---
    commitment_line = extract_field(lines, "Commitment")
    behavioral_line = extract_field(lines, "Behavioral")
    if commitment_line:
        item["quality_tier"] = "commitment"
        if not item["claim"]:
            item["claim"] = commitment_line[:500]
    elif behavioral_line:
        item["quality_tier"] = "behavioral"
        if not item["claim"]:
            item["claim"] = behavioral_line[:500]

    # --- Normalized: serialize quantitative signals ---
    norm_parts = []
    if severity:
        norm_parts.append(f"severity: {severity}")
    if frequency:
        norm_parts.append(f"frequency: {frequency}")
    item["normalized"] = "; ".join(norm_parts) if norm_parts else None

    return item


def split_interview_blocks(text: str) -> list[str]:
    """Split markdown text into individual interview blocks."""
    # Split on explicit delimiters: ---interview--- or ## Interview N or ---
    split_pattern = re.compile(
        r"(?:^---interview---$|^##\s+Interview\s+\d+|^---$)",
        re.IGNORECASE | re.MULTILINE
    )
    parts = split_pattern.split(text)
    # Filter empty blocks
    return [p.strip() for p in parts if p.strip() and len(p.strip()) > 30]


def validate_item(item: dict, idx: int) -> list[str]:
    """Validate a single evidence item against required fields. Returns list of errors."""
    errors = []
    required = ["claim", "source", "method", "collected_at", "quality_tier"]
    for field in required:
        if not item.get(field):
            errors.append(f"  item[{idx}]: missing required field '{field}'")
    if item.get("method") and item["method"] not in VALID_METHODS:
        errors.append(f"  item[{idx}]: invalid method '{item['method']}'")
    if item.get("quality_tier") and item["quality_tier"] not in VALID_QUALITY_TIERS:
        errors.append(f"  item[{idx}]: invalid quality_tier '{item['quality_tier']}'")
    if item.get("dimension") and item["dimension"] not in VALID_DIMENSIONS:
        errors.append(f"  item[{idx}]: invalid dimension '{item['dimension']}'")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Normalize JTBD interview notes into evidence.schema.json items."
    )
    parser.add_argument("--input", "-i", required=True, help="Markdown interview file to parse")
    parser.add_argument("--output", "-o", help="Output JSON file (default: stdout)")
    parser.add_argument("--dimension", help="Default dimension if not specified per interview")
    parser.add_argument(
        "--validate", action="store_true",
        help="Validate output against required schema fields and exit 1 on errors"
    )
    args = parser.parse_args()

    input_path = Path(args.input)
    if not input_path.exists():
        print(f"ERROR: input file not found: {input_path}", file=sys.stderr)
        return 1

    text = input_path.read_text(encoding="utf-8")
    if not text.strip():
        print("ERROR: input file is empty", file=sys.stderr)
        return 1

    blocks = split_interview_blocks(text)

    # If no delimiters found, treat entire file as a single interview
    if not blocks:
        blocks = [text.strip()]

    items = [parse_structured_interview(block, args.dimension) for block in blocks]

    # Remove None-only items (blocks that produced nothing useful)
    items = [item for item in items if item.get("claim") or item.get("raw")]

    if not items:
        print("WARNING: no evidence items extracted from input", file=sys.stderr)

    if args.validate:
        all_errors = []
        for idx, item in enumerate(items):
            all_errors.extend(validate_item(item, idx))
        if all_errors:
            print("VALIDATION ERRORS:", file=sys.stderr)
            for err in all_errors:
                print(err, file=sys.stderr)
            return 1
        print(f"OK: {len(items)} item(s) validated", file=sys.stderr)

    output_json = json.dumps(items, indent=2, ensure_ascii=False)

    if args.output:
        out_path = Path(args.output)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(output_json, encoding="utf-8")
        print(f"Written: {out_path} ({len(items)} item(s))", file=sys.stderr)
    else:
        print(output_json)

    return 0


if __name__ == "__main__":
    sys.exit(main())
