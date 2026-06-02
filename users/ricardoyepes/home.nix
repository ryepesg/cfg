{ config, pkgs, user, ... }:

{
  home.username = "${user}";

  home.stateVersion = "22.11";

  imports = [
    ./packages.nix
    ./files.nix
    ../programs/git
    ../programs/zsh
    ../programs/vim
    ../programs/restic
  ];

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  home.sessionVariables = {
    PAGER = "less -R";
  };

}
