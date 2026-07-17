#!/usr/bin/env python3
"""Regression tests for lint_portable_skill.py."""

from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from lint_portable_skill import lint_skill


class PortableSkillLintTests(unittest.TestCase):
    def write_skill(self, name: str, contents: str) -> Path:
        root = Path(self.tempdir.name) / name
        root.mkdir()
        (root / "SKILL.md").write_text(contents, encoding="utf-8")
        return root

    def setUp(self) -> None:
        self.tempdir = tempfile.TemporaryDirectory()

    def tearDown(self) -> None:
        self.tempdir.cleanup()

    def test_minimal_portable_skill_passes_strict_core(self) -> None:
        root = self.write_skill(
            "good-skill",
            "---\nname: good-skill\ndescription: Check a useful thing.\n---\n\n# Do it\n",
        )
        self.assertEqual(lint_skill(root, True, []).status, "PASS")

    def test_standard_optional_field_only_fails_strict_policy(self) -> None:
        root = self.write_skill(
            "good-skill",
            "---\nname: good-skill\ndescription: Check it.\nlicense: Apache-2.0\n---\nBody\n",
        )
        self.assertEqual(lint_skill(root, False, []).status, "PASS")
        self.assertEqual(lint_skill(root, True, []).status, "FAIL")

    def test_unknown_field_fails(self) -> None:
        root = self.write_skill(
            "bad-skill",
            "---\nname: bad-skill\ndescription: Check it.\ncontext: fork\n---\nBody\n",
        )
        result = lint_skill(root, False, [])
        self.assertEqual(result.status, "FAIL")
        self.assertIn("SPEC002", {item.code for item in result.diagnostics})

    def test_missing_local_resource_fails(self) -> None:
        root = self.write_skill(
            "bad-link",
            "---\nname: bad-link\ndescription: Check it.\n---\nRead [details](references/missing.md).\n",
        )
        result = lint_skill(root, True, [])
        self.assertIn("RES001", {item.code for item in result.diagnostics})

    def test_harness_invocation_is_a_warning(self) -> None:
        root = self.write_skill(
            "invoke-me",
            "---\nname: invoke-me\ndescription: Check it.\n---\nRun $invoke-me now.\n",
        )
        result = lint_skill(root, True, [])
        self.assertEqual(result.status, "WARN")
        self.assertIn("PORT107", {item.code for item in result.diagnostics})

    def test_folded_description_is_supported(self) -> None:
        root = self.write_skill(
            "folded-skill",
            "---\nname: folded-skill\ndescription: >-\n  A description spread over\n  two source lines.\n---\nBody\n",
        )
        self.assertEqual(lint_skill(root, True, []).status, "PASS")


if __name__ == "__main__":
    unittest.main()
