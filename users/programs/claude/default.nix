# users/programs/claude/default.nix
#
# Shared Claude Code wiring, imported by homeManagerModules.default so it reaches
# EVERY machine through this public library alone — including machines restricted
# to public sources only (the private machine layers never land there). Three pieces:
#
#   1. A live symlink to the portable rules (rules.md) in this repo.
#   2. A live symlink for EVERY skill folder under ./skills — enumerated at eval
#      time, so dropping a new ./skills/<name> here propagates it to all machines
#      on the next rebuild, with no per-skill wiring. Each link targets the live
#      checkout path, so skill edits apply without a rebuild.
#   3. An idempotent guarantee that ~/.claude/CLAUDE.md imports the rules via
#      Claude Code's `@`-import. The personal CLAUDE.md lives in a private personal
#      config layer and is absent on public-only machines, so this library ensures
#      the single import line itself (creating a minimal CLAUDE.md if none exists).
#      Personal/private content stays out of here.
#   4. A REAL ~/.claude/.gitignore (allowlist), copied from ./gitignore on every
#      machine. Copied, not symlinked: git refuses to read a symlinked .gitignore
#      (opens it O_NOFOLLOW), so the rules only take effect from a real file. With
#      it in place, any machine can keep ~/.claude as a local-only git repo using
#      the same allowlist, without duplicating the rules per machine.
#
# CONFIG ONLY — this does NOT install Claude Code (no package/cask/npm). The tool
# is provided per-machine by other means; this only wires its config files. The
# activation uses only bash + coreutils (already in every machine's closure), so
# importing this module adds no new packages.
#
# Skills placed here are PUBLIC and reach every machine. Keep them generic; a
# private/personal skill belongs in a private machine layer, wired there separately.
# A skill that needs runtime state (e.g. /wrap-up reads $LOGSEQ_GRAPH) only fully
# works on machines where that state exists — the symlink is harmless either way.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  claudeDir = "${config.home.homeDirectory}/.claude";
  cfgClaude = "${config.home.homeDirectory}/cfg/users/programs/claude";
  rulesSrc = "${cfgClaude}/rules.md";

  # Skill folder names, read from the store copy of ./skills at eval time. Each
  # symlink points at the LIVE ~/cfg path (not the store), so edits and newly
  # added skills are picked up without a rebuild.
  skillNames = builtins.attrNames (
    lib.filterAttrs (_name: type: type == "directory") (builtins.readDir ./skills)
  );

  skillLinks = builtins.listToAttrs (
    map (name: {
      name = ".claude/skills/${name}";
      value.source = config.lib.file.mkOutOfStoreSymlink "${cfgClaude}/skills/${name}";
    }) skillNames
  );
in
{
  home.file = skillLinks // {
    ".claude/cfg-rules.md".source = config.lib.file.mkOutOfStoreSymlink rulesSrc;
  };

  # Fullscreen (alt-screen) TUI, same as settings.json `tui: "fullscreen"`. The
  # default renderer prints into normal terminal scrollback, which the terminal
  # reflows (and mangles) on every tiling-WM resize; the alt-screen renderer owns
  # the viewport and repaints cleanly. Env var instead of settings.json because
  # settings.json is deliberately per-machine and untracked. Cost: cmd+f only
  # sees the viewport — search the transcript with ctrl+o then `/` (or `[` to
  # dump it into native scrollback).
  home.sessionVariables.CLAUDE_CODE_NO_FLICKER = "1";

  # CLAUDE_CODE_DISABLE_MOUSE deliberately NOT set: tested and rejected — in the
  # alt-screen, trackpad scroll degrades to arrow keys (transcript won't scroll),
  # and the app's own drag-selection covers copying fine.

  # bash-builtin check (no gnugrep dep): read the file with $(< …) and substring-
  # match, then append only if the import line is absent. The mutating append is
  # wrapped in `$DRY_RUN_CMD bash -c '…'` so a dry-run activation only echoes it
  # (the >> redirect stays inside the quoted string and isn't executed).
  home.activation.claudeRulesImport = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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

  # Copy the allowlist .gitignore as a REAL file (git won't follow a symlinked
  # one). Idempotent: only rewrites when content differs, so rebuilds don't churn.
  home.activation.claudeGitignore = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "${claudeDir}"
    $DRY_RUN_CMD ${pkgs.bash}/bin/bash -c '
      src="$1"; dst="$2/.gitignore"
      if [ ! -e "$dst" ] || ! ${pkgs.diffutils}/bin/cmp -s "$src" "$dst"; then
        ${pkgs.coreutils}/bin/install -m 0644 "$src" "$dst"
        echo "[claude] wrote allowlist .gitignore to $dst"
      fi
    ' _ "${./gitignore}" "${claudeDir}"
  '';
}
