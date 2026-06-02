# users/programs/zsh/default.nix
#
# Canonical, cross-machine zsh config — the single source of truth shared by:
#   - cfg  (this repo)                            — imported by its home.nix
#   - a downstream flake via flake input `cfg`    — imported in its home config
#
# Written in the current home-manager API (initContent / autosuggestion.enable /
# syntaxHighlighting.enable) so it evaluates on BOTH home-manager release-26.05
# (conf) and unstable (cfg). shellAliases are safe to share even when a target
# is missing on one host (an alias only fails when invoked, not at startup);
# startup-time evals (zoxide/direnv) are guarded with `command -v`.
#
# Deliberately low-opinion so it's safe to import on any machine (incl. a
# corporate one): the prompt is Starship (HM-native, fast, cross-shell) on its
# defaults; completion + autosuggestion + syntax highlighting use home-manager's
# native options rather than oh-my-zsh. Machine-specific bits (pentest tools,
# restic helpers) live in the consuming flake, not here.

{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    history = {
      expireDuplicatesFirst = true;
      ignoreDups = true;
      share = true;
      size = 1000000;
    };

    shellAliases = {
      mv = "mv -i";
      cp = "cp -i";
      rm = "rm -i";
      ls = "eza";
      cat = "bat";
      less = "bat";
      more = "bat";
      rg = "rg --color=always";
      jq = "jq -C";
      nix = "noglob nix"; # allow #hashtags in flake refs

      # Cross-platform clipboard: native on macOS, xclip under X11.
      pbcopy = "if [ -f /usr/bin/pbcopy ]; then pbcopy; else xclip -selection c; fi";
      pbpaste = "if [ -f /usr/bin/pbpaste ]; then pbpaste; else xclip -selection clipboard -o; fi";
    };

    initContent = ''
      export PATH=$PATH:~/.local/bin

      bindkey '^R' history-incremental-search-backward

      # Don't record typos / unknown commands in history. Runs before execution,
      # so it keeps a line only if its command word resolves (alias / function /
      # builtin / binary). Skips leading VAR=value assignments. Only the first
      # command word is checked, so e.g. `sudo <typo>` can still be recorded.
      zshaddhistory() {
        emulate -L zsh
        local w
        for w in ''${(z)1}; do
          [[ $w == [A-Za-z_][A-Za-z0-9_]*=* ]] && continue
          whence -- $w >/dev/null 2>&1 && return 0 || return 1
        done
        return 0
      }

      # Prompt is Starship (programs.starship below), on its defaults — it shows
      # directory plus per-directory context (git / python / nix-shell / …)
      # automatically and is wired into zsh by home-manager.

      command -v fastfetch >/dev/null && fastfetch   # system-info logo on start

      command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

      # A fresh interactive shell shouldn't inherit a parent's direnv state (e.g.
      # the terminal/WM was launched from inside a direnv'd dir). Without this,
      # direnv's first hook sees the inherited DIRENV_DIR, notices we aren't in
      # it, and prints a spurious "direnv: unloading". Drop the bookkeeping so it
      # starts clean (a real direnv dir just re-loads, cached & instant).
      unset DIRENV_DIFF DIRENV_DIR DIRENV_FILE DIRENV_WATCHES
      command -v direnv >/dev/null && eval "$(direnv hook zsh)"
    '';
  };

  programs.command-not-found.enable = false;
  programs.fzf.enableZshIntegration = true;

  # Prompt. Starship on its defaults: fast, cross-shell, corporate-neutral, and
  # auto-shows directory context. home-manager installs the package and adds the
  # zsh integration (enableZshIntegration defaults true). Customise per-machine
  # via programs.starship.settings if ever needed.
  programs.starship.enable = true;
}
