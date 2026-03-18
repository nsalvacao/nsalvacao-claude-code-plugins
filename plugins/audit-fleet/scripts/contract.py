#!/usr/bin/env python3
"""Shared audit-fleet contract constants and helper validators."""

from __future__ import annotations

import re
from typing import Iterable

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


def normalize_heading(value: str) -> str:
    return re.sub(r"\s+", " ", value.strip().lower())


def normalize_key(value: str) -> str:
    normalized = value.strip().lower().replace("-", "_")
    normalized = re.sub(r"[^a-z0-9_]+", "_", normalized)
    normalized = re.sub(r"_+", "_", normalized).strip("_")
    return normalized


def finding_key_deltas(keys: Iterable[str]) -> tuple[list[str], list[str]]:
    key_set = set(keys)
    required = set(REQUIRED_FINDING_KEYS)
    missing = sorted(list(required - key_set))
    extras = sorted(list(key_set - required))
    return missing, extras


def section_order_deltas(section_titles: list[str]) -> tuple[list[str], bool]:
    expected_norm = [normalize_heading(section) for section in REQUIRED_SECTION_ORDER]
    found_norm = [normalize_heading(section) for section in section_titles]

    missing_sections = [
        section for section in REQUIRED_SECTION_ORDER if normalize_heading(section) not in found_norm
    ]
    ordered = [value for value in found_norm if value in expected_norm]
    return missing_sections, ordered == expected_norm

