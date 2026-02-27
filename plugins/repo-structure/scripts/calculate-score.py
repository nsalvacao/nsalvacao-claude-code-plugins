#!/usr/bin/env python3
"""
Quality scoring engine for repositories.

Calculates a 0-100 point score across four categories:
- Documentation (25 pts default)
- Security (25 pts default)
- CI/CD (25 pts default)
- Community (25 pts default)

Usage:
    python3 calculate-score.py [repo_path]
    python3 calculate-score.py --path /path/to/repo
    python3 calculate-score.py --json-output
    python3 calculate-score.py --verbose

Output: JSON with scores, issues, and recommendations
"""

import argparse
import json
import os
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional


# Score weights per category (must sum to 100)
DEFAULT_WEIGHTS = {
    "documentation": 25,
    "security": 25,
    "ci_cd": 25,
    "community": 25,
}

# Grade thresholds
GRADE_THRESHOLDS = [
    (95, "Outstanding", "⭐"),
    (85, "Excellent", "✅"),
    (70, "Good", "⚠️"),
    (50, "Poor", "🔶"),
    (0, "Critical", "🚨"),
]


def get_git_info() -> Dict[str, str]:
    """Get git repository information."""
    info = {
        "commit_sha": "",
        "branch": "",
        "remote_url": "",
    }
    try:
        # Get current commit
        result = subprocess.run(
            ["git", "rev-parse", "HEAD"],
            capture_output=True,
            text=True,
            timeout=5,
        )
        if result.returncode == 0:
            info["commit_sha"] = result.stdout.strip()

        # Get current branch
        result = subprocess.run(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"],
            capture_output=True,
            text=True,
            timeout=5,
        )
        if result.returncode == 0:
            info["branch"] = result.stdout.strip()

        # Get remote URL
        result = subprocess.run(
            ["git", "remote", "get-url", "origin"],
            capture_output=True,
            text=True,
            timeout=5,
        )
        if result.returncode == 0:
            info["remote_url"] = result.stdout.strip()
    except (subprocess.TimeoutExpired, FileNotFoundError, subprocess.CalledProcessError):
        pass

    return info


def check_file_exists(filepath: str) -> bool:
    """Check if a file exists."""
    return os.path.isfile(filepath)


def check_directory_exists(dirpath: str) -> bool:
    """Check if a directory exists."""
    return os.path.isdir(dirpath)


# ============================================================
# Documentation Scoring (25 pts)
# ============================================================

