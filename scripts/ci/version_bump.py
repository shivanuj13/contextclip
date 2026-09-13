#!/usr/bin/env python3
"""Decide whether main should cut a GitHub / Homebrew release.

A release is created only when pubspec.yaml `version:` changed vs the
previous commit, and tag vMAJOR.MINOR.PATCH does not already exist.
"""

from __future__ import annotations

import os
import re
import subprocess
import sys
from pathlib import Path

VERSION_RE = re.compile(r"^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$", re.M)


def parse_version(text: str) -> tuple[str, str]:
    match = VERSION_RE.search(text)
    if not match:
        raise SystemExit("Could not parse `version: x.y.z+build` from pubspec.yaml")
    return match.group(1), match.group(2)


def git(*args: str) -> str:
    return subprocess.check_output(["git", *args], text=True).strip()


def write_output(**values: str) -> None:
    dest = os.environ.get("GITHUB_OUTPUT")
    if not dest:
        for key, value in values.items():
            print(f"{key}={value}")
        return
    with open(dest, "a", encoding="utf-8") as handle:
        for key, value in values.items():
            handle.write(f"{key}={value}\n")


def main() -> int:
    force = os.environ.get("FORCE_RELEASE", "").lower() in {"1", "true", "yes"}
    pubspec = Path("pubspec.yaml").read_text(encoding="utf-8")
    marketing, build = parse_version(pubspec)
    tag = f"v{marketing}"

    previous = None
    try:
        old = git("show", "HEAD^:pubspec.yaml")
        previous = parse_version(old)
    except subprocess.CalledProcessError:
        previous = None

    changed = previous != (marketing, build)
    try:
        tag_exists = bool(git("tag", "-l", tag))
    except subprocess.CalledProcessError:
        tag_exists = False

    if tag_exists:
        should = False
        reason = f"tag {tag} already exists — bump the x.y.z part of pubspec.yaml"
    elif changed or force:
        should = True
        if changed:
            reason = f"version bumped to {marketing}+{build}"
        else:
            reason = f"forced release of {marketing}+{build}"
    else:
        should = False
        reason = "pubspec.yaml version unchanged"

    write_output(
        should_release="true" if should else "false",
        version=marketing,
        build=build,
        tag=tag,
        reason=reason,
    )
    print(reason)
    return 0


if __name__ == "__main__":
    sys.exit(main())
