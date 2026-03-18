#!/usr/bin/env python3
"""Normalize paths between Windows and WSL conventions."""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from pathlib import Path

WINDOWS_DRIVE_RE = re.compile(r"^(?P<drive>[A-Za-z]):[\\/]*(?P<rest>.*)$")
WSL_MOUNT_RE = re.compile(r"^/mnt/(?P<drive>[A-Za-z])(?:/(?P<rest>.*))?$")
WINDOWS_WSL_UNC_RE = re.compile(
    r"^\\\\wsl\$\\(?P<distro>[^\\]+)(?:\\(?P<rest>.*))?$",
    re.IGNORECASE,
)


def fail(message: str, code: int = 1) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(code)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Convert paths between Windows and WSL forms."
    )
    parser.add_argument("path", help="Input path")
    parser.add_argument(
        "--to",
        choices=("auto", "wsl", "windows"),
        default="auto",
        help="Target format (default: auto)",
    )
    parser.add_argument(
        "--distro",
        default=os.environ.get("WSL_DISTRO_NAME", "Ubuntu"),
        help="WSL distro for UNC conversion (default: env WSL_DISTRO_NAME or Ubuntu)",
    )
    parser.add_argument(
        "--windows-style",
        choices=("backslash", "forward"),
        default="backslash",
        help="Windows output separator style (default: backslash)",
    )
    parser.add_argument(
        "--resolve",
        action="store_true",
        help="Resolve relative input paths before conversion",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Print structured JSON output",
    )
    return parser.parse_args()


def detect_kind(path_text: str) -> str:
    if WINDOWS_DRIVE_RE.match(path_text):
        return "windows_drive"
    if WINDOWS_WSL_UNC_RE.match(path_text):
        return "windows_unc"
    if WSL_MOUNT_RE.match(path_text):
        return "wsl_mount"
    if path_text.startswith("/"):
        return "posix"
    return "relative"


def maybe_resolve(path_text: str, resolve: bool) -> str:
    if not resolve:
        return path_text
    if detect_kind(path_text) in {"windows_drive", "windows_unc"}:
        return path_text
    return str(Path(path_text).expanduser().resolve())


def windows_to_wsl(path_text: str) -> str:
    unc_match = WINDOWS_WSL_UNC_RE.match(path_text)
    if unc_match:
        rest = (unc_match.group("rest") or "").replace("\\", "/")
        return "/" + rest.lstrip("/")

    drive_match = WINDOWS_DRIVE_RE.match(path_text)
    if not drive_match:
        fail(f"cannot convert non-Windows path to WSL format: {path_text}")

    drive = drive_match.group("drive").lower()
    rest = drive_match.group("rest").replace("\\", "/").lstrip("/")
    return f"/mnt/{drive}/{rest}" if rest else f"/mnt/{drive}"


def wsl_to_windows(path_text: str, distro: str, windows_style: str) -> str:
    mount_match = WSL_MOUNT_RE.match(path_text)
    if mount_match:
        drive = mount_match.group("drive").upper()
        rest = (mount_match.group("rest") or "").replace("/", "\\")
        output = f"{drive}:\\{rest}" if rest else f"{drive}:\\"
    elif path_text.startswith("/"):
        rest = path_text.lstrip("/").replace("/", "\\")
        output = f"\\\\wsl$\\{distro}\\{rest}" if rest else f"\\\\wsl$\\{distro}\\"
    else:
        fail(f"cannot convert non-WSL path to Windows format: {path_text}")

    if windows_style == "forward":
        return output.replace("\\", "/")
    return output


def main() -> None:
    args = parse_args()
    original = args.path
    normalized_input = maybe_resolve(original, args.resolve)
    source_kind = detect_kind(normalized_input)

    target = args.to
    if target == "auto":
        if source_kind in {"windows_drive", "windows_unc"}:
            target = "wsl"
        elif source_kind in {"wsl_mount", "posix"}:
            target = "windows"
        else:
            target = "wsl"

    if target == "wsl":
        if source_kind in {"windows_drive", "windows_unc"}:
            converted = windows_to_wsl(normalized_input)
        elif source_kind in {"wsl_mount", "posix"}:
            converted = normalized_input
        else:
            converted = str(Path(normalized_input).expanduser().resolve())
    elif target == "windows":
        if source_kind in {"windows_drive", "windows_unc"}:
            converted = normalized_input
            if args.windows_style == "forward":
                converted = converted.replace("\\", "/")
            else:
                converted = converted.replace("/", "\\")
        else:
            absolute_posix = (
                normalized_input
                if source_kind in {"wsl_mount", "posix"}
                else str(Path(normalized_input).expanduser().resolve())
            )
            converted = wsl_to_windows(absolute_posix, args.distro, args.windows_style)
    else:
        fail(f"unsupported target format: {target}")

    if args.json:
        payload = {
            "input": original,
            "normalized_input": normalized_input,
            "source_kind": source_kind,
            "target": target,
            "output": converted,
        }
        print(json.dumps(payload, indent=2, sort_keys=True))
    else:
        print(converted)


if __name__ == "__main__":
    main()