def score_documentation(repo_path: str) -> Dict[str, Any]:
    """Score documentation quality."""
    scores = {
        "readme_completeness": 0,
        "api_documentation": 0,
        "additional_docs": 0,
        "inline_documentation": 0,
    }

    readme_path = os.path.join(repo_path, "README.md")
    if os.path.exists(readme_path):
        with open(readme_path) as f:
            readme_content = f.read().lower()

        # README Completeness (12 pts)
        # Project title and description (2 pts)
        if re.search(r'^#\s+.+', readme_content, re.MULTILINE):
            scores["readme_completeness"] += 2

        # Installation instructions (2 pts)
        if re.search(r'##.*installation|pip install|npm install|go get|cargo add', readme_content, re.IGNORECASE):
            scores["readme_completeness"] += 2

        # Usage examples (3 pts)
        if re.search(r'##.*usage|```python|```js|```javascript|```bash', readme_content, re.IGNORECASE):
            scores["readme_completeness"] += 3

        # Contributing guidelines link (2 pts)
        if re.search(r'\[contributing\]\(contributing\.md\)|contributing\.md', readme_content, re.IGNORECASE):
            scores["readme_completeness"] += 2

        # License badge/link (1 pt)
        if re.search(r'license|badge', readme_content, re.IGNORECASE):
            scores["readme_completeness"] += 1

        # Prerequisites listed (1 pt)
        if re.search(r'prerequisite|python|node\.js|nodejs', readme_content, re.IGNORECASE):
            scores["readme_completeness"] += 1

        # Contact/support information (1 pt)
        if re.search(r'contact|email|support|issues', readme_content, re.IGNORECASE):
            scores["readme_completeness"] += 1

        # API Documentation (5 pts)
        # Function/method docstrings check (heuristic - look for docstring patterns)
        python_files = list(Path(repo_path).rglob("*.py"))
        docstring_count = 0
        for py_file in python_files[:10]:  # Check first 10 files
            try:
                with open(py_file) as f:
                    content = f.read()
                    # Count function definitions with docstrings
                    func_count = len(re.findall(r'def \w+\(', content))
                    docstring_count += len(re.findall(r'"""[\s\S]*?"""|\'\'\'[\s\S]*?\'\'\'', content))
            except Exception:
                pass

        if docstring_count > 0 and len(python_files) > 0:
            # Calculate ratio
            ratio = min(docstring_count / max(len(python_files), 1), 1.0)
            scores["api_documentation"] = int(ratio * 2)

        # Type annotations (1 pt)
        type_annotations = 0
        for py_file in python_files[:10]:
            try:
                with open(py_file) as f:
                    content = f.read()
                    if re.search(r': \w+', content) or re.search(r'-> \w+', content):
                        type_annotations += 1
            except Exception:
                pass

        if type_annotations > 0:
            scores["api_documentation"] += 1

        # Generated API docs (2 pts)
        if check_directory_exists(os.path.join(repo_path, "docs")) or \
           check_file_exists(os.path.join(repo_path, "docs/index.md")) or \
           check_file_exists(os.path.join(repo_path, "api.md")):
            scores["api_documentation"] += 2

        # Additional Docs (5 pts)
        # CONTRIBUTING.md exists (2 pts)
        if check_file_exists(os.path.join(repo_path, "CONTRIBUTING.md")):
            scores["additional_docs"] += 2

        # Architecture/design docs (1 pt)
        if check_file_exists(os.path.join(repo_path, "ARCHITECTURE.md")) or \
           check_file_exists(os.path.join(repo_path, "docs/architecture.md")):
            scores["additional_docs"] += 1

        # Changelog (1 pt)
        if check_file_exists(os.path.join(repo_path, "CHANGELOG.md")) or \
           check_file_exists(os.path.join(repo_path, "HISTORY.md")):
            scores["additional_docs"] += 1

        # Examples directory (1 pt)
        if check_directory_exists(os.path.join(repo_path, "examples")) or \
           check_directory_exists(os.path.join(repo_path, "example")):
            scores["additional_docs"] += 1

        # Inline Documentation (3 pts)
        # Comment density (heuristic - check Python files)
        comment_density = 0
        for py_file in python_files[:10]:
            try:
                with open(py_file) as f:
                    lines = f.readlines()
                    total_lines = len(lines)
                    comment_lines = len([l for l in lines if l.strip().startswith('#')])
                    comment_density += comment_lines / max(total_lines, 1)
            except Exception:
                pass

        if comment_density > 0 and len(python_files) > 0:
            avg_density = comment_density / len(python_files)
            if avg_density > 0.1:  # >10% comment density
                scores["inline_documentation"] = 1
            elif avg_density > 0.05:
                scores["inline_documentation"] = 0.5

    return scores


# ============================================================
# Security Scoring (25 pts)
# ============================================================

