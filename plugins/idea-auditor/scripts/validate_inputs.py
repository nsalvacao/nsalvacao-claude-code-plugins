#!/usr/bin/env python3
"""validate_inputs.py — Validates IDEA.md/IDEA.json required fields and STATE/ JSON integrity.

Note: this script performs structural validation (required fields, valid mode enum, JSON
parseability) and reads required field names from idea.schema.json. It does NOT perform
full JSON Schema draft-07 validation (no jsonschema dependency). Full schema validation
is planned for a future version.

Usage:
  python3 validate_inputs.py --idea <path>           Validate IDEA file only
  python3 validate_inputs.py --idea <path> --state <dir>  Validate IDEA + STATE dir
"""

import argparse
import json
import sys
from pathlib import Path

# Schema directory — used to validate required fields from idea.schema.json
SCHEMA_DIR = Path(__file__).parent.parent / "schemas"

# Required fields per schema (mirrors idea.schema.json "required" array)
IDEA_REQUIRED_FIELDS = ["icp", "job_to_be_done", "pain", "current_alternative", "promise", "mode"]
VALID_MODES = ["OSS_CLI", "B2B_SaaS", "Consumer_Viral", "Infra_Fork_Standard"]

# Required sections in IDEA.md (markdown format)
IDEA_MD_REQUIRED_SECTIONS = ["ICP", "JTBD", "pain", "current_alternative", "promise", "mode"]


def load_json(path: Path) -> dict:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        print(f"ERROR: Invalid JSON in {path}: {e}", file=sys.stderr)
        sys.exit(1)


def validate_required_fields(data: dict, required: list[str], context: str) -> list[str]:
    errors = []
    for field in required:
        if field not in data or data[field] is None:
            errors.append(f"{context}: missing required field '{field}'")
    return errors


def _get_schema_required(schema_name: str) -> list[str]:
    """Read 'required' array from a schema file, if available."""
    schema_path = SCHEMA_DIR / schema_name
    if not schema_path.exists():
        return []
    try:
        schema = json.loads(schema_path.read_text(encoding="utf-8"))
        return schema.get("required", [])
    except (json.JSONDecodeError, KeyError):
        return []


def validate_idea(idea_path: Path) -> list[str]:
    errors = []
    if not idea_path.exists():
        return [f"IDEA file not found: {idea_path}"]

    if idea_path.suffix == ".json":
        data = load_json(idea_path)
        # Use required fields from schema if available, fall back to hardcoded list
        required = _get_schema_required("idea.schema.json") or IDEA_REQUIRED_FIELDS
        errors.extend(validate_required_fields(data, required, "IDEA"))

        if "mode" in data and data["mode"] not in VALID_MODES:
            errors.append(
                f"IDEA: invalid mode '{data['mode']}'. Must be one of: {VALID_MODES}"
            )

        if "icp" in data and isinstance(data["icp"], dict):
            for sub in ["who", "context"]:
                if not data["icp"].get(sub):
                    errors.append(f"IDEA.icp: missing required sub-field '{sub}'")

    else:
        # Markdown IDEA.md — check for required section keywords
        content = idea_path.read_text(encoding="utf-8")
        if content.strip().startswith("{"):
            # Misnamed file: content is JSON
            try:
                data = json.loads(content)
                required = _get_schema_required("idea.schema.json") or IDEA_REQUIRED_FIELDS
                errors.extend(validate_required_fields(data, required, "IDEA"))
                return errors
            except json.JSONDecodeError:
                return [f"IDEA file appears to be JSON but is not valid: {idea_path}"]

        for section in IDEA_MD_REQUIRED_SECTIONS:
            if section.lower() not in content.lower():
                errors.append(f"IDEA.md: missing required section or keyword '{section}'")

        # Check that a valid mode appears in the file
        if not any(mode in content for mode in VALID_MODES):
            errors.append(
                f"IDEA.md: no valid mode found. Expected one of: {VALID_MODES}"
            )

    return errors


def validate_state(state_dir: Path) -> list[str]:
    errors = []
    if not state_dir.exists():
        return [f"STATE dir not found: {state_dir}"]
    if not state_dir.is_dir():
        return [f"STATE path is not a directory: {state_dir}"]

    json_files = list(state_dir.glob("*.json"))
    for f in json_files:
        try:
            json.loads(f.read_text(encoding="utf-8"))
        except json.JSONDecodeError as e:
            errors.append(f"STATE/{f.name}: invalid JSON: {e}")

    return errors


def main():
    parser = argparse.ArgumentParser(description="Validate idea-auditor inputs.")
    parser.add_argument("--idea", required=True, help="Path to IDEA.md or IDEA.json")
    parser.add_argument("--state", required=False, help="Path to STATE/ directory")
    args = parser.parse_args()

    errors = []
    errors.extend(validate_idea(Path(args.idea)))

    if args.state:
        errors.extend(validate_state(Path(args.state)))

    if errors:
        print("VALIDATION FAILED:", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        sys.exit(1)

    print("OK: all inputs valid.")
    sys.exit(0)


if __name__ == "__main__":
    main()
