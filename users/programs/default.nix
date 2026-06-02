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
    ./zsh # canonical cross-machine zsh (path-only Spaceship prompt, aliases, history)
    ./git # programs.git + the shared .gitconfig
    ./editors/nvim # neovim (withRuby / withPython3 off)
  ];

  # Classic vim kept available next to neovim, with the shared .vimrc. (editors/
  # provides neovim only, so the vim binary + vimrc are added here, not via the
  # ./vim module — importing that too would double-define programs.neovim.)
  home.file.".vimrc".source = ./vim/vimrc;

  # The portable CLI baseline. Add a tool here once and it lands on every machine
  # that imports this module. Nothing secret or machine-specific belongs in here.
  home.packages = with pkgs; [
    vim

    # system info
    htop
    pfetch

    # docs
    tldr
    manix

    # spelling
    diction
    aspell
    aspellDicts.es
    aspellDicts.en

    # development
    git
    just

    # shell ergonomics
    coreutils
    tree
    pstree
    nushell
    zellij
    grml-zsh-config

    # files
    fd
    ripgrep
    gnugrep
    fzf
    zoxide
    eza
    file
    bat
    lf
    nnn
    sd
    most
    mprocs
    fasd

    # formats
    jq
    yq

    # compress
    unzip
    unrar

    # crypto
    age

    # networking
    nmap
    dnsutils # dig, host, nslookup (single bind bundle, avoids man-page collision)
    wget
    iproute2mac # ip addr, ip link, ... (the macOS shim)
  ];
}