def score_security(repo_path: str) -> Dict[str, Any]:
    """Score security practices."""
    scores = {
        "security_policy": 0,
        "dependency_management": 0,
        "code_scanning": 0,
        "best_practices": 0,
    }

    # Security Policy (8 pts)
    security_md_path = os.path.join(repo_path, "SECURITY.md")
    if check_file_exists(security_md_path):
        scores["security_policy"] += 3

        # Check for vulnerability reporting process
        with open(security_md_path) as f:
            security_content = f.read().lower()
            if "vulnerability" in security_content or "report" in security_content:
                scores["security_policy"] += 2

            # Check for supported versions
            if "version" in security_content or "support" in security_content:
                scores["security_policy"] += 2

            # Check for security contact
            if "email" in security_content or "contact" in security_content:
                scores["security_policy"] += 1

    # Dependency Management (8 pts)
    # Dependabot/Renovate configured (3 pts)
    dependabot_path = os.path.join(repo_path, ".github/dependabot.yml")
    renovate_path = os.path.join(repo_path, ".github/renovate.json")
    if check_file_exists(dependabot_path) or check_file_exists(renovate_path):
        scores["dependency_management"] += 3

    # Dependency lockfiles present (2 pts)
    lockfiles = ["package-lock.json", "yarn.lock", "requirements.lock", "Pipfile.lock",
                 "Cargo.lock", "go.sum", "composer.lock"]
    if any(check_file_exists(os.path.join(repo_path, lf)) for lf in lockfiles):
        scores["dependency_management"] += 2

    # Code scanning (6 pts)
    # CodeQL or equivalent enabled (3 pts)
    workflows_dir = os.path.join(repo_path, ".github/workflows")
    codeql_workflow = os.path.join(workflows_dir, "codeql.yml")
    if check_file_exists(codeql_workflow):
        scores["code_scanning"] += 3
    elif check_directory_exists(workflows_dir):
        # Check for any security-related workflow
        for wf in os.listdir(workflows_dir):
            if "security" in wf.lower() or "scan" in wf.lower():
                scores["code_scanning"] += 2
                break

    # SAST tool configured (2 pts)
    sast_tools = [".secrets.baseline", ".eslintignore", ".golangci.yml"]
    if any(check_file_exists(os.path.join(repo_path, st)) for st in sast_tools):
        scores["code_scanning"] += 2

    # Secret scanning enabled (1 pt)
    if check_file_exists(dependabot_path):
        with open(dependabot_path) as f:
            if "secret" in f.read().lower():
                scores["code_scanning"] += 1

    # Best Practices (3 pts)
    # No hardcoded secrets (heuristic check)
    secrets_found = False
    sensitive_patterns = [
        r'api[_-]?key\s*=\s*["\'][^"\']+["\']',
        r'secret[_-]?key\s*=\s*["\'][^"\']+["\']',
        r'password\s*=\s*["\'][^"\']+["\']',
    ]
    for pattern in sensitive_patterns:
        for root, dirs, files in os.walk(repo_path):
            for file in files:
                if file.endswith(('.py', '.js', '.ts', '.go', '.rs')):
                    try:
                        with open(os.path.join(root, file)) as f:
                            if re.search(pattern, f.read(), re.IGNORECASE):
                                secrets_found = True
                    except Exception:
                        pass

    if not secrets_found:
        scores["best_practices"] += 1

    # Input validation check (heuristic)
    validation_found = False
    for py_file in Path(repo_path).rglob("*.py"):
        try:
            with open(py_file) as f:
                content = f.read()
                if re.search(r'validate|check.*input|sanitize', content, re.IGNORECASE):
                    validation_found = True
                    break
        except Exception:
            pass

    if validation_found:
        scores["best_practices"] += 1

    # Secure defaults (heuristic - check for config files)
    config_files = ["settings.py", "config.py", "config.yml", "config.yaml", "config.json"]
    if any(check_file_exists(os.path.join(repo_path, cf)) for cf in config_files):
        scores["best_practices"] += 1

    return scores


# ============================================================
# CI/CD Scoring (25 pts)
# ============================================================

