# users/programs/claude/default.nix
#
# Shared Claude Code wiring, imported by homeManagerModules.default so it reaches
# EVERY machine through the public cfg input alone — including machines that can't
# clone private repos (conf / claude-config never land there). Two pieces:
#
#   1. A live symlink to the portable rules (rules.md) in this repo.
#   2. An idempotent guarantee that ~/.claude/CLAUDE.md imports those rules via
#      Claude Code's `@`-import. The personal CLAUDE.md lives in the private
#      claude-config repo and is absent on private-repo-restricted machines, so
#      cfg ensures the single import line itself (creating a minimal CLAUDE.md if
#      none exists). Personal/private content stays out of here.
#
# CONFIG ONLY — this does NOT install Claude Code (no package/cask/npm). The tool
# is provided per-machine by other means; cfg just wires its config files. The
# activation uses only bash + coreutils (already in every machine's closure), so
# importing this module adds no new packages.

{ config, lib, pkgs, ... }:

let
  claudeDir = "${config.home.homeDirectory}/.claude";
  # mkOutOfStoreSymlink → live file, edits picked up without a rebuild. Requires
  # ~/cfg cloned at this home path on every machine (same assumption as the other
  # shared dotfile symlinks).
  rulesSrc = "${config.home.homeDirectory}/cfg/users/programs/claude/rules.md";
in
{
  home.file.".claude/cfg-rules.md".source =
    config.lib.file.mkOutOfStoreSymlink rulesSrc;

  # bash-builtin check (no gnugrep dep): read the file with $(< …) and substring-
  # match, then append only if the import line is absent. The mutating append is
  # wrapped in `$DRY_RUN_CMD bash -c '…'` so a dry-run activation only echoes it
  # (the >> redirect stays inside the quoted string and isn't executed).
  home.activation.claudeRulesImport =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "${claudeDir}"
      $DRY_RUN_CMD ${pkgs.bash}/bin/bash -c '
        f="$1/CLAUDE.md"; line="@cfg-rules.md"
        if [ -e "$f" ]; then c="$(< "$f")"; else c=""; fi
        case "$c" in
          *"$line"*) : ;;  # already imported — nothing to do
          *) printf "%s\n" "$line" >> "$f"
             echo "[claude] added $line import to $f" ;;
        esac
      ' _ "${claudeDir}"
    '';
}
