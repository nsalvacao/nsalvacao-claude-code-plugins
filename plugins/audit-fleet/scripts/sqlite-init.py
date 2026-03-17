#!/usr/bin/env python3
"""Initialize audit-fleet SQLite storage and optional lane seed data."""

from __future__ import annotations

import argparse
import json
import sqlite3
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ALLOWED_STATUSES = ("pending", "in_progress", "done", "blocked")

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

CREATE_TABLES_SQL = """
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS todos (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL CHECK(status IN ('pending', 'in_progress', 'done', 'blocked')),
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS todo_deps (
  todo_id TEXT NOT NULL,
  depends_on TEXT NOT NULL,
  created_at TEXT NOT NULL,
  PRIMARY KEY (todo_id, depends_on),
  FOREIGN KEY (todo_id) REFERENCES todos(id) ON DELETE CASCADE,
  FOREIGN KEY (depends_on) REFERENCES todos(id) ON DELETE CASCADE,
  CHECK (todo_id <> depends_on)
);

CREATE INDEX IF NOT EXISTS idx_todos_status ON todos(status);
CREATE INDEX IF NOT EXISTS idx_todo_deps_depends_on ON todo_deps(depends_on);
"""


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def fail(message: str, code: int = 1) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(code)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Initialize audit-fleet SQLite DB with tables todos + todo_deps."
    )
    parser.add_argument(
        "--db",
        default=".audit-fleet/audit-fleet.sqlite3",
        help="SQLite database path (default: .audit-fleet/audit-fleet.sqlite3)",
    )
    parser.add_argument(
        "--if-exists",
        choices=("keep", "reset", "fail"),
        default="keep",
        help="Behavior when schema already exists (default: keep)",
    )
    parser.add_argument(
        "--seed-json",
        help="Optional JSON payload {'todos': [...], 'todo_deps': [...]} for seed data",
    )
    parser.add_argument(
        "--seed-fleet",
        action="store_true",
        help="Seed deterministic lane todos and dependencies for reports 00..13",
    )
    parser.add_argument(
        "--replace-seed",
        action="store_true",
        help="When seeding, update existing lane todos back to pending",
    )
    return parser.parse_args()


def table_exists(conn: sqlite3.Connection, table_name: str) -> bool:
    row = conn.execute(
        "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ?",
        (table_name,),
    ).fetchone()
    return row is not None


def ensure_parent_dir(db_path: Path) -> None:
    db_path.parent.mkdir(parents=True, exist_ok=True)


def init_schema(conn: sqlite3.Connection, if_exists: str) -> None:
    schema_exists = table_exists(conn, "todos") or table_exists(conn, "todo_deps")

    if schema_exists and if_exists == "fail":
        fail("schema already exists; use --if-exists keep or --if-exists reset")

    if schema_exists and if_exists == "reset":
        conn.executescript(
            """
            DROP TABLE IF EXISTS todo_deps;
            DROP TABLE IF EXISTS todos;
            """
        )

    conn.executescript(CREATE_TABLES_SQL)


def read_seed_payload(seed_path: Path) -> dict[str, Any]:
    try:
        raw = seed_path.read_text(encoding="utf-8")
    except OSError as exc:
        fail(f"cannot read seed file {seed_path}: {exc}")

    try:
        payload = json.loads(raw)
    except json.JSONDecodeError as exc:
        fail(f"invalid seed JSON in {seed_path}: {exc}")

    if not isinstance(payload, dict):
        fail("seed payload must be a JSON object")
    return payload


def seed_todos(conn: sqlite3.Connection, todos: Any) -> int:
    if todos is None:
        return 0
    if not isinstance(todos, list):
        fail("'todos' in seed payload must be a list")

    inserted = 0
    for item in todos:
        if not isinstance(item, dict):
            fail("each todo seed entry must be an object")

        todo_id = item.get("id")
        title = item.get("title")
        description = item.get("description", "")
        status = item.get("status", "pending")

        if not isinstance(todo_id, str) or not todo_id.strip():
            fail("seed todo entry requires non-empty string 'id'")
        if not isinstance(title, str) or not title.strip():
            fail(f"seed todo '{todo_id}' requires non-empty string 'title'")
        if not isinstance(description, str):
            fail(f"seed todo '{todo_id}' has non-string 'description'")
        if status not in ALLOWED_STATUSES:
            fail(
                f"seed todo '{todo_id}' has invalid status '{status}'. "
                f"Allowed: {', '.join(ALLOWED_STATUSES)}"
            )

        now = utc_now()
        conn.execute(
            """
            INSERT INTO todos(id, title, description, status, created_at, updated_at)
            VALUES(?, ?, ?, ?, ?, ?)
            """,
            (todo_id.strip(), title.strip(), description, status, now, now),
        )
        inserted += 1
    return inserted