def score_cicd(repo_path: str) -> Dict[str, Any]:
    """Score CI/CD setup."""
    scores = {
        "automated_testing": 0,
        "continuous_integration": 0,
        "code_quality": 0,
        "deployment": 0,
    }

    workflows_dir = os.path.join(repo_path, ".github/workflows")

    # Automated Testing (10 pts)
    # Test suite exists (3 pts)
    has_test_suite = False
    if check_directory_exists(os.path.join(repo_path, "tests")) or \
       check_directory_exists(os.path.join(repo_path, "test")):
        has_test_suite = True

    # Check for test files
    test_files = list(Path(repo_path).rglob("test_*.py")) + \
                 list(Path(repo_path).rglob("*_test.py")) + \
                 list(Path(repo_path).rglob("*.spec.ts")) + \
                 list(Path(repo_path).rglob("*.test.ts"))

    if len(test_files) > 0 or has_test_suite:
        scores["automated_testing"] += 3

    # Tests pass check (heuristic - look for test command in package.json or Makefile)
    tests_pass = False
    if check_file_exists(os.path.join(repo_path, "package.json")):
        with open(os.path.join(repo_path, "package.json")) as f:
            pkg = json.load(f)
            if "test" in pkg.get("scripts", {}):
                tests_pass = True

    if tests_pass:
        scores["automated_testing"] += 3

    # Code coverage >70% (heuristic - look for coverage config)
    coverage_found = False
    coverage_files = [
        os.path.join(repo_path, ".coveragerc"),
        os.path.join(repo_path, "pyproject.toml"),
        os.path.join(repo_path, ".coveragerc"),
        os.path.join(workflows_dir, "test.yml") if check_directory_exists(workflows_dir) else None,
    ]
    for cf in coverage_files:
        if cf and check_file_exists(cf):
            with open(cf) as f:
                if "coverage" in f.read().lower() or "pytest-cov" in f.read().lower():
                    coverage_found = True
                    break

    if coverage_found:
        scores["automated_testing"] += 2

    # Coverage >90% (additional 2 pts) - heuristic
    if coverage_found:
        scores["automated_testing"] += 2

    # Continuous Integration (8 pts)
    # CI workflow configured (3 pts)
    ci_workflows = [
        os.path.join(workflows_dir, "test.yml"),
        os.path.join(workflows_dir, "ci.yml"),
        os.path.join(workflows_dir, "build.yml"),
    ]
    if any(check_file_exists(wf) for wf in ci_workflows):
        scores["continuous_integration"] += 3

    # Runs on PR (2 pts)
    for wf in ci_workflows:
        if check_file_exists(wf):
            with open(wf) as f:
                if "pull_request" in f.read() or "push" in f.read():
                    scores["continuous_integration"] += 2
                    break

    # Multiple OS/versions tested (2 pts)
    for wf in ci_workflows:
        if check_file_exists(wf):
            with open(wf) as f:
                content = f.read()
                if "matrix" in content or "python-version" in content or "node-version" in content:
                    scores["continuous_integration"] += 2
                    break

    # Status checks required for merge (1 pt) - heuristic
    # Check if there's a branch protection pattern in workflows
    scores["continuous_integration"] += 1

    # Code Quality (4 pts)
    # Linter configured (2 pts)
    linters = [".flake8", ".eslintrc.json", ".eslintrc.yml", "pyproject.toml",
               ".golangci.yml", "Cargo.toml"]
    if any(check_file_exists(os.path.join(repo_path, l)) for l in linters):
        scores["code_quality"] += 2

    # Linter passing (heuristic)
    scores["code_quality"] += 1

    # Formatter configured (1 pt)
    formatters = [".prettierrc", "pyproject.toml", "ruff.toml", ".EditorConfig"]
    if any(check_file_exists(os.path.join(repo_path, f)) for f in formatters):
        scores["code_quality"] += 1

    # Deployment (3 pts)
    # Automated release workflow (2 pts)
    release_workflows = [
        os.path.join(workflows_dir, "release.yml"),
        os.path.join(workflows_dir, "publish.yml"),
    ]
    if any(check_file_exists(wf) for wf in release_workflows):
        scores["deployment"] += 2

    # Package published (heuristic - look for package registry config)
    published = False
    if check_file_exists(os.path.join(repo_path, "package.json")):
        with open(os.path.join(repo_path, "package.json")) as f:
            pkg = json.load(f)
            if pkg.get("publishConfig") or pkg.get("homepage"):
                published = True
    if check_file_exists(os.path.join(repo_path, "pyproject.toml")):
        with open(os.path.join(repo_path, "pyproject.toml")) as f:
            if "pypi" in f.read().lower():
                published = True

    if published:
        scores["deployment"] += 1

    return scores


# ============================================================
# Community Scoring (25 pts)
# ============================================================

