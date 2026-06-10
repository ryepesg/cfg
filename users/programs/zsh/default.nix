# users/programs/zsh/default.nix
#
# Canonical, cross-machine zsh config — the single source of truth shared by:
#   - cfg  (this repo)                            — imported by its home.nix
#   - a downstream flake via flake input `cfg`    — imported in its home config
#
# Written in the current home-manager API (initContent / autosuggestion.enable /
# syntaxHighlighting.enable) so it evaluates on BOTH home-manager release-26.05
# and unstable (cfg). shellAliases are safe to share even when a target
# is missing on one host (an alias only fails when invoked, not at startup).
# zoxide / direnv / fzf are wired via their native home-manager modules (which
# add the startup hooks), not hand-written `command -v … && eval` lines.
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
#     ships an `l` alias, but it was never sourced here.) See the personal
#     notes on the config split for the full evaluation.

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
      # cp/mv pinned to the BSD /bin versions: macOS's cp/mv preserve extended
      # attributes (com.apple.* xattrs — Finder tags, quarantine, resource forks)
      # that the GNU coreutils cp/mv (ahead on PATH) silently drop. -i prompts
      # before clobbering. rm has no such metadata concern, so it stays bare.
      mv = "/bin/mv -i";
      cp = "/bin/cp -i";
      rm = "rm -i";
      # not mapping ls to eza to avoid claude getting confused, use other aliases like l
      # ls = "eza";
      # ls-family shorthands carried over from oh-my-zsh (dropped — see header),
      # remapped to eza. NB: eza has no `-A`; its `-a` already hides ./.. like
      # `ls -A`, and `-h` adds a header row (eza sizes are human-readable anyway).
      l = "eza -lah"; # long + hidden + header   (omz l='ls -lah')
      la = "eza -lah"; # omz la='ls -lAh' (no -A in eza → same as l here)
      ll = "eza -lh"; # long + header, no hidden (omz ll='ls -lh')
      lsa = "eza -lah"; # omz lsa='ls -lah' (alias of l)
      tree = "eza -T"; # tree view via eza (replaces the standalone `tree` pkg)
      cat = "bat";
      less = "bat";
      more = "bat";
      rg = "rg --color=always";
      jq = "jq -C";
      nix = "noglob nix"; # allow #hashtags in flake refs
      gs = "git status"; # NB: shadows ghostscript's `gs` (use `command gs` for that)
      gst = "git status -s"; # mirror the `st` git alias (status -s); omz muscle memory

      # Cross-platform clipboard: native on macOS, xclip under X11. Both commented
      # out — cfg is macOS-only now, so the native pbcopy/pbpaste are used directly
      # and the xclip fallback is dead. Re-enable if a Linux/X11 consumer appears.
      # pbcopy = "if [ -f /usr/bin/pbcopy ]; then pbcopy; else xclip -selection c; fi";
      # pbpaste = "if [ -f /usr/bin/pbpaste ]; then pbpaste; else xclip -selection clipboard -o; fi";
    };

    initContent = lib.mkMerge [ ''
      export PATH=$PATH:~/.local/bin

      # Completion UX. `enableCompletion` runs compinit but leaves bare zsh
      # defaults; these restore the essentials lost when grml/oh-my-zsh went away
      # (menu, case-insensitive + partial matching, colours, grouping). zstyles
      # are consulted at completion time, so order vs compinit doesn't matter.
      # (For an fzf-driven TAB menu instead, add the fzf-tab plugin.)
      command -v dircolors >/dev/null && eval "$(dircolors -b)" # populate LS_COLORS (colours completion + eza)
      zstyle ':completion:*' menu select                                      # arrow-key selectable menu
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'l:|=* r:|=*' # case-insensitive + partial
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"              # colourise the candidate list
      zstyle ':completion:*' group-name '''                                   # group matches by category
      zstyle ':completion:*:descriptions' format '%B%F{blue}%d%f%b'           # category headers
      setopt COMPLETE_IN_WORD ALWAYS_TO_END                                   # complete mid-word, cursor to end

      # Prefix history search on Up/Down. Type a prefix (e.g. `vim`) and press
      # Up to cycle through ONLY the history entries beginning with what's typed
      # (the match is the buffer up to the cursor). This is what oh-my-zsh gave
      # us via lib/key-bindings.zsh; it was lost when omz was removed, leaving
      # zsh's default up-line-or-history (plain chronological walk). The
      # *-beginning-search widgets also still move within a multi-line buffer.
      autoload -U up-line-or-beginning-search down-line-or-beginning-search
      zle -N up-line-or-beginning-search
      zle -N down-line-or-beginning-search
      bindkey '^[[A' up-line-or-beginning-search   # Up   — normal cursor mode
      bindkey '^[OA' up-line-or-beginning-search   # Up   — application mode
      bindkey '^[[B' down-line-or-beginning-search # Down — normal cursor mode
      bindkey '^[OB' down-line-or-beginning-search # Down — application mode
      # terminfo codes too, for terminals that report non-standard sequences
      [[ -n ''${terminfo[kcuu1]} ]] && bindkey "''${terminfo[kcuu1]}" up-line-or-beginning-search
      [[ -n ''${terminfo[kcud1]} ]] && bindkey "''${terminfo[kcud1]}" down-line-or-beginning-search

      # Ctrl+←/→ → no-op: consume the sequence so it inserts nothing (otherwise the
      # unbound `;5D`/`;5C` tail self-inserts). Intentional — retraining onto native
      # macOS word motion (Opt+←/→).
      noop() {}
      zle -N noop
      bindkey '^[[1;5C' noop  # Ctrl+Right
      bindkey '^[[1;5D' noop  # Ctrl+Left

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

      # `grep` nudge: still runs the real grep (scripts/pipes are unaffected — this
      # interactive function isn't seen by separate script processes), but prints a
      # reminder to STDERR to retrain onto `rg -P`. `command grep` avoids recursion;
      # "$@" + returning grep's status keeps `if grep -q …`, pipes, `grep -c`, etc.
      # working unchanged.
      grep() {
        print -u2 "reminder: prefer 'rg -P' (ripgrep, PCRE2) — running grep anyway"
        command grep "$@"
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
    ''

    # Under Claude Code (CLAUDECODE=1), strip aliases that mask a real binary so
    # the agent hits the genuine tool (no colour codes, pager swaps, or -i hangs).
    # mkAfter so it runs past HM's shellAliases block, at rc-source time (fires in
    # the non-interactive shell). $commands[x] is set iff a binary x is on $PATH,
    # so pure launchers (l/ll/tree/gst/…) are kept.
    (lib.mkAfter ''
      if [[ -n $CLAUDECODE ]]; then
        () {
          local a
          for a in ''${(k)aliases}; do
            (( ''${+commands[$a]} )) && unalias -- "$a"
          done
        }
        # Drop the grep nudge; pin to native BSD grep (no stderr noise, beats a
        # GNU grep that might sit ahead on $PATH).
        unfunction grep 2>/dev/null
        [[ -x /usr/bin/grep ]] && grep() { /usr/bin/grep "$@"; }
      fi
    '')
    ];
  };

  # Binaries the aliases/config above depend on, so this module is self-contained
  # when imported on its own (homeManagerModules.zsh): eza → ls/l/la/ll/lsa/tree;
  # bat → cat/less/more; ripgrep → rg (and the grep nudge points at it); jq → jq.
  # fzf/zoxide/direnv/starship install themselves via their programs.* options;
  # dircolors (coreutils) is `command -v`-guarded. default.nix re-uses these via
  # its `./zsh` import, so it no longer lists them itself.
  home.packages = with pkgs; [ eza bat ripgrep jq ];

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
