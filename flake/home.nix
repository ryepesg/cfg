{ config, pkgs, user, ... }:

{
  home.username = "${user}";

  home.stateVersion = "22.11";

  imports = [
    ./packages.nix
    ./files.nix
    ./programs/git
    ./programs/i3
    ./programs/zsh
    ./programs/vim
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.sessionVariables = {
    PAGER = "less -R";
  };

  systemd.user.startServices = true;

}