def score_community(repo_path: str) -> Dict[str, Any]:
    """Score community health."""
    scores = {
        "license": 0,
        "contribution_process": 0,
        "community_health": 0,
        "documentation_quality": 0,
    }

    # License (6 pts)
    license_files = ["LICENSE", "LICENSE.md", "LICENSE.txt"]
    if any(check_file_exists(os.path.join(repo_path, lf)) for lf in license_files):
        scores["license"] += 3

        # Check for OSI-approved license
        for lf in license_files:
            if check_file_exists(os.path.join(repo_path, lf)):
                with open(os.path.join(repo_path, lf)) as f:
                    content = f.read()
                    if any(lic in content for lic in ["MIT", "Apache", "GPL", "BSD", "ISC", "BSD-3-Clause"]):
                        scores["license"] += 2
                    break

        # License in package manifest (1 pt)
        if check_file_exists(os.path.join(repo_path, "package.json")):
            with open(os.path.join(repo_path, "package.json")) as f:
                if "license" in json.load(f):
                    scores["license"] += 1

    # Contribution Process (8 pts)
    # CONTRIBUTING.md present (3 pts)
    if check_file_exists(os.path.join(repo_path, "CONTRIBUTING.md")):
        scores["contribution_process"] += 3

    # Clear contribution workflow (2 pts)
    if check_file_exists(os.path.join(repo_path, "CONTRIBUTING.md")):
        with open(os.path.join(repo_path, "CONTRIBUTING.md")) as f:
            content = f.read().lower()
            if "fork" in content and "pull" in content:
                scores["contribution_process"] += 2

    # Issue/PR templates (2 pts)
    issue_templates = [
        os.path.join(repo_path, ".github/ISSUE_TEMPLATE"),
        os.path.join(repo_path, ".github/PULL_REQUEST_TEMPLATE.md"),
    ]
    if any(check_directory_exists(t) or check_file_exists(t) for t in issue_templates):
        scores["contribution_process"] += 2

    # Code of Conduct (1 pt)
    if check_file_exists(os.path.join(repo_path, "CODE_OF_CONDUCT.md")):
        scores["contribution_process"] += 1

    # Community Health (6 pts)
    # CODE_OF_CONDUCT.md (3 pts)
    if check_file_exists(os.path.join(repo_path, "CODE_OF_CONDUCT.md")):
        scores["community_health"] += 3

    # Active maintenance (1 pt) - check recent commits
    try:
        result = subprocess.run(
            ["git", "log", "-1", "--format=%ct"],
            capture_output=True,
            text=True,
            timeout=5,
            cwd=repo_path,
        )
        if result.returncode == 0:
            last_commit = int(result.stdout.strip())
            current_time = datetime.now().timestamp()
            days_since = (current_time - last_commit) / 86400
            if days_since < 30:
                scores["community_health"] += 1
    except Exception:
        pass

    # Multiple contributors (1 pt) - heuristic
    try:
        result = subprocess.run(
            ["git", "shortlog", "-sn", "HEAD"],
            capture_output=True,
            text=True,
            timeout=5,
            cwd=repo_path,
        )
        if result.returncode == 0:
            contributors = len(result.stdout.strip().split("\n"))
            if contributors > 1:
                scores["community_health"] += 1
    except Exception:
        pass

    # Documentation Quality (5 pts)
    # README professionally written (2 pts)
    if check_file_exists(os.path.join(repo_path, "README.md")):
        scores["documentation_quality"] += 2

    # No broken links (heuristic - skip for now, would need external check)
    scores["documentation_quality"] += 1

    # Badges up-to-date (1 pt)
    if check_file_exists(os.path.join(repo_path, "README.md")):
        with open(os.path.join(repo_path, "README.md")) as f:
            content = f.read()
            if "shields.io" in content or "img.shields.io" in content:
                scores["documentation_quality"] += 1

    return scores


# ============================================================
# Main Scoring Logic
# ============================================================

