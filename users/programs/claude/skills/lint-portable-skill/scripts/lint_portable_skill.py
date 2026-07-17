#!/usr/bin/env python3
"""Lint Agent Skills packages using a conservative, portable contract."""

from __future__ import annotations

import argparse
import json
import re
import shlex
import subprocess
import sys
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, Iterable
from urllib.parse import unquote


SPEC_FIELDS = {
    "name",
    "description",
    "license",
    "compatibility",
    "metadata",
    "allowed-tools",
}
CORE_FIELDS = {"name", "description"}
NAME_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
KEY_RE = re.compile(r"^([A-Za-z0-9_-]+):(?:[ \t]*(.*))?$")
LINK_RE = re.compile(r"!?\[[^\]]*\]\(([^)]+)\)")


@dataclass
class Diagnostic:
    level: str
    code: str
    message: str
    line: int | None = None


@dataclass
class ProbeResult:
    name: str
    command: list[str]
    returncode: int | None
    output: str


@dataclass
class SkillResult:
    path: str
    status: str
    diagnostics: list[Diagnostic]
    probes: list[ProbeResult]


class FrontmatterError(ValueError):
    def __init__(self, message: str, line: int | None = None):
        super().__init__(message)
        self.line = line


def scalar_value(raw: str, line: int) -> str:
    value = raw.strip()
    if not value:
        raise FrontmatterError("empty values are not portable scalars", line)
    if value[0] in "[{&*!":
        raise FrontmatterError(
            "flow collections, anchors, aliases, and tags are outside the portable subset",
            line,
        )
    if value.startswith('"'):
        try:
            parsed = json.loads(value)
        except json.JSONDecodeError as exc:
            raise FrontmatterError(f"invalid double-quoted scalar: {exc.msg}", line) from exc
        if not isinstance(parsed, str):
            raise FrontmatterError("frontmatter scalar must be a string", line)
        return parsed
    if value.startswith("'"):
        if len(value) < 2 or not value.endswith("'"):
            raise FrontmatterError("unterminated single-quoted scalar", line)
        return value[1:-1].replace("''", "'")
    if value.endswith(('"', "'")):
        raise FrontmatterError("unmatched quote in plain scalar", line)
    if re.search(r":\s", value):
        raise FrontmatterError("quote plain scalars containing a colon followed by space", line)
    value = re.split(r"\s+#", value, maxsplit=1)[0].rstrip()
    if value.lower() in {"null", "~", "true", "false"} or re.fullmatch(
        r"[-+]?\d+(?:\.\d+)?", value
    ):
        raise FrontmatterError("quote YAML-typed values so they remain strings", line)
    return value


def block_value(lines: list[str], start: int, marker: str) -> tuple[str, int]:
    collected: list[str] = []
    i = start
    while i < len(lines):
        line = lines[i]
        if line and not line[0].isspace():
            break
        collected.append(line)
        i += 1
    nonblank = [len(line) - len(line.lstrip(" ")) for line in collected if line.strip()]
    if not nonblank:
        raise FrontmatterError("block scalar is empty", start + 2)
    indent = min(nonblank)
    if indent == 0 or any("\t" in line[:indent] for line in collected if line.strip()):
        raise FrontmatterError("block scalars require consistent space indentation", start + 2)
    dedented = [line[indent:] if line.strip() else "" for line in collected]
    text = "\n".join(dedented)
    if marker.startswith(">"):
        text = re.sub(r"(?<!\n)\n(?!\n)", " ", text)
    return text.strip(), i


def parse_frontmatter(lines: list[str]) -> dict[str, Any]:
    values: dict[str, Any] = {}
    i = 0
    while i < len(lines):
        source = lines[i]
        line_no = i + 2
        if not source.strip() or source.lstrip().startswith("#"):
            i += 1
            continue
        if "\t" in source:
            raise FrontmatterError("tabs are not allowed in portable frontmatter", line_no)
        if source[0].isspace():
            raise FrontmatterError("unexpected indentation at top level", line_no)
        match = KEY_RE.match(source)
        if not match:
            raise FrontmatterError("expected a top-level key and scalar value", line_no)
        key, raw = match.groups()
        if key in values:
            raise FrontmatterError(f"duplicate key: {key}", line_no)
        raw = raw or ""
        if raw in {"|", "|-", "|+", ">", ">-", ">+"}:
            value, i = block_value(lines, i + 1, raw)
            values[key] = value
            continue
        if key == "metadata" and not raw.strip():
            metadata: dict[str, str] = {}
            i += 1
            while i < len(lines) and (not lines[i] or lines[i][0].isspace()):
                child = lines[i]
                child_no = i + 2
                if not child.strip() or child.lstrip().startswith("#"):
                    i += 1
                    continue
                if "\t" in child:
                    raise FrontmatterError("tabs are not allowed in metadata", child_no)
                indent = len(child) - len(child.lstrip(" "))
                if indent < 2:
                    break
                child_match = KEY_RE.match(child[indent:])
                if not child_match:
                    raise FrontmatterError("metadata must map string keys to strings", child_no)
                child_key, child_raw = child_match.groups()
                if child_key in metadata:
                    raise FrontmatterError(f"duplicate metadata key: {child_key}", child_no)
                metadata[child_key] = scalar_value(child_raw or "", child_no)
                i += 1
            if not metadata:
                raise FrontmatterError("metadata mapping is empty", line_no)
            values[key] = metadata
            continue
        values[key] = scalar_value(raw, line_no)
        i += 1
    return values


