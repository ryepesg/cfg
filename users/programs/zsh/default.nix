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
# Deliberately low-opinion so it's safe to import on any machine: the prompt is
# Starship (HM-native, fast, cross-shell) trimmed to directory + git; completion
# + autosuggestion + syntax highlighting use home-manager's native options rather
# than oh-my-zsh.
#
# No zsh framework, on purpose:
#   - oh-my-zsh REMOVED. What we actually used from it (git/completion plugins,
#     the ls-family aliases l/la/ll/lsa) is covered by HM-native options +
#     Starship; the ls aliases were re-added explicitly below. Dropping omz
#     removes a whole framework + its startup cost for things we already have.
#   - grml-zsh-config deliberately NOT adopted. It's an all-or-nothing zshrc
#     that clashes with Starship (prompt) and double-runs compinit/zstyles, and
#     duplicates what we set natively — net redundant + conflict-prone. (It also
#     ships an `l` alias, but it was never sourced here.) See logseq
#     `cs/os/Nix/conf and cfg` for the full evaluation.

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
      # ls-family shorthands carried over from oh-my-zsh (dropped — see header),
      # remapped to eza. NB: eza has no `-A`; its `-a` already hides ./.. like
      # `ls -A`, and `-h` adds a header row (eza sizes are human-readable anyway).
      l = "eza -lah"; # long + hidden + header   (omz l='ls -lah')
      la = "eza -lah"; # omz la='ls -lAh' (no -A in eza → same as l here)
      ll = "eza -lh"; # long + header, no hidden (omz ll='ls -lh')
      lsa = "eza -lah"; # omz lsa='ls -lah' (alias of l)
      cat = "bat";
      less = "bat";
      more = "bat";
      rg = "rg --color=always";
      jq = "jq -C";
      nix = "noglob nix"; # allow #hashtags in flake refs
      gs = "git status"; # NB: shadows ghostscript's `gs` (use `command gs` for that)

      # Cross-platform clipboard: native on macOS, xclip under X11. Both commented
      # out — cfg is macOS-only now, so the native pbcopy/pbpaste are used directly
      # and the xclip fallback is dead. Re-enable if a Linux/X11 consumer appears.
      # pbcopy = "if [ -f /usr/bin/pbcopy ]; then pbcopy; else xclip -selection c; fi";
      # pbpaste = "if [ -f /usr/bin/pbpaste ]; then pbpaste; else xclip -selection clipboard -o; fi";
    };

    initContent = ''
      export PATH=$PATH:~/.local/bin

      # Ctrl-R is left to fzf's fuzzy history widget (programs.fzf below). A
      # manual `bindkey '^R' history-incremental-search-backward` used to live
      # here and clobbered it — removed so fzf owns reverse history search.

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

      # Prompt is Starship (programs.starship below) — wired into zsh by
      # home-manager and trimmed to directory + git (see its settings). A
      # startup system-info logo is a per-machine opt-in, not shared here.

      # A fresh interactive shell shouldn't inherit a parent's direnv state (e.g.
      # the terminal/WM was launched from inside a direnv'd dir). Without this,
      # direnv's first hook sees the inherited DIRENV_DIR, notices we aren't in
      # it, and prints a spurious "direnv: unloading". Drop that bookkeeping so a
      # new shell starts clean (a real direnv dir just re-loads, cached/instant).
      # MUST run before the direnv hook — that hook now comes from
      # programs.direnv.enableZshIntegration (below), which home-manager appends
      # AFTER this initContent, so the ordering is preserved.
      unset DIRENV_DIFF DIRENV_DIR DIRENV_FILE DIRENV_WATCHES
    '';
  };

  programs.command-not-found.enable = false;

  # Shell-integration tools, owned fully by home-manager: enabling each installs
  # the binary AND adds its zsh hook (enableZshIntegration defaults true), so we
  # neither list them as packages nor hand-write `eval "$(… init/hook zsh)"`.
  # direnv's hook is appended after the initContent above, i.e. after the
  # DIRENV_* unset, which is exactly the ordering that suppresses "unloading".
  programs.fzf.enable = true;
  programs.zoxide.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Prompt. Starship (fast, cross-shell, visually neutral). home-manager installs
  # the package + zsh integration (enableZshIntegration defaults true).
  programs.starship.enable = true;
  programs.starship.settings = {
    # Quiet, focused prompt: directory + git only. The `format` string is an
    # explicit allowlist — any module NOT listed is omitted, so the noisy
    # context modules (nix_shell, gcloud/cloud, python/venv, language versions,
    # cmd_duration, …) never render. Add a module back by inserting its
    # `$name` here. git_branch = branch name; git_status = dirty/ahead markers.
    format = "$directory$git_branch$git_status$character";

    # Keep Starship's default truncate_to_repo = true (the prompt path collapses
    # to the git-repo root). The full working path is already shown in the
    # Ghostty window/tab title, so repeating it in the prompt is redundant.
    # To show the real path in the prompt instead (the old Spaceship
    # SPACESHIP_DIR_TRUNC_REPO=false), uncomment:
    # directory.truncate_to_repo = false;
  };
}