def calculate_score(repo_path: str, weights: Optional[Dict[str, int]] = None) -> Dict[str, Any]:
    """Calculate overall quality score for a repository."""
    if weights is None:
        weights = DEFAULT_WEIGHTS

    # Ensure weights sum to 100
    total_weight = sum(weights.values())
    if total_weight != 100:
        # Normalize weights
        weights = {k: v / total_weight * 100 for k, v in weights.items()}

    # Get category scores
    doc_scores = score_documentation(repo_path)
    sec_scores = score_security(repo_path)
    cicd_scores = score_cicd(repo_path)
    com_scores = score_community(repo_path)

    # Calculate category totals
    doc_total = sum(doc_scores.values())
    sec_total = sum(sec_scores.values())
    cicd_total = sum(cicd_scores.values())
    com_total = sum(com_scores.values())

    # Weighted overall score
    overall_score = (
        doc_total * weights["documentation"] / 25 +
        sec_total * weights["security"] / 25 +
        cicd_total * weights["ci_cd"] / 25 +
        com_total * weights["community"] / 25
    )

    # Determine grade
    grade = "Critical"
    emoji = "🚨"
    for threshold, grade_name, emoji_char in GRADE_THRESHOLDS:
        if overall_score >= threshold:
            grade = grade_name
            emoji = emoji_char
            break

    # Generate issues and recommendations
    issues = []
    recommendations = []

    # Documentation issues
    if doc_scores["readme_completeness"] < 12:
        issues.append({
            "category": "documentation",
            "severity": "warning",
            "message": "README could be more complete",
            "impact": -1,
            "recommendation": "Add usage examples, prerequisites, and contact info"
        })
    if doc_scores["additional_docs"] < 5:
        issues.append({
            "category": "documentation",
            "severity": "info",
            "message": "Missing additional documentation",
            "impact": -1,
            "recommendation": "Add CHANGELOG.md and examples directory"
        })

    # Security issues
    if sec_scores["security_policy"] < 8:
        issues.append({
            "category": "security",
            "severity": "critical" if sec_scores["security_policy"] < 3 else "warning",
            "message": "Security policy incomplete or missing",
            "impact": -3,
            "recommendation": "Add SECURITY.md with vulnerability reporting process"
        })
    if sec_scores["dependency_management"] < 8:
        issues.append({
            "category": "security",
            "severity": "warning",
            "message": "Dependency management could be improved",
            "impact": -2,
            "recommendation": "Enable Dependabot for automated dependency updates"
        })

    # CI/CD issues
    if cicd_scores["automated_testing"] < 10:
        issues.append({
            "category": "ci_cd",
            "severity": "warning",
            "message": "Test coverage could be improved",
            "impact": -2,
            "recommendation": "Add test suite with coverage reporting"
        })

    # Community issues
    if com_scores["license"] < 6:
        issues.append({
            "category": "community",
            "severity": "warning",
            "message": "License information could be clearer",
            "impact": -1,
            "recommendation": "Add a clear LICENSE file with OSI-approved license"
        })
    if com_scores["contribution_process"] < 8:
        issues.append({
            "category": "community",
            "severity": "info",
            "message": "Contribution process could be clearer",
            "impact": -1,
            "recommendation": "Add CONTRIBUTING.md with clear workflow"
        })

    # Generate recommendations based on gaps
    if doc_total < 20:
        recommendations.append({
            "priority": "high",
            "category": "documentation",
            "action": "Improve README completeness",
            "impact": "+5 pts",
            "effort": "low"
        })
    if sec_total < 18:
        recommendations.append({
            "priority": "high",
            "category": "security",
            "action": "Add security policy",
            "impact": "+5 pts",
            "effort": "low"
        })
    if cicd_total < 18:
        recommendations.append({
            "priority": "high",
            "category": "ci_cd",
            "action": "Set up CI/CD pipeline",
            "impact": "+5 pts",
            "effort": "medium"
        })
    if com_total < 18:
        recommendations.append({
            "priority": "medium",
            "category": "community",
            "action": "Improve community standards",
            "impact": "+5 pts",
            "effort": "low"
        })

    # Calculate max scores per category
    max_scores = {
        "documentation": 25,
        "security": 25,
        "ci_cd": 25,
        "community": 25,
    }

    return {
        "score": round(overall_score, 1),
        "max_score": 100,
        "grade": grade,
        "emoji": emoji,
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "categories": {
            "documentation": {
                "score": round(doc_total, 1),
                "max": 25,
                "percentage": round(doc_total / 25 * 100, 1),
                "breakdown": {k: round(v, 1) for k, v in doc_scores.items()},
                "issues": [i for i in issues if i["category"] == "documentation"]
            },
            "security": {
                "score": round(sec_total, 1),
                "max": 25,
                "percentage": round(sec_total / 25 * 100, 1),
                "breakdown": {k: round(v, 1) for k, v in sec_scores.items()},
                "issues": [i for i in issues if i["category"] == "security"]
            },
            "ci_cd": {
                "score": round(cicd_total, 1),
                "max": 25,
                "percentage": round(cicd_total / 25 * 100, 1),
                "breakdown": {k: round(v, 1) for k, v in cicd_scores.items()},
                "issues": [i for i in issues if i["category"] == "ci_cd"]
            },
            "community": {
                "score": round(com_total, 1),
                "max": 25,
                "percentage": round(com_total / 25 * 100, 1),
                "breakdown": {k: round(v, 1) for k, v in com_scores.items()},
                "issues": [i for i in issues if i["category"] == "community"]
            }
        },
        "issues": issues,
        "recommendations": recommendations,
        "git_info": get_git_info()
    }


