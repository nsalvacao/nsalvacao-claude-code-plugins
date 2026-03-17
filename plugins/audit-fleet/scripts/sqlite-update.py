#!/usr/bin/env python3
"""Update and export audit-fleet SQLite lifecycle data."""

from __future__ import annotations

import argparse
import json
import sqlite3
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ALLOWED_STATUSES = ("pending", "in_progress", "done", "blocked")
ALLOWED_TRANSITIONS: dict[str, set[str]] = {
    "pending": {"in_progress", "blocked"},
    "in_progress": {"pending", "blocked", "done"},
    "blocked": {"pending", "in_progress"},
    "done": {"pending"},
}

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


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def fail(message: str, code: int = 1) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(code)


def lane_todo_id(report_file: str) -> str:
    return f"lane-{Path(report_file).stem}"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Manage todos and lifecycle transitions for audit-fleet orchestration."
    )
    parser.add_argument(
        "--db",
        default=".audit-fleet/audit-fleet.sqlite3",
        help="SQLite database path (default: .audit-fleet/audit-fleet.sqlite3)",
    )

    subparsers = parser.add_subparsers(dest="command", required=True)

    create_todo = subparsers.add_parser("create-todo", help="Create or update a todo entry")
    create_todo.add_argument("--todo-id", required=True, help="Todo identifier")
    create_todo.add_argument("--title", required=True, help="Todo title")
    create_todo.add_argument("--description", default="", help="Todo description")
    create_todo.add_argument(
        "--status",
        choices=ALLOWED_STATUSES,
        default="pending",
        help="Initial status (default: pending)",
    )
    create_todo.add_argument("--replace", action="store_true", help="Replace existing todo values")

    add_dep = subparsers.add_parser("add-dependency", help="Add a dependency between todos")
    add_dep.add_argument("--todo-id", required=True, help="Dependent todo id")
    add_dep.add_argument("--depends-on", required=True, help="Dependency todo id")

    set_status = subparsers.add_parser("set-status", help="Transition a todo lifecycle state")
    set_status.add_argument("--todo-id", required=True, help="Todo identifier")
    set_status.add_argument("--to-status", choices=ALLOWED_STATUSES, required=True)
    set_status.add_argument("--force", action="store_true", help="Bypass transition checks")
    set_status.add_argument("--allow-noop", action="store_true", help="Allow status unchanged")

    seed = subparsers.add_parser("seed-fleet", help="Seed deterministic lane todos/dependencies")
    seed.add_argument("--replace", action="store_true", help="Reset existing lane todos to pending")

    barrier = subparsers.add_parser("barrier-status", help="Compute fan-out/fan-in barrier status")
    barrier.add_argument(
        "--output",
        help="Optional JSON output file. If omitted, prints to stdout only",
    )

    export_contract = subparsers.add_parser("export-contract", help="Export sqlite-contract JSON")
    export_contract.add_argument(
        "--output",
        default=".audit-fleet/sqlite-contract.json",
        help="Output JSON path (default: .audit-fleet/sqlite-contract.json)",
    )

    status = subparsers.add_parser("status", help="Generate deterministic orchestration status")
    status.add_argument(
        "--mode",
        choices=("strict", "balanced"),
        default="balanced",
        help="Status evaluation mode (default: balanced)",
    )
    status.add_argument(
        "--reports-check",
        default=".audit-fleet/reports-check.json",
        help="Path to reports-check output JSON",
    )
    status.add_argument(
        "--bundle",
        default=".audit-fleet/audit-bundle.json",
        help="Path to audit bundle JSON",
    )
    status.add_argument(
        "--validation",
        default=".audit-fleet/validation-result.json",
        help="Path to validation result JSON",
    )
    status.add_argument(
        "--output",
        default=".audit-fleet/status.json",
        help="Deterministic status output path (default: .audit-fleet/status.json)",
    )

    return parser.parse_args()


def connect(db_path: Path) -> sqlite3.Connection:
    try:
        conn = sqlite3.connect(str(db_path))
    except sqlite3.Error as exc:
        fail(f"cannot open database '{db_path}': {exc}")
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON;")
    return conn


def ensure_schema(conn: sqlite3.Connection) -> None:
    rows = conn.execute(
        """
        SELECT name
        FROM sqlite_master
        WHERE type = 'table' AND name IN ('todos', 'todo_deps')
        ORDER BY name
        """
    ).fetchall()
    names = [row["name"] for row in rows]
    missing = [name for name in ("todos", "todo_deps") if name not in names]
    if missing:
        fail(
            "database schema is incomplete. Missing tables: "
            + ", ".join(missing)
            + ". Run sqlite-init.py first."
        )


