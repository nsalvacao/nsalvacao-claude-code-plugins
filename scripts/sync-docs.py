#!/usr/bin/env python3
"""
sync-docs.py — Auto-generate plugin documentation from marketplace.json + plugin directories.

Updates:
  1. README.md — plugin table between <!-- PLUGINS-TABLE-START/END --> markers
  2. docs/plugins-inventory.md — detailed per-plugin inventory

Optionally enhances descriptions via GitHub Models (MODELS_PAT env var).
"""

import json
import os
import pathlib
import re
import sys
import textwrap

ROOT = pathlib.Path(__file__).parent.parent

# ── Helpers ────────────────────────────────────────────────────────────────────

def read_json(path):
    try:
        return json.loads(pathlib.Path(path).read_text())
    except Exception as e:
        print(f"⚠️  Cannot read {path}: {e}", file=sys.stderr)
        return None


def scan_component(plugin_dir, subdir, pattern="*.md"):
    """Return list of (name, file) for components under plugin_dir/subdir."""
    results = []
    d = plugin_dir / subdir
    if not d.is_dir():
        return results
    for f in sorted(d.glob(pattern)):
        # Extract name from YAML frontmatter if present, else use filename stem
        text = f.read_text(errors="replace")
        m = re.search(r"^---\s*\nname:\s*(.+)", text, re.MULTILINE)
        name = m.group(1).strip() if m else f.stem
        results.append((name, f))
    return results


def scan_skills(plugin_dir):
    """Return skill names from skills/*/SKILL.md"""
    results = []
    d = plugin_dir / "skills"
    if not d.is_dir():
        return results
    for skill_dir in sorted(d.iterdir()):
        skill_file = skill_dir / "SKILL.md"
        if not skill_file.exists():
            continue
        text = skill_file.read_text(errors="replace")
        m = re.search(r"^---\s*\nname:\s*(.+)", text, re.MULTILINE)
        name = m.group(1).strip() if m else skill_dir.name
        results.append((name, skill_file))
    return results


def first_paragraph(text):
    """Extract first non-empty paragraph from markdown, strip headers."""
    for line in text.splitlines():
        line = line.strip()
        if line and not line.startswith("#") and not line.startswith("---") \
                and not line.startswith("!") and len(line) > 20:
            return line[:200]
    return ""


def ai_describe(plugin_name, readme_path, manifest_desc):
    """
    Optionally call GitHub Models to generate a richer 1-sentence description.
    Falls back to manifest description if MODELS_PAT not set or call fails.
    """
    token = os.environ.get("MODELS_PAT")
    if not token:
        return manifest_desc

    try:
        import requests  # noqa: PLC0415
        readme = pathlib.Path(readme_path).read_text(errors="replace")[:3000] if pathlib.Path(readme_path).exists() else ""
        payload = {
            "model": "openai/gpt-4.1",
            "messages": [
                {
                    "role": "system",
                    "content": (
                        "You are a technical writer. Given a Claude Code plugin README, "
                        "write a single concise sentence (max 120 chars) describing what the plugin does "
                        "and who it is for. Be specific. No marketing fluff. Start with a verb."
                    ),
                },
                {
                    "role": "user",
                    "content": f"Plugin: {plugin_name}\nCurrent description: {manifest_desc}\n\nREADME excerpt:\n{readme}",
                },
            ],
            "max_tokens": 80,
            "temperature": 0.2,
        }
        resp = requests.post(
            "https://models.github.ai/inference/chat/completions",
            headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
            json=payload,
            timeout=30,
        )
        if resp.status_code == 200:
            return resp.json()["choices"][0]["message"]["content"].strip().strip('"')
    except Exception as e:
        print(f"⚠️  AI describe failed for {plugin_name}: {e}", file=sys.stderr)

    return manifest_desc


# ── Build plugin data ──────────────────────────────────────────────────────────

def collect_plugin_data(marketplace):
    plugins = []
    for entry in marketplace.get("plugins", []):
        name = entry["name"]
        plugin_dir = ROOT / "plugins" / name
        if not plugin_dir.exists():
            print(f"⚠️  Plugin dir missing: {plugin_dir}", file=sys.stderr)
            continue

        manifest = read_json(plugin_dir / ".claude-plugin" / "plugin.json") or {}
        readme_path = plugin_dir / "README.md"

        commands = scan_component(plugin_dir, "commands")
        agents   = scan_component(plugin_dir, "agents")
        skills   = scan_skills(plugin_dir)
        hooks    = (plugin_dir / "hooks" / "hooks.json").exists()

        description = (
            manifest.get("description")
            or entry.get("description")
            or (first_paragraph(readme_path.read_text()) if readme_path.exists() else "")
            or "—"
        )

        # Optional AI enhancement
        if os.environ.get("MODELS_PAT") and os.environ.get("AI_ENHANCE_DOCS", "false") == "true":
            description = ai_describe(name, readme_path, description)

        plugins.append({
            "name": name,
            "version": manifest.get("version", entry.get("version", "—")),
            "description": description,
            "category": entry.get("category", "—"),
            "commands": [c[0] for c in commands],
            "agents":   [a[0] for a in agents],
            "skills":   [s[0] for s in skills],
            "hooks":    hooks,
        })

    return plugins