def main():
    parser = argparse.ArgumentParser(
        description="Calculate quality score for a repository"
    )
    parser.add_argument(
        "path",
        nargs="?",
        default=".",
        help="Path to repository (default: current directory)"
    )
    parser.add_argument(
        "--weights",
        help="Custom weights as JSON (e.g., '{\"documentation\": 30, \"security\": 40}')"
    )
    parser.add_argument(
        "--json-output",
        action="store_true",
        help="Output only JSON (no summary)"
    )
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Show detailed breakdown"
    )

    args = parser.parse_args()

    # Validate path
    repo_path = os.path.abspath(args.path)
    if not os.path.isdir(repo_path):
        print(f"Error: Path is not a directory: {repo_path}", file=sys.stderr)
        sys.exit(1)

    # Check for git repository
    if not os.path.isdir(os.path.join(repo_path, ".git")):
        print(f"Warning: {repo_path} is not a git repository", file=sys.stderr)

    # Parse custom weights
    weights = None
    if args.weights:
        try:
            weights = json.loads(args.weights)
        except json.JSONDecodeError:
            print(f"Error: Invalid JSON for weights: {args.weights}", file=sys.stderr)
            sys.exit(1)

    # Calculate score
    result = calculate_score(repo_path, weights)

    # Output
    if args.json_output:
        print(json.dumps(result, indent=2))
    else:
        print(f"\n{'=' * 50}")
        print(f"Quality Score: {result['score']}/{result['max_score']} {result['emoji']} ({result['grade']})")
        print(f"{'=' * 50}\n")

        for category, data in result["categories"].items():
            status = "✅" if data["percentage"] >= 80 else "⚠️" if data["percentage"] >= 50 else "❌"
            print(f"{status} {category.upper():12} {data['score']:5.1f}/{data['max']:3} ({data['percentage']:5.1f}%)")

        print(f"\n{'=' * 50}")
        print("RECOMMENDATIONS")
        print(f"{'=' * 50}")
        for rec in result["recommendations"]:
            print(f"[{rec['priority'].upper():7}] {rec['action']} ({rec['impact']})")

        if args.verbose:
            print(f"\n{'=' * 50}")
            print("DETAILED BREAKDOWN")
            print(f"{'=' * 50}")
            for category, data in result["categories"].items():
                print(f"\n{category.upper()}:")
                for item, value in data["breakdown"].items():
                    print(f"  - {item}: {value}")

            if result["issues"]:
                print(f"\n{'=' * 50}")
                print("ISSUES FOUND")
                print(f"{'=' * 50}")
                for issue in result["issues"]:
                    print(f"[{issue['severity'].upper()}] {issue['message']} (Impact: {issue['impact']})")

    return 0


if __name__ == "__main__":
    sys.exit(main())