def todo_exists(conn: sqlite3.Connection, todo_id: str) -> bool:
    row = conn.execute("SELECT 1 FROM todos WHERE id = ?", (todo_id,)).fetchone()
    return row is not None


def handle_create_todo(conn: sqlite3.Connection, args: argparse.Namespace) -> dict[str, Any]:
    todo_id = args.todo_id.strip()
    title = args.title.strip()
    if not todo_id:
        fail("--todo-id cannot be empty")
    if not title:
        fail("--title cannot be empty")

    now = utc_now()
    existing = conn.execute("SELECT id FROM todos WHERE id = ?", (todo_id,)).fetchone()

    if existing and not args.replace:
        fail(f"todo '{todo_id}' already exists; use --replace to overwrite")

    if existing and args.replace:
        conn.execute(
            """
            UPDATE todos
            SET title = ?, description = ?, status = ?, updated_at = ?
            WHERE id = ?
            """,
            (title, args.description, args.status, now, todo_id),
        )
        action = "updated"
    else:
        conn.execute(
            """
            INSERT INTO todos(id, title, description, status, created_at, updated_at)
            VALUES(?, ?, ?, ?, ?, ?)
            """,
            (todo_id, title, args.description, args.status, now, now),
        )
        action = "created"

    return {
        "ok": True,
        "action": action,
        "todo_id": todo_id,
        "status": args.status,
        "updated_at": now,
    }


def handle_add_dependency(conn: sqlite3.Connection, args: argparse.Namespace) -> dict[str, Any]:
    todo_id = args.todo_id.strip()
    depends_on = args.depends_on.strip()
    if not todo_id or not depends_on:
        fail("--todo-id and --depends-on must be non-empty")
    if todo_id == depends_on:
        fail("dependency cannot reference the same todo")
    if not todo_exists(conn, todo_id):
        fail(f"todo '{todo_id}' does not exist")
    if not todo_exists(conn, depends_on):
        fail(f"dependency target '{depends_on}' does not exist")

    now = utc_now()
    try:
        conn.execute(
            """
            INSERT INTO todo_deps(todo_id, depends_on, created_at)
            VALUES(?, ?, ?)
            """,
            (todo_id, depends_on, now),
        )
    except sqlite3.IntegrityError as exc:
        fail(f"cannot add dependency {todo_id} -> {depends_on}: {exc}")

    return {
        "ok": True,
        "action": "dependency_added",
        "todo_id": todo_id,
        "depends_on": depends_on,
    }


def handle_set_status(conn: sqlite3.Connection, args: argparse.Namespace) -> dict[str, Any]:
    todo_id = args.todo_id.strip()
    target = args.to_status
    row = conn.execute("SELECT status FROM todos WHERE id = ?", (todo_id,)).fetchone()
    if row is None:
        fail(f"todo '{todo_id}' not found")
    current = row["status"]

    if current == target:
        if not args.allow_noop:
            fail(
                f"todo '{todo_id}' is already '{target}'. "
                "Use --allow-noop to acknowledge no-op transitions."
            )
        return {
            "ok": True,
            "action": "noop",
            "todo_id": todo_id,
            "from_status": current,
            "to_status": target,
            "changed": False,
        }

    allowed = ALLOWED_TRANSITIONS.get(current, set())
    if target not in allowed and not args.force:
        fail(
            f"invalid transition for todo '{todo_id}': {current} -> {target}. "
            f"Allowed from {current}: {', '.join(sorted(allowed)) or '<none>'}. "
            "Use --force to bypass lifecycle checks."
        )

    now = utc_now()
    conn.execute(
        "UPDATE todos SET status = ?, updated_at = ? WHERE id = ?",
        (target, now, todo_id),
    )
    return {
        "ok": True,
        "action": "status_updated",
        "todo_id": todo_id,
        "from_status": current,
        "to_status": target,
        "changed": True,
        "forced": bool(args.force),
        "updated_at": now,
    }


