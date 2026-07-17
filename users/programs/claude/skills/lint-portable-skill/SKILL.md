---
name: lint-portable-skill
description: Validate an Agent Skills package for portable use across multiple agent harnesses. Use when creating, reviewing, or troubleshooting a SKILL.md intended for Claude, Codex, Omnigent, or another Agent Skills client; when checking strict frontmatter, local resource references, and harness-specific leakage; or before distributing one canonical skill through symlinks or a synchronization bridge.
---

# Lint a portable skill

Treat content portability and runtime behavior as separate claims. Passing this
lint means the skill conforms to the shared file contract; it does not prove that
clients share invocation grammar, permissions, memory, tools, or orchestration.

## Workflow

1. Resolve the target skill directory and this skill's own directory from the
   loaded `SKILL.md` paths.
2. Run the dependency-free checker:

   ```text
   python3 <this-skill-directory>/scripts/lint_portable_skill.py --strict-core <target-skill-directory>
   ```

3. Fix errors before warnings. Errors cover malformed packages or violations of
   the selected contract. Warnings identify experimental fields, client-shaped
   instructions, missing portability evidence, or maintainability risks.
4. Re-run the checker and report its exact result. Do not translate a clean file
   check into a claim of runtime equivalence.
5. When a client exposes a deterministic validator, add it as an external probe:

   ```text
   python3 <this-skill-directory>/scripts/lint_portable_skill.py \
     --strict-core \
     --external 'client-name=client-command validate {skill}' \
     <target-skill-directory>
   ```

   The command runs without a shell. Quote the whole `NAME=COMMAND` argument and
   use `{skill}` where the absolute target path belongs. A failed or unavailable
   probe is a lint failure, not evidence about clients that were not tested.

Use `--json` for machine-readable results. Without `--strict-core`, standardized
optional Agent Skills fields are accepted; the strict workspace policy permits
only `name` and `description` in core frontmatter and keeps client metadata at the
edges.

## Interpretation

- `PASS`: no errors or warnings.
- `WARN`: no errors, but portability risks remain; exit status is still zero.
- `FAIL`: at least one error or failed external probe; exit status is one.
- `2`: command-line usage error.

The checker intentionally accepts only a conservative YAML subset that every
target client should be able to parse. If a richer YAML construct is intentional,
validate it with each real client rather than weakening the portable contract.
