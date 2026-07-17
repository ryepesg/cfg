import unittest

import mdplain


class FoldTests(unittest.TestCase):
    def test_default_mode_is_not_explicit_text_expanded(self):
        text = "OAuth SKILL.md SQLite FTS tailnet v0.18.2"
        self.assertEqual(mdplain.fold(text), text)

    def test_spell_mode_expands_explicit_tokens(self):
        text = "OAuth SKILL.md SQLite FTS MCP CVSS"
        expected = (
            "O auth skill dot M D SQLite F T S M C P C V S S"
        )
        self.assertEqual(mdplain.fold(text, spell=True), expected)

    def test_spell_mode_expands_versions_and_cve_digits(self):
        text = "v0.18.2 0.16.0 CVE-2026-53869"
        expected = (
            "version zero point eighteen point two "
            "zero point sixteen point zero "
            "C V E two zero two six five three eight six nine"
        )
        self.assertEqual(mdplain.fold(text, spell=True), expected)

    def test_dollar_range_still_works(self):
        self.assertEqual(mdplain.fold("$18-160/mo"),
                         "18 to 160 dollars a month")


if __name__ == "__main__":
    unittest.main()