def handle_seed_fleet(conn: sqlite3.Connection, replace: bool) -> dict[str, Any]:
    now = utc_now()
    inserted_todos = 0
    updated_todos = 0
    inserted_deps = 0

    for report_file in REQUIRED_REPORT_FILES:
        lane = Path(report_file).stem
        todo_id = lane_todo_id(report_file)
        title = f"Audit lane {lane}"
        description = f"Produce {report_file} aligned to blueprint and plan contract"

        existing = conn.execute("SELECT id FROM todos WHERE id = ?", (todo_id,)).fetchone()
        if existing is None:
            conn.execute(
                """
                INSERT INTO todos(id, title, description, status, created_at, updated_at)
                VALUES(?, ?, ?, 'pending', ?, ?)
                """,
                (todo_id, title, description, now, now),
            )
            inserted_todos += 1
        elif replace:
            conn.execute(
                """
                UPDATE todos
                SET title = ?, description = ?, status = 'pending', updated_at = ?
                WHERE id = ?
                """,
                (title, description, now, todo_id),
            )
            updated_todos += 1

    consolidator = lane_todo_id("00-executive-summary.md")
    for report_file in REQUIRED_REPORT_FILES:
        if report_file.startswith("00-"):
            continue
        specialist = lane_todo_id(report_file)
        row = conn.execute(
            "SELECT 1 FROM todo_deps WHERE todo_id = ? AND depends_on = ?",
            (consolidator, specialist),
        ).fetchone()
        if row is None:
            conn.execute(
                """
                INSERT INTO todo_deps(todo_id, depends_on, created_at)
                VALUES(?, ?, ?)
                """,
                (consolidator, specialist, now),
            )
            inserted_deps += 1

    return {
        "ok": True,
        "action": "fleet_seeded",
        "seeded_todos": inserted_todos,
        "updated_todos": updated_todos,
        "seeded_dependencies": inserted_deps,
    }


def compute_barrier_snapshot(conn: sqlite3.Connection) -> dict[str, Any]:
    lane_ids = [Path(name).stem for name in REQUIRED_REPORT_FILES]
    specialist_ids = [lane for lane in lane_ids if not lane.startswith("00-")]

    status_by_lane: dict[str, str] = {}
    missing_lanes: list[str] = []

    for lane in lane_ids:
        todo_id = f"lane-{lane}"
        row = conn.execute("SELECT status FROM todos WHERE id = ?", (todo_id,)).fetchone()
        if row is None:
            missing_lanes.append(lane)
        else:
            status_by_lane[lane] = str(row["status"])

    specialist_counts = {status: 0 for status in ALLOWED_STATUSES}
    specialist_missing = 0
    for lane in specialist_ids:
        status = status_by_lane.get(lane)
        if status is None:
            specialist_missing += 1
        else:
            specialist_counts[status] += 1

    consolidator_status = status_by_lane.get("00-executive-summary", "missing")
    all_specialists_done = specialist_counts["done"] == len(specialist_ids) and specialist_missing == 0
    ready_for_fan_in = all_specialists_done and consolidator_status != "missing"

    return {
        "required_reports": REQUIRED_REPORT_FILES,
        "lanes": lane_ids,
        "status_by_lane": status_by_lane,
        "missing_lanes": missing_lanes,
        "specialists": {
            "count": len(specialist_ids),
            "done": specialist_counts["done"],
            "in_progress": specialist_counts["in_progress"],
            "pending": specialist_counts["pending"],
            "blocked": specialist_counts["blocked"],
            "missing": specialist_missing,
        },
        "consolidator": {
            "lane": "00-executive-summary",
            "status": consolidator_status,
        },
        "all_specialists_done": all_specialists_done,
        "ready_for_fan_in": ready_for_fan_in,
    }


def write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    try:
        path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    except OSError as exc:
        fail(f"cannot write JSON file '{path}': {exc}")


def load_optional_json(path: Path, label: str, warnings: list[str], errors: list[str]) -> dict[str, Any] | None:
    if not path.exists():
        warnings.append(f"{label} file not found: {path}")
        return None
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except OSError as exc:
        errors.append(f"cannot read {label} file {path}: {exc}")
        return None
    except json.JSONDecodeError as exc:
        errors.append(f"invalid JSON in {label} file {path}: {exc}")
        return None
    if not isinstance(payload, dict):
        errors.append(f"{label} payload must be a JSON object: {path}")
        return None
    return payload


def handle_barrier_status(conn: sqlite3.Connection, output: str | None) -> dict[str, Any]:
    snapshot = compute_barrier_snapshot(conn)
    result = {
        "ok": True,
        "generated_at": utc_now(),
        "barrier": snapshot,
    }
    if output:
        write_json(Path(output).expanduser(), result)
    return result


def serialize_transitions() -> list[dict[str, Any]]:
    return [
        {"from": src, "to": sorted(list(dst))}
        for src, dst in sorted(ALLOWED_TRANSITIONS.items())
    ]


