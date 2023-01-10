{ config, pkgs, user, ... }:
let
  inherit (pkgs) callPackage;
  restic-s3 = pkgs.callPackage ./features/restic/restic-s3.nix { homeDir = "${config.home.homeDirectory}"; };
in
{

  home.packages = with pkgs; [

    # system info
    htop
    pfetch

    # development
    git
    google-cloud-sdk
    dotnet-sdk_7
    fsharp

    # shell ergonomics
    xclip
    tree
    pstree
    coreutils
    nushell
    bat
    fd
    ripgrep
    gnugrep
    fzf
    zoxide
    exa
    file
    tldr
    grml-zsh-config

    # extra editors
    helix

    # formats
    jq
    yq

    # networking
    wget
    nmap
    httpie
    netcat-gnu

    # secret management
    sops
    age

    # backup
    restic-s3

    (let
      my-python-packages = python-packages: with python-packages; [
        toolz
        ipython
      ];
      python-with-my-packages = python3.withPackages my-python-packages;
    in
    python-with-my-packages)
  ];

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      dracula-theme.theme-dracula
      vscodevim.vim
      yzhang.markdown-all-in-one
      ms-python.python
      ionide.ionide-fsharp
      thenuprojectcontributors.vscode-nushell-lang
      streetsidesoftware.code-spell-checker
      ms-vscode.hexeditor
      #ms-vscode.PowerShell
      ms-python.vscode-pylance
      kahole.magit
      jnoortheen.nix-ide
      eamodio.gitlens
      bbenoist.nix
      b4dm4n.vscode-nixpkgs-fmt
      vspacecode.whichkey
      vspacecode.vspacecode
    ];
  };

  programs.tmux = {
    enable = true;
    #clock24 = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      {
        plugin = tilish;
        extraConfig = ''
          set -g @tilish-default 'main-vertical'
        '';
      }
      # resurrect
      # yank
      #{
      #  plugin = dracula;
      #  extraConfig = ''
      #    set -g @dracula-show-battery false
      #    set -g @dracula-show-powerline true
      #    set -g @dracula-refresh-rate 10
      #  '';
      #}
    ];

    #extraConfig = ''
    #  set -g mouse on
    #'';

  };

  home.file.".tmux.conf" = {
    source = ./programs/tmux.conf;
  };

  home.file.".logseq/" = {
    source = ./programs/logseq;
    recursive = true;
  };

  home.file."./.init.sh" = {
    source = ./init.sh;
  };

  home.file."./.ssh/config" = {
    source = ./programs/ssh-config;
  };

  # Setup tmux plugins
  # git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  home.file.".tmux/plugins/tpm" = {
    recursive = true;
    source = pkgs.fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tpm";
      rev = "v3.1.0";
      sha256 = "sha256-CeI9Wq6tHqV68woE11lIY4cLoNY8XWyXyMHTDmFKJKI=";
    };
  };

  home.sessionVariables = {
    PAGER = "less -R";
  };

  systemd.user.startServices = true;

}
