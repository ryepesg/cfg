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
# startup-time evals (zoxide/direnv/pfetch) are guarded with `command -v`.

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

    oh-my-zsh = {
      enable = true;
      theme = "agnoster"; # cosmetic only; Spaceship (below) sets the prompt
      plugins = [ "git" "pip" ];
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

      # Host-specific aliases. Harmless on the other machine — an alias only
      # fails if actually run, never at shell startup. (`drs` lives in conf's
      # home-darwin.nix instead, since it carries a personal --override-input.)
      prune = ''
        restic-s3 forget --prune \
                         --keep-last 1 \
                         --keep-within 24h \
                         --keep-daily 7 \
                         --keep-weekly 12 \
                         --keep-monthly 36 \
                         --keep-yearly 15'';
      backup = ''
        restic-s3 backup ~ \
                         --exclude=.cache \
                         --one-file-system \
                         --verbose'';
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

      # Prompt: Spaceship, PATH ONLY. Every other section (git / gcloud / venv /
      # nix_shell / exec_time / …) is removed from the always-on prompt; render
      # any of them on demand with `spsec <section>` or `ctx` (defined below).
      # See the logseq `tool/Spaceship` page. The DIR vars show the real path
      # instead of collapsing to the git repo name, and must precede the source.
      export SPACESHIP_DIR_TRUNC_REPO=false
      export SPACESHIP_DIR_TRUNC=3        # last 3 path segments; 0 = full path
      SPACESHIP_PROMPT_ORDER=(dir char)   # only the path (+ the prompt character)
      source ${pkgs.spaceship-prompt}/share/zsh/site-functions/prompt_spaceship_setup
      autoload -U promptinit; promptinit
      command -v pfetch >/dev/null && pfetch   # fetch logo on terminal start

      # On-demand prompt sections. Spaceship only loads section files listed in
      # the prompt order, so lazy-source the file before rendering it:
      #   spsec gcloud   spsec git   spsec venv   spsec nix_shell
      #   ctx            -> dumps the common context sections at once
      spsec() {
        local s=$1
        [[ -r $SPACESHIP_ROOT/sections/$s.zsh ]] && builtin source $SPACESHIP_ROOT/sections/$s.zsh
        print -P "$(spaceship::section::render "$(spaceship_$s)")"
      }
      ctx() { local s; for s in git gcloud venv nix_shell; do spsec $s; done }

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
}