def handle_export_contract(conn: sqlite3.Connection, output: str, db_path: Path) -> dict[str, Any]:
    todos_rows = conn.execute(
        """
        SELECT id, title, description, status, created_at, updated_at
        FROM todos
        ORDER BY id
        """
    ).fetchall()
    deps_rows = conn.execute(
        """
        SELECT todo_id, depends_on, created_at
        FROM todo_deps
        ORDER BY todo_id, depends_on
        """
    ).fetchall()

    contract = {
        "schema_version": "1.0.0",
        "database": str(db_path),
        "generated_at": utc_now(),
        "lifecycle": {
            "statuses": list(ALLOWED_STATUSES),
            "transitions": serialize_transitions(),
        },
        "todos": [dict(row) for row in todos_rows],
        "todo_deps": [dict(row) for row in deps_rows],
    }

    output_path = Path(output).expanduser()
    write_json(output_path, contract)

    return {
        "ok": True,
        "action": "contract_exported",
        "output": str(output_path),
        "todo_count": len(contract["todos"]),
        "dependency_count": len(contract["todo_deps"]),
    }


def handle_status(conn: sqlite3.Connection, args: argparse.Namespace) -> dict[str, Any]:
    warnings: list[str] = []
    errors: list[str] = []

    todo_counts = {status: 0 for status in ALLOWED_STATUSES}
    for row in conn.execute(
        "SELECT status, COUNT(*) AS c FROM todos GROUP BY status ORDER BY status"
    ).fetchall():
        status = str(row["status"])
        if status in todo_counts:
            todo_counts[status] = int(row["c"])

    dep_count_row = conn.execute("SELECT COUNT(*) AS c FROM todo_deps").fetchone()
    dep_count = int(dep_count_row["c"]) if dep_count_row else 0

    barrier = compute_barrier_snapshot(conn)

    reports_check_payload = load_optional_json(
        Path(args.reports_check).expanduser(), "reports-check", warnings, errors
    )
    bundle_payload = load_optional_json(Path(args.bundle).expanduser(), "bundle", warnings, errors)
    validation_payload = load_optional_json(
        Path(args.validation).expanduser(), "validation", warnings, errors
    )

    report_inventory_complete = False
    if reports_check_payload is not None:
        missing_reports = reports_check_payload.get("missing_reports", [])
        if not isinstance(missing_reports, list):
            errors.append("reports-check.missing_reports must be an array")
        report_inventory_complete = isinstance(missing_reports, list) and len(missing_reports) == 0

    bundle_report_count = None
    if bundle_payload is not None:
        count_value = bundle_payload.get("report_count")
        if not isinstance(count_value, int):
            errors.append("bundle.report_count must be an integer")
        else:
            bundle_report_count = count_value

    validation_ok = False
    if validation_payload is not None:
        ok_value = validation_payload.get("ok")
        if not isinstance(ok_value, bool):
            errors.append("validation.ok must be a boolean")
        else:
            validation_ok = ok_value

    healthy = (
        not errors
        and report_inventory_complete
        and validation_ok
        and barrier["ready_for_fan_in"]
        and todo_counts["blocked"] == 0
    )

    result = {
        "ok": healthy,
        "mode": args.mode,
        "generated_at": utc_now(),
        "database": str(Path(args.db).expanduser()),
        "todo_counts": todo_counts,
        "dependency_count": dep_count,
        "barrier": barrier,
        "report_inventory_complete": report_inventory_complete,
        "bundle_report_count": bundle_report_count,
        "validation_ok": validation_ok,
        "healthy": healthy,
        "warnings": warnings,
        "errors": errors,
    }

    output_path = Path(args.output).expanduser()
    write_json(output_path, result)

    strict_failed = args.mode == "strict" and (warnings or not healthy)
    if strict_failed:
        result["ok"] = False

    return result


def main() -> None:
    args = parse_args()
    db_path = Path(args.db).expanduser()
    conn = connect(db_path)

    try:
        ensure_schema(conn)
        with conn:
            if args.command == "create-todo":
                result = handle_create_todo(conn, args)
            elif args.command == "add-dependency":
                result = handle_add_dependency(conn, args)
            elif args.command == "set-status":
                result = handle_set_status(conn, args)
            elif args.command == "seed-fleet":
                result = handle_seed_fleet(conn, args.replace)
            elif args.command == "barrier-status":
                result = handle_barrier_status(conn, args.output)
            elif args.command == "export-contract":
                result = handle_export_contract(conn, args.output, db_path)
            elif args.command == "status":
                result = handle_status(conn, args)
            else:
                fail(f"unsupported command: {args.command}")
    except sqlite3.Error as exc:
        fail(f"database operation failed: {exc}")
    finally:
        conn.close()

    print(json.dumps(result, indent=2, sort_keys=True))

    if args.command == "status" and args.mode == "strict":
        status_failed = not bool(result.get("ok", False))
        strict_warnings = bool(result.get("warnings"))
        if status_failed or strict_warnings:
            raise SystemExit(1)


if __name__ == "__main__":
    main()