def seed_todo_deps(conn: sqlite3.Connection, deps: Any) -> int:
    if deps is None:
        return 0
    if not isinstance(deps, list):
        fail("'todo_deps' in seed payload must be a list")

    inserted = 0
    for item in deps:
        if not isinstance(item, dict):
            fail("each todo_deps seed entry must be an object")

        todo_id = item.get("todo_id")
        depends_on = item.get("depends_on")
        if not isinstance(todo_id, str) or not todo_id.strip():
            fail("seed dependency requires non-empty string 'todo_id'")
        if not isinstance(depends_on, str) or not depends_on.strip():
            fail("seed dependency requires non-empty string 'depends_on'")
        if todo_id.strip() == depends_on.strip():
            fail("seed dependency cannot reference itself")

        now = utc_now()
        conn.execute(
            """
            INSERT INTO todo_deps(todo_id, depends_on, created_at)
            VALUES(?, ?, ?)
            """,
            (todo_id.strip(), depends_on.strip(), now),
        )
        inserted += 1
    return inserted


def lane_todo_id(report_file: str) -> str:
    return f"lane-{Path(report_file).stem}"


def seed_fleet(conn: sqlite3.Connection, replace_seed: bool) -> dict[str, int]:
    now = utc_now()
    inserted_todos = 0
    updated_todos = 0
    inserted_deps = 0

    for report_file in REQUIRED_REPORT_FILES:
        lane_id = Path(report_file).stem
        todo_id = lane_todo_id(report_file)
        title = f"Audit lane {lane_id}"
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
        elif replace_seed:
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
        existing_dep = conn.execute(
            "SELECT 1 FROM todo_deps WHERE todo_id = ? AND depends_on = ?",
            (consolidator, specialist),
        ).fetchone()
        if existing_dep is None:
            conn.execute(
                """
                INSERT INTO todo_deps(todo_id, depends_on, created_at)
                VALUES(?, ?, ?)
                """,
                (consolidator, specialist, now),
            )
            inserted_deps += 1

    return {
        "seeded_todos": inserted_todos,
        "updated_todos": updated_todos,
        "seeded_dependencies": inserted_deps,
    }


def main() -> None:
    args = parse_args()
    db_path = Path(args.db).expanduser()
    ensure_parent_dir(db_path)

    try:
        conn = sqlite3.connect(str(db_path))
    except sqlite3.Error as exc:
        fail(f"cannot open database '{db_path}': {exc}")

    todos_seeded = 0
    deps_seeded = 0
    fleet_result = {"seeded_todos": 0, "updated_todos": 0, "seeded_dependencies": 0}

    try:
        with conn:
            conn.execute("PRAGMA foreign_keys = ON;")
            init_schema(conn, args.if_exists)

            if args.seed_json:
                payload = read_seed_payload(Path(args.seed_json).expanduser())
                todos_seeded = seed_todos(conn, payload.get("todos"))
                deps_seeded = seed_todo_deps(conn, payload.get("todo_deps"))

            if args.seed_fleet:
                fleet_result = seed_fleet(conn, args.replace_seed)

    except sqlite3.IntegrityError as exc:
        fail(f"seed data violates database constraints: {exc}")
    except sqlite3.Error as exc:
        fail(f"database operation failed: {exc}")
    finally:
        conn.close()

    result = {
        "ok": True,
        "database": str(db_path),
        "tables": ["todos", "todo_deps"],
        "allowed_statuses": list(ALLOWED_STATUSES),
        "todos_seeded": todos_seeded,
        "todo_deps_seeded": deps_seeded,
        "fleet_seed": fleet_result,
    }
    print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
