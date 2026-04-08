#!/usr/bin/env python3
"""validate_inputs.py — Validates IDEA.md/IDEA.json and STATE/ against schemas.

Usage:
  python3 validate_inputs.py --idea <path>           Validate IDEA file only
  python3 validate_inputs.py --idea <path> --state <dir>  Validate IDEA + STATE dir
"""

import argparse
import json
import sys
from pathlib import Path

SCHEMA_DIR = Path(__file__).parent.parent / "schemas"


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


def validate_idea(idea_path: Path) -> list[str]:
    errors = []
    if not idea_path.exists():
        return [f"IDEA file not found: {idea_path}"]

    if idea_path.suffix == ".json":
        data = load_json(idea_path)
    else:
        # Minimal markdown parse: look for JSON front-matter or treat as structured text
        content = idea_path.read_text(encoding="utf-8")
        if content.strip().startswith("{"):
            try:
                data = json.loads(content)
            except json.JSONDecodeError:
                return [f"IDEA file is not valid JSON: {idea_path}"]
        else:
            # Markdown IDEA.md — check for required sections
            required_sections = ["ICP", "JTBD", "pain", "current_alternative", "promise", "mode"]
            for section in required_sections:
                if section.lower() not in content.lower():
                    errors.append(f"IDEA.md: missing section or keyword '{section}'")
            return errors

    required = ["icp", "job_to_be_done", "pain", "current_alternative", "promise", "mode"]
    errors.extend(validate_required_fields(data, required, "IDEA"))

    valid_modes = ["OSS_CLI", "B2B_SaaS", "Consumer_Viral", "Infra_Fork_Standard"]
    if "mode" in data and data["mode"] not in valid_modes:
        errors.append(f"IDEA: invalid mode '{data['mode']}'. Must be one of: {valid_modes}")

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
