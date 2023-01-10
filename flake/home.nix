{ config, pkgs, user, homedir, ... }:

{
  home.username = "${user}";

  # Home Manager needs information about the
  # paths it should manage.
  #home.homeDirectory = "${homedir}";
  #home.homeDirectory = "$HOME";

  home.stateVersion = "22.11";

  imports = [
    ./packages.nix
    ./profiles/x.nix
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