def load_skill(path: Path) -> tuple[Path, dict[str, Any], str]:
    skill_file = path if path.name == "SKILL.md" else path / "SKILL.md"
    if not skill_file.is_file():
        raise FrontmatterError(f"SKILL.md not found at {skill_file}")
    try:
        text = skill_file.read_text(encoding="utf-8")
    except UnicodeDecodeError as exc:
        raise FrontmatterError("SKILL.md must be UTF-8") from exc
    lines = text.splitlines()
    if not lines or lines[0] != "---":
        raise FrontmatterError("frontmatter must begin with --- on line 1", 1)
    try:
        closing = lines.index("---", 1)
    except ValueError as exc:
        raise FrontmatterError("frontmatter has no closing --- delimiter", 1) from exc
    fields = parse_frontmatter(lines[1:closing])
    body = "\n".join(lines[closing + 1 :]).strip()
    return skill_file.parent, fields, body


def add(
    diagnostics: list[Diagnostic],
    level: str,
    code: str,
    message: str,
    line: int | None = None,
) -> None:
    diagnostics.append(Diagnostic(level, code, message, line))


def validate_fields(
    root: Path,
    fields: dict[str, Any],
    body: str,
    strict_core: bool,
    diagnostics: list[Diagnostic],
) -> None:
    for required in sorted(CORE_FIELDS - fields.keys()):
        add(diagnostics, "error", "SPEC001", f"missing required field: {required}")
    for key in fields:
        if key not in SPEC_FIELDS:
            add(diagnostics, "error", "SPEC002", f"unknown Agent Skills field: {key}")
        elif strict_core and key not in CORE_FIELDS:
            add(
                diagnostics,
                "error",
                "PORT001",
                f"strict core permits only name and description; move {key} to an edge adapter",
            )
    name = fields.get("name")
    if isinstance(name, str):
        if not 1 <= len(name) <= 64 or not NAME_RE.fullmatch(name):
            add(
                diagnostics,
                "error",
                "SPEC003",
                "name must be 1-64 lowercase letters, digits, or single hyphen separators",
            )
        if name != root.name:
            add(
                diagnostics,
                "error",
                "SPEC004",
                f"name {name!r} does not match parent directory {root.name!r}",
            )
    description = fields.get("description")
    if isinstance(description, str) and not 1 <= len(description) <= 1024:
        add(diagnostics, "error", "SPEC005", "description must be 1-1024 characters")
    compatibility = fields.get("compatibility")
    if isinstance(compatibility, str) and len(compatibility) > 500:
        add(diagnostics, "error", "SPEC006", "compatibility must be at most 500 characters")
    if "allowed-tools" in fields:
        add(
            diagnostics,
            "warning",
            "PORT002",
            "allowed-tools is experimental and client support varies",
        )
    if not body:
        add(diagnostics, "error", "SPEC007", "instruction body is empty")
    elif len(body.splitlines()) > 500:
        add(
            diagnostics,
            "warning",
            "MAINT001",
            "SKILL.md exceeds 500 body lines; move detailed material into focused resources",
        )


def local_link_target(raw: str) -> str | None:
    target = raw.strip()
    if target.startswith("<") and ">" in target:
        target = target[1 : target.index(">")]
    else:
        try:
            target = shlex.split(target)[0]
        except (ValueError, IndexError):
            return None
    if re.match(r"^[a-zA-Z][a-zA-Z0-9+.-]*:", target) or target.startswith("#"):
        return None
    return unquote(target.split("#", 1)[0].split("?", 1)[0])


def validate_resources(root: Path, body: str, diagnostics: list[Diagnostic]) -> None:
    resolved_root = root.resolve()
    seen: set[str] = set()
    for match in LINK_RE.finditer(body):
        target = local_link_target(match.group(1))
        if not target or target in seen:
            continue
        seen.add(target)
        candidate = (root / target).resolve()
        try:
            candidate.relative_to(resolved_root)
        except ValueError:
            add(
                diagnostics,
                "error",
                "PORT003",
                f"local reference escapes the skill directory: {target}",
            )
            continue
        if not candidate.exists():
            add(diagnostics, "error", "RES001", f"local reference does not exist: {target}")
    for dirname in ("scripts", "references", "assets", "agents"):
        item = root / dirname
        if item.exists() and not item.is_dir():
            add(diagnostics, "error", "RES002", f"reserved resource path is not a directory: {dirname}")


