#
#  Apps
#
#  flake.nix
#   ├─ ./hosts
#       └─ ./modules
#   │      └─ ...
#   └─ ./users
#       └─ ./modules
#           └─ default.nix *
#               └─ ...
#

{ inputs, config, pkgs, ... }:
let
  login = "ricardoyepes";
in
{

  imports = [
    # Home-Manager module that is used
    inputs.home-manager.nixosModules.home-manager {              
      home-manager.extraSpecialArgs = { inherit user; };
    }
  ];

  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];

  # nixos configuration for user
  users.extraUsers."${login}" = {
    createHome = true;
    # wheel is for sudo / doas
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "disk"
      "networkmanager"
    ];
    group = "users";
    home = "/home/" + login;
    isNormalUser = true;
    uid = 1000;
    # Don't forget to set a password with ‘passwd’.
  };

  nix.settings.trusted-users = [ login ];

  services.gnome.gnome-keyring.enable = true;
  
  # home-manager configuration for user
  home-manager.users."${login}" = import ./home.nix;

}
