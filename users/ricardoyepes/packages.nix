{ config, pkgs, user, ... }:
let
  inherit (pkgs) callPackage;
  restic-s3 = pkgs.callPackage ../programs/restic/restic-s3.nix { homeDir = "${config.home.homeDirectory}"; };
in
{

  home.packages = with pkgs; [

    # system info
    htop
    pfetch

    # docs
    manix
    tldr

    # spelling
    diction
    aspell
    aspellDicts.es
    aspellDicts.en

    # development
    git
    just
    google-cloud-sdk

    # shell ergonomics
    coreutils
    tree
    pstree
    nushell
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

    # extra editors
    helix

    # formats
    jq
    yq

    # networking
    nmap
    dig
    host

    # backup and secret management
    sops
    age
    rclone
    restic-s3

    (
      let
        my-python-packages = python-packages: with python-packages; [
          toolz
          ipython
        ];
        python-with-my-packages = python3.withPackages my-python-packages;
      in
      python-with-my-packages
    )
  ];

  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      dracula-theme.theme-dracula
      vscodevim.vim
      yzhang.markdown-all-in-one
      ms-python.python
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

  home.file.".logseq/" = {
    source = ../programs/logseq;
    recursive = true;
  };

  home.file."./.init.sh" = {
    source = ./init.sh;
  };

  home.file."./.ssh/config" = {
    source = ../programs/ssh-config;
  };

  home.sessionVariables = {
    PAGER = "less -R";
  };

}
