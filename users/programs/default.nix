# users/programs/default.nix
#
# cfg.homeManagerModules.default — the SHARED home baseline both machines import.
# This is the "install a CLI tool once → both laptops" bundle: the portable,
# non-secret home-manager config (the CLI package baseline + the canonical
# program modules). A machine's private flake imports this via
# `inputs.cfg.homeManagerModules.default` and adds only a thin per-machine delta
# (secrets, Homebrew casks / system settings, machine-only packages, the `drs`
# alias, live-edited dotfile symlinks).
#
# Rules for what may live here (see logseq `cs/os/Nix/conf and cfg`):
#   - non-secret AND useful on more than one machine -> belongs here,
#   - secret / machine-or-system-specific -> stays in the machine's private flake.
#
# Channel-agnostic: must evaluate on whatever nixpkgs each consumer follows
# (currently nixos-unstable on both macs). Keep it darwin-safe — no X11-only
# tools (e.g. xclip); the zsh module already falls back to pbcopy on macOS.

{ config, lib, pkgs, ... }:

{
  imports = [
    ./zsh # canonical cross-machine zsh (Starship prompt, aliases, history)
    ./git # programs.git aliases/tools (identity-free; name/email set per-machine)
    ./editors/nvim # neovim (withRuby / withPython3 off)
  ];

  # The shared .vimrc, applied to whatever vim is present. macOS ships a `vim`
  # binary, so we don't install one here (editors/ provides neovim only —
  # importing ./vim too would double-define programs.neovim). Uncomment `vim` in
  # the package list below for a machine without a system vim.
  home.file.".vimrc".source = ./vim/vimrc;

  # tealdeer: fast Rust `tldr` client (provides the `tldr` command), managed via
  # its program module rather than a bare package so the cache auto-updates.
  programs.tealdeer = {
    enable = true;
    settings.updates = {
      auto_update = true;
      auto_update_interval_hours = 720; # refresh the page cache every 30 days
    };
  };

  # The portable CLI baseline. Add a tool here once and it lands on every machine
  # that imports this module. Nothing secret or machine-specific belongs in here.
  home.packages = with pkgs; [
    # vim — macOS ships a system vim; the shared .vimrc above applies to it.

    # system info
    btop

    # spelling — standalone CLI spell checker, NOT editor-coupled (vim/neovim use
    # their own built-in `:set spell`). Personal-preference + unclear usage, so
    # commented out of the shared baseline; re-enable here, or add to a machine's
    # conf, if actually used.
    # diction  # GNU style/grammar checker (1990s-era). Modern alternative is
    #          # Vale (vale.sh) — a configurable prose linter with style rules.
    # aspell
    # aspellDicts.es
    # aspellDicts.en

    # development
    git

    # shell ergonomics
    coreutils
    # tree — replaced by the `tree = "eza -T"` shell alias (zsh module)
    pstree

    # files
    fd
    ripgrep
    gnugrep
    # fzf + zoxide are installed by their home-manager program modules (see the
    # zsh module: programs.fzf.enable / programs.zoxide.enable) — not listed here.
    eza
    # file — macOS ships /usr/bin/file
    bat
    # lf — TUI file manager, not currently used; also undecided vs yazi (a more
    # modern Rust TUI file manager with image previews). Re-enable lf or add yazi
    # if/when a TUI file manager is wanted.
    sd

    # formats
    jq
    yq

    # compress
    #unzip
    #unrar

    # crypto
    #age

    # networking
    # dnsutils # dig/host/nslookup — macOS ships these, so commented out
    # wget excluded: curl ships with macOS and covers everyday fetching; add wget
    # per-machine only if recursive/mirroring downloads are actually needed.
    # iproute2mac kept on purpose: macOS has ifconfig/netstat/route but NOT `ip`;
    # this shim provides `ip addr`/`ip link` for Linux parity.
    iproute2mac
  ];
}
