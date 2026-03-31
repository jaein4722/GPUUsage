#!/usr/bin/env python3

from __future__ import annotations

import argparse
import pathlib
import re
import sys


def extract_release_notes(changelog: str, version: str) -> str:
    pattern = re.compile(
        rf"^## {re.escape(version)}(?:\s+-\s+[^\n]+)?\n(?P<body>.*?)(?=^## |\Z)",
        re.MULTILINE | re.DOTALL,
    )
    match = pattern.search(changelog)
    if match is None:
        raise ValueError(f"Could not find CHANGELOG entry for version {version}")

    body = match.group("body").strip()
    if not body:
        raise ValueError(f"CHANGELOG entry for version {version} is empty")

    return body + "\n"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--version", required=True)
    parser.add_argument("--changelog", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    changelog_path = pathlib.Path(args.changelog)
    output_path = pathlib.Path(args.output)

    notes = extract_release_notes(changelog_path.read_text(), args.version)
    output_path.write_text(notes)
    return 0


if __name__ == "__main__":
    sys.exit(main())