def validate_harness_leakage(body: str, name: str, diagnostics: list[Diagnostic]) -> None:
    rules: list[tuple[str, str, str]] = [
        (r"\$\{?CLAUDE_SKILL_DIR\}?", "PORT101", "Claude-only skill directory variable"),
        (r"\b(?:disable-model-invocation|when_to_use|argument-hint)\b", "PORT102", "Claude-specific skill metadata"),
        (r"\bcontext\s*:\s*fork\b", "PORT103", "Claude-specific execution context"),
        (r"\b(?:WebFetch|WebSearch|Task)\b", "PORT104", "harness-specific tool name"),
        (r"\bmcp__[A-Za-z0-9_]+", "PORT105", "Codex-shaped MCP tool name"),
        (r"\b(?:apply_patch|request_user_input)\b", "PORT106", "Codex-specific tool name"),
    ]
    if name:
        rules.extend(
            [
                (rf"(?<!\w)\${re.escape(name)}\b", "PORT107", "Codex invocation syntax"),
                (rf"(?<!\w)/{re.escape(name)}\b", "PORT108", "Claude invocation syntax"),
            ]
        )
    for pattern, code, label in rules:
        if re.search(pattern, body):
            add(
                diagnostics,
                "warning",
                code,
                f"instruction body contains {label}; express the capability without client syntax",
            )


def parse_external(value: str) -> tuple[str, list[str]]:
    name, separator, command = value.partition("=")
    if not separator or not name.strip() or not command.strip():
        raise argparse.ArgumentTypeError("external probe must be NAME=COMMAND")
    try:
        argv = shlex.split(command)
    except ValueError as exc:
        raise argparse.ArgumentTypeError(f"invalid external probe command: {exc}") from exc
    if not argv:
        raise argparse.ArgumentTypeError("external probe command is empty")
    return name.strip(), argv


def run_probes(root: Path, probes: Iterable[tuple[str, list[str]]]) -> list[ProbeResult]:
    results: list[ProbeResult] = []
    for name, template in probes:
        used_placeholder = any("{skill}" in part for part in template)
        command = [part.replace("{skill}", str(root.resolve())) for part in template]
        if not used_placeholder:
            command.append(str(root.resolve()))
        try:
            completed = subprocess.run(
                command,
                check=False,
                capture_output=True,
                text=True,
                timeout=60,
            )
            output = "\n".join(
                part.strip() for part in (completed.stdout, completed.stderr) if part.strip()
            )
            results.append(ProbeResult(name, command, completed.returncode, output))
        except FileNotFoundError:
            results.append(ProbeResult(name, command, None, "validator executable not found"))
        except subprocess.TimeoutExpired:
            results.append(ProbeResult(name, command, None, "validator timed out after 60 seconds"))
    return results


def lint_skill(
    path: Path,
    strict_core: bool,
    external: list[tuple[str, list[str]]],
) -> SkillResult:
    diagnostics: list[Diagnostic] = []
    probes: list[ProbeResult] = []
    try:
        root, fields, body = load_skill(path)
        validate_fields(root, fields, body, strict_core, diagnostics)
        validate_resources(root, body, diagnostics)
        validate_harness_leakage(body, str(fields.get("name", "")), diagnostics)
        probes = run_probes(root, external)
        for probe in probes:
            if probe.returncode != 0:
                add(
                    diagnostics,
                    "error",
                    "PROBE001",
                    f"external validator {probe.name!r} did not pass: {probe.output}",
                )
    except (FrontmatterError, OSError) as exc:
        add(
            diagnostics,
            "error",
            "PARSE001",
            str(exc),
            getattr(exc, "line", None),
        )
    levels = {item.level for item in diagnostics}
    status = "FAIL" if "error" in levels else "WARN" if "warning" in levels else "PASS"
    return SkillResult(str(path), status, diagnostics, probes)


def print_human(results: list[SkillResult]) -> None:
    for result in results:
        print(f"{result.status} {result.path}")
        for item in result.diagnostics:
            location = f" line {item.line}" if item.line else ""
            print(f"  {item.level.upper():7} {item.code}{location}: {item.message}")
        for probe in result.probes:
            outcome = "PASS" if probe.returncode == 0 else "FAIL"
            print(f"  PROBE   {outcome} {probe.name}: {shlex.join(probe.command)}")
            if probe.output and probe.returncode == 0:
                print(f"          {probe.output}")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Lint Agent Skills packages for conservative cross-harness portability."
    )
    parser.add_argument("paths", nargs="+", type=Path, help="skill directory or SKILL.md")
    parser.add_argument(
        "--strict-core",
        action="store_true",
        help="allow only name and description in core frontmatter",
    )
    parser.add_argument("--json", action="store_true", help="emit JSON results")
    parser.add_argument(
        "--external",
        action="append",
        default=[],
        type=parse_external,
        metavar="NAME=COMMAND",
        help="run a client validator; {skill} expands to the absolute skill directory",
    )
    return parser


def main() -> int:
    args = build_parser().parse_args()
    results = [lint_skill(path, args.strict_core, args.external) for path in args.paths]
    if args.json:
        print(json.dumps([asdict(result) for result in results], indent=2))
    else:
        print_human(results)
    return 1 if any(result.status == "FAIL" for result in results) else 0


if __name__ == "__main__":
    sys.exit(main())
