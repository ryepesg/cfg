# users/programs/zsh/default.nix
#
# Canonical, cross-machine zsh config — the single source of truth shared by:
#   - cfg  (this repo, another machine)              — imported by its home.nix
#   - conf (personal flake) via flake input `cfg` — imported in home-darwin.nix
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
      theme = "agnoster";        # cosmetic only; Spaceship (below) sets the prompt
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
      nano = "kak";
      nix = "noglob nix";        # allow #hashtags in flake refs

      # Cross-platform clipboard: native on macOS, xclip under X11.
      pbcopy = "if [ -f /usr/bin/pbcopy ]; then pbcopy; else xclip -selection c; fi";
      pbpaste = "if [ -f /usr/bin/pbpaste ]; then pbpaste; else xclip -selection clipboard -o; fi";

      # Host-specific aliases. Harmless on the other machine — an alias only
      # fails if actually run, never at shell startup.
      drs = "sudo darwin-rebuild switch --flake ~/conf#macbook";
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

      # Prompt: Spaceship. Show the real directory path instead of collapsing it
      # to the git repo name (these must be set before the prompt is sourced).
      export SPACESHIP_DIR_TRUNC_REPO=false
      export SPACESHIP_DIR_TRUNC=3   # last 3 path segments; set 0 for the full path
      source ${pkgs.spaceship-prompt}/share/zsh/site-functions/prompt_spaceship_setup
      autoload -U promptinit; promptinit
      command -v pfetch >/dev/null && pfetch   # fetch logo on terminal start

      command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
      command -v direnv >/dev/null && eval "$(direnv hook zsh)"
    '';
  };

  programs.command-not-found.enable = false;
  programs.fzf.enableZshIntegration = true;
}
