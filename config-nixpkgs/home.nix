{ config, pkgs, ... }:

let
  user = "ricardoyepes";
in
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "${user}";
  home.homeDirectory = "/Users/${user}";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;


  home.packages = with pkgs; [
    vim
    wget
    bat
    fd
    ripgrep
    gnugrep
    tree
    pstree
    jq
    yq
    fzf
    coreutils
    htop
    firefox
    tmux
    git
    dotnet-sdk_7
    fsharp
    xclip
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
      ms-vscode.PowerShell
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

  home.file.".config/i3/config" = {
    source = ./i3-config;
  };

  home.file.".zshrc" = {
    source = ./zshrc;
  };

  home.file.".vimrc" = {
    source = ./vimrc;
  };

  home.file.".gitconfig" = {
    source = ./gitconfig;
  };

  home.file.".tmux.conf" = {
    source = ./tmux.conf;
  };

}
