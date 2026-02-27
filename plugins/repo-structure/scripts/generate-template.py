#!/usr/bin/env python3
"""
Template rendering script with Mustache-style variable substitution.

Supports:
- {{VAR}} - Simple variable substitution
- {{#COND}}...{{/COND}} - Include if condition is truthy
- {{^COND}}...{{/COND}} - Include if condition is falsy

Conditionals: PYTHON, JAVASCRIPT, TYPESCRIPT, GO, RUST, HAS_CI, HAS_TESTS,
              HAS_DOCKER, IS_LIBRARY, IS_CLI

Variable resolution order:
1. --vars or --vars-file (highest priority)
2. git config (user.name, user.email, remote.origin.url)
3. Default/fallback values
"""

import argparse
import json
import os
import re
import sys
from datetime import datetime
from pathlib import Path
from typing import Optional


def get_git_config(key: str, default: str = "") -> str:
    """Get value from git config, return default if not set."""
    try:
        import subprocess
        result = subprocess.run(
            ["git", "config", key],
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return default


def get_project_name() -> str:
    """Extract project name from git remote or directory name."""
    try:
        import subprocess
        remote = get_git_config("remote.origin.url")
        if remote:
            # Match github.com/user/repo or git@github.com:user/repo.git
            match = re.search(r'github\.com[/:]([^/]+)/([^\.]+?)(\.git)?$', remote)
            if match:
                return match.group(2)
            match = re.search(r'git@github\.com:([^/]+)/([^\.]+?)(\.git)?$', remote)
            if match:
                return match.group(2)
    except Exception:
        pass
    return Path.cwd().name


def get_github_username() -> Optional[str]:
    """Get GitHub username from git remote."""
    try:
        import subprocess
        remote = get_git_config("remote.origin.url")
        if remote:
            match = re.search(r'github\.com[/:]([^/]+)', remote)
            if match:
                return match.group(1)
            match = re.search(r'git@github\.com:([^/]+)', remote)
            if match:
                return match.group(1)
    except Exception:
        pass
    return None


def detect_license() -> str:
    """Detect license type from LICENSE file."""
    license_files = ["LICENSE", "LICENSE.md", "LICENSE.txt"]
    for lf in license_files:
        if os.path.exists(lf):
            try:
                with open(lf, 'r') as f:
                    content = f.read(500)
                    if "Apache" in content:
                        return "Apache-2.0"
                    elif "GPL" in content:
                        return "GPL-3.0"
                    elif "BSD" in content:
                        return "BSD-3-Clause"
            except Exception:
                pass
    return "MIT"


def get_version() -> str:
    """Get version from package.json or pyproject.toml."""
    # Try package.json
    if os.path.exists("package.json"):
        try:
            with open("package.json") as f:
                data = json.load(f)
                return data.get("version", "0.1.0")
        except Exception:
            pass

    # Try pyproject.toml
    if os.path.exists("pyproject.toml"):
        try:
            with open("pyproject.toml") as f:
                content = f.read()
                match = re.search(r'version\s*=\s*"([^"]+)"', content)
                if match:
                    return match.group(1)
        except Exception:
            pass

    return "0.1.0"


def detect_primary_language() -> str:
    """Detect primary programming language."""
    # Check for Python
    python_files = ["requirements.txt", "pyproject.toml", "setup.py", "Pipfile"]
    if any(os.path.exists(f) for f in python_files):
        return "Python"

    # Check for JavaScript/TypeScript
    if os.path.exists("package.json"):
        try:
            with open("package.json") as f:
                data = json.load(f)
                if data.get("devDependencies", {}).get("typescript"):
                    return "TypeScript"
                return "JavaScript"
        except Exception:
            return "JavaScript"

    # Check for Go
    if os.path.exists("go.mod"):
        return "Go"

    # Check for Rust
    if os.path.exists("Cargo.toml"):
        return "Rust"

    return "Unknown"


def detect_tech_stack() -> list:
    """Detect technology stack."""
    stack = []

    # Python stack
    if os.path.exists("requirements.txt") or os.path.exists("pyproject.toml"):
        stack.append("Python")
        try:
            with open("requirements.txt") as f:
                content = f.read().lower()
                if "django" in content:
                    stack.append("Django")
                elif "fastapi" in content:
                    stack.append("FastAPI")
                elif "flask" in content:
                    stack.append("Flask")
        except Exception:
            pass

    # JavaScript/TypeScript stack
    if os.path.exists("package.json"):
        stack.append("JavaScript")
        try:
            with open("package.json") as f:
                content = f.read()
                if "react" in content:
                    stack.append("React")
                elif "vue" in content:
                    stack.append("Vue")
                elif "next" in content:
                    stack.append("Next.js")
                elif "express" in content:
                    stack.append("Express")
        except Exception:
            pass

    # Go
    if os.path.exists("go.mod"):
        stack.append("Go")

    # Rust
    if os.path.exists("Cargo.toml"):
        stack.append("Rust")

    return stack


def has_ci() -> bool:
    """Check if CI/CD is configured."""
    return os.path.isdir(".github/workflows") or os.path.exists(".gitlab-ci.yml")


def has_tests() -> bool:
    """Check if tests are configured."""
    if os.path.isdir("tests") or os.path.isdir("test"):
        return True
    if os.path.exists("pytest.ini") or os.path.exists("setup.cfg"):
        return True
    if os.path.exists("package.json"):
        try:
            with open("package.json") as f:
                data = json.load(f)
                return "test" in data.get("scripts", {})
        except Exception:
            pass
    return False


def has_docker() -> bool:
    """Check if Docker is configured."""
    return os.path.exists("Dockerfile") or os.path.exists("docker-compose.yml")


def has_license() -> bool:
    """Check if LICENSE file exists."""
    return any(os.path.exists(f) for f in ["LICENSE", "LICENSE.md", "LICENSE.txt"])


def is_library() -> bool:
    """Check if project is a library."""
    if os.path.exists("setup.py"):
        return True
    if os.path.exists("pyproject.toml"):
        try:
            with open("pyproject.toml") as f:
                content = f.read()
                return "[project]" in content or "[tool.poetry]" in content
        except Exception:
            pass
    if os.path.exists("Cargo.toml"):
        try:
            with open("Cargo.toml") as f:
                content = f.read()
                return "[lib]" in content
        except Exception:
            pass
    return False


def is_cli() -> bool:
    """Check if project is a CLI tool."""
    if os.path.exists("package.json"):
        try:
            with open("package.json") as f:
                data = json.load(f)
                return "bin" in data
        except Exception:
            pass
    if os.path.exists("setup.py"):
        try:
            with open("setup.py") as f:
                return "console_scripts" in f.read()
        except Exception:
            pass
    return False


def resolve_variables(
    provided_vars: dict,
    mock: bool = False
) -> dict:
    """Resolve all template variables with fallbacks."""
    vars = {}

    # Set from provided vars (highest priority)
    for key, value in provided_vars.items():
        upper_key = key.upper().replace("-", "_")
        vars[upper_key] = value

    # Resolve git config values if not set
    if "PROJECT_NAME" not in vars:
        vars["PROJECT_NAME"] = get_project_name()
    if "AUTHOR_NAME" not in vars:
        vars["AUTHOR_NAME"] = get_git_config("user.name", "")
    if "AUTHOR_EMAIL" not in vars:
        vars["AUTHOR_EMAIL"] = get_git_config("user.email", "")
    if "GITHUB_USERNAME" not in vars:
        vars["GITHUB_USERNAME"] = get_github_username() or ""

    if "LICENSE_TYPE" not in vars:
        vars["LICENSE_TYPE"] = detect_license()
    if "YEAR" not in vars:
        vars["YEAR"] = str(datetime.now().year)
    if "VERSION" not in vars:
        vars["VERSION"] = get_version()
    if "PRIMARY_LANGUAGE" not in vars:
        vars["PRIMARY_LANGUAGE"] = detect_primary_language()
    if "TECH_STACK" not in vars:
        stack = detect_tech_stack()
        vars["TECH_STACK"] = ", ".join(stack)

    # Set defaults for missing values
    defaults = {
        "CI_PROVIDER": "github-actions",
        "PYTHON_VERSION": "3.10",
        "NODE_VERSION": "18",
        "GO_VERSION": "1.21",
        "RUST_VERSION": "1.75",
        "DESCRIPTION": "A great new project",
        "PROJECT_NAME": "my-project",
    }

    for key, default in defaults.items():
        if key not in vars:
            vars[key] = default

    # Generate derived variables
    primary = vars.get("PRIMARY_LANGUAGE", "").lower()

    # Test command
    if primary == "python":
        vars["TEST_COMMAND"] = "pytest"
        vars["LINT_COMMAND"] = "flake8"
        vars["FORMAT_COMMAND"] = "black ."
    elif primary in ("javascript", "typescript"):
        vars["TEST_COMMAND"] = "npm test"
        vars["LINT_COMMAND"] = "npm run lint"
        vars["FORMAT_COMMAND"] = "prettier --write ."
    elif primary == "go":
        vars["TEST_COMMAND"] = "go test ./..."
        vars["LINT_COMMAND"] = "golangci-lint run"
        vars["FORMAT_COMMAND"] = "gofmt -w ."
    elif primary == "rust":
        vars["TEST_COMMAND"] = "cargo test"
        vars["LINT_COMMAND"] = "cargo clippy"
        vars["FORMAT_COMMAND"] = "cargo fmt"

    # Badge URLs
    gh_user = vars.get("GITHUB_USERNAME", "")
    repo = vars.get("PROJECT_NAME", "")
    license_type = vars.get("LICENSE_TYPE", "MIT")

    if gh_user and repo:
        vars["CI_BADGE"] = f"![CI](https://github.com/{gh_user}/{repo}/workflows/CI/badge.svg)"
        vars["LICENSE_BADGE"] = f"![License](https://img.shields.io/badge/license-{license_type}-blue.svg)"
        vars["VERSION_BADGE"] = f"![Version](https://img.shields.io/badge/version-{vars.get('VERSION', '0.1.0')}-blue)"

    # GitHub repo URL
    if gh_user and repo:
        vars["GITHUB_REPO_URL"] = f"https://github.com/{gh_user}/{repo}"

    # Package URLs
    if primary == "python":
        vars["PYPI_PACKAGE"] = f"https://pypi.org/project/{repo}"
    elif primary == "javascript":
        vars["NPM_PACKAGE"] = f"https://www.npmjs.com/package/{repo}"
    elif primary == "rust":
        vars["CRATES_PACKAGE"] = f"https://crates.io/crates/{repo}"

    # Case transformations
    project_name = vars.get("PROJECT_NAME", "my-project")
    vars["PROJECT_NAME_SNAKE"] = project_name.replace("-", "_")
    vars["PROJECT_NAME_UPPER"] = vars["PROJECT_NAME_SNAKE"].upper()
    # PascalCase
    vars["PROJECT_NAME_PASCAL"] = project_name.replace("-", " ").title().replace(" ", "")
    # kebab-case
    vars["PROJECT_NAME_KEBAB"] = project_name.replace("_", "-")

    return vars


def evaluate_condition(condition: str, vars: dict) -> bool:
    """Evaluate a conditional expression."""
    condition = condition.upper()

    # Map condition names to variables/functions
    condition_map = {
        "PYTHON": lambda: vars.get("PRIMARY_LANGUAGE", "").lower() == "python",
        "JAVASCRIPT": lambda: vars.get("PRIMARY_LANGUAGE", "").lower() in ("javascript", "typescript"),
        "TYPESCRIPT": lambda: "TypeScript" in vars.get("TECH_STACK", ""),
        "GO": lambda: vars.get("PRIMARY_LANGUAGE", "").lower() == "go",
        "RUST": lambda: vars.get("PRIMARY_LANGUAGE", "").lower() == "rust",
        "JAVA": lambda: vars.get("PRIMARY_LANGUAGE", "").lower() == "java",
        "HAS_CI": lambda: has_ci(),
        "HAS_TESTS": lambda: has_tests(),
        "HAS_DOCKER": lambda: has_docker(),
        "HAS_LICENSE": lambda: has_license(),
        "IS_LIBRARY": lambda: is_library(),
        "IS_CLI": lambda: is_cli(),
    }

    if condition in condition_map:
        return condition_map[condition]()

    # Check if variable is truthy (non-empty)
    return bool(vars.get(condition, ""))


def render_template(template_content: str, vars: dict) -> str:
    """Render template with variable substitution and conditionals."""

    def process_conditionals(content: str, is_negated: bool) -> str:
        """Process conditional blocks recursively."""
        pattern = r'\{\{#(\^?)([A-Z_][A-Z0-9_]*)\}\}(.*?)\{\{/\2\}\}'

        def replace_match(match):
            negation_flag = match.group(1)
            condition = match.group(2)
            block_content = match.group(3)

            # Determine if should include
            include = evaluate_condition(condition, vars)

            # Apply negation if needed
            if negation_flag == "^":
                include = not include

            return block_content if include else ""

        # Keep processing until no more conditionals
        prev_content = None
        while prev_content != content:
            prev_content = content
            content = re.sub(pattern, replace_match, content, flags=re.DOTALL)

        return content

    def process_variables(content: str) -> str:
        """Process simple variable substitution."""
        pattern = r'\{\{([A-Z_][A-Z0-9_]*)\}\}'

        def replace_var(match):
            var_name = match.group(1)
            return str(vars.get(var_name, match.group(0)))

        return re.sub(pattern, replace_var, content)

    # Step 1: Process negated conditionals {{^COND}}...{{/COND}}
    template_content = process_conditionals(template_content, is_negated=True)

    # Step 2: Process positive conditionals {{#COND}}...{{/COND}}
    template_content = process_conditionals(template_content, is_negated=False)

    # Step 3: Simple variable substitution
    template_content = process_variables(template_content)

    return template_content


def main():
    parser = argparse.ArgumentParser(
        description="Template rendering with Mustache-style variable substitution"
    )
    parser.add_argument("--template", required=True, help="Template file path")
    parser.add_argument("--output", required=True, help="Output file path")
    parser.add_argument("--vars", help="Comma-separated key=value pairs")
    parser.add_argument("--vars-file", help="JSON file with variables")
    parser.add_argument("--prompt-missing", action="store_true", help="Prompt for missing variables")
    parser.add_argument("--mock-vars", action="store_true", help="Use mock values")
    parser.add_argument("--strict", action="store_true", help="Fail on missing variables")

    args = parser.parse_args()

    # Parse provided variables
    provided_vars = {}

    if args.vars:
        for pair in args.vars.split(","):
            if "=" in pair:
                key, value = pair.split("=", 1)
                provided_vars[key.strip()] = value.strip()

    if args.vars_file:
        try:
            with open(args.vars_file) as f:
                provided_vars.update(json.load(f))
        except Exception as e:
            print(f"Error reading vars file: {e}", file=sys.stderr)
            sys.exit(1)

    # Resolve all variables
    vars = resolve_variables(provided_vars, mock=args.mock_vars)

    # Read template
    try:
        with open(args.template) as f:
            template_content = f.read()
    except FileNotFoundError:
        print(f"Error: Template file not found: {args.template}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error reading template: {e}", file=sys.stderr)
        sys.exit(1)

    # Render template
    rendered = render_template(template_content, vars)

    # Ensure output directory exists
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    # Write output
    try:
        with open(output_path, "w") as f:
            f.write(rendered)
        print(f"Template rendered to: {output_path}")
    except Exception as e:
        print(f"Error writing output: {e}", file=sys.stderr)
        sys.exit(1)

    return 0


if __name__ == "__main__":
    sys.exit(main())