# ── Generate README table ─────────────────────────────────────────────────────

def make_readme_table(plugins):
    lines = [
        "| Plugin | Version | Description | Category | Components |",
        "|--------|---------|-------------|----------|------------|",
    ]
    for p in plugins:
        comps = []
        if p["commands"]: comps.append(f"{len(p['commands'])} cmd")
        if p["skills"]:   comps.append(f"{len(p['skills'])} skill")
        if p["agents"]:   comps.append(f"{len(p['agents'])} agent")
        if p["hooks"]:    comps.append("hooks")
        comp_str = ", ".join(comps) or "—"

        desc = p["description"]
        if len(desc) > 80:
            desc = desc[:77] + "..."

        lines.append(
            f"| `{p['name']}` | {p['version']} | {desc} | {p['category']} | {comp_str} |"
        )
    return "\n".join(lines)


def update_readme(plugins):
    readme = ROOT / "README.md"
    if not readme.exists():
        print("⚠️  README.md not found — skipping table update", file=sys.stderr)
        return False

    table = make_readme_table(plugins)
    block = f"<!-- PLUGINS-TABLE-START -->\n{table}\n<!-- PLUGINS-TABLE-END -->"

    text = readme.read_text()
    if "<!-- PLUGINS-TABLE-START -->" in text:
        new_text = re.sub(
            r"<!-- PLUGINS-TABLE-START -->.*?<!-- PLUGINS-TABLE-END -->",
            block,
            text,
            flags=re.DOTALL,
        )
    else:
        # Append before the first ## section after badges/intro
        # Simple heuristic: insert before "## Available Plugins" or "## Plugins" or at end
        for marker in ["## Available Plugins", "## Plugins", "## Plugin List"]:
            if marker in text:
                new_text = text.replace(marker, f"{block}\n\n{marker}", 1)
                break
        else:
            new_text = text + f"\n\n{block}\n"

    # Also update plugin count badge (e.g. plugins-5)
    count = len(plugins)
    new_text = re.sub(r"plugins-\d+", f"plugins-{count}", new_text)

    if new_text != text:
        readme.write_text(new_text)
        print(f"✅ README.md updated ({count} plugins, table refreshed)")
        return True
    else:
        print("ℹ️  README.md unchanged")
        return False


# ── Generate plugins-inventory.md ─────────────────────────────────────────────

def generate_inventory(plugins):
    docs_dir = ROOT / "docs"
    docs_dir.mkdir(exist_ok=True)
    inventory = docs_dir / "plugins-inventory.md"

    lines = [
        "# Plugin Inventory",
        "",
        "> Auto-generated by `scripts/sync-docs.py`. Do not edit manually.",
        f"> Last updated: <!-- LAST-UPDATED -->",
        "",
    ]

    for p in plugins:
        lines += [
            f"## {p['name']} `v{p['version']}`",
            "",
            f"**Category:** {p['category']}",
            "",
            f"{p['description']}",
            "",
        ]
        if p["commands"]:
            lines.append(f"**Commands ({len(p['commands'])}):**")
            for c in p["commands"]:
                lines.append(f"- `/{p['name']}:{c}`")
            lines.append("")
        if p["skills"]:
            lines.append(f"**Skills ({len(p['skills'])}):**")
            for s in p["skills"]:
                lines.append(f"- {s}")
            lines.append("")
        if p["agents"]:
            lines.append(f"**Agents ({len(p['agents'])}):**")
            for a in p["agents"]:
                lines.append(f"- {a}")
            lines.append("")
        if p["hooks"]:
            lines.append("**Hooks:** ✅ hooks.json present")
            lines.append("")
        lines.append("---")
        lines.append("")

    content = "\n".join(lines)

    # Inject timestamp
    from datetime import datetime, timezone
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    content = content.replace("<!-- LAST-UPDATED -->", now)

    if inventory.exists() and inventory.read_text() == content:
        print("ℹ️  docs/plugins-inventory.md unchanged")
        return False

    inventory.write_text(content)
    print(f"✅ docs/plugins-inventory.md updated ({len(plugins)} plugins)")
    return True


# ── Main ───────────────────────────────────────────────────────────────────────

def main():
    marketplace_path = ROOT / ".claude-plugin" / "marketplace.json"
    marketplace = read_json(marketplace_path)
    if not marketplace:
        print("❌ Cannot read marketplace.json", file=sys.stderr)
        sys.exit(1)

    plugins = collect_plugin_data(marketplace)
    print(f"Found {len(plugins)} plugins: {[p['name'] for p in plugins]}")

    readme_changed   = update_readme(plugins)
    inventory_changed = generate_inventory(plugins)

    if readme_changed or inventory_changed:
        print("✅ Docs updated — auto-commit will follow")
    else:
        print("✅ All docs already up to date")


if __name__ == "__main__":
    main()
