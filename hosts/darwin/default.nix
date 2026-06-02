#
#  These are the different profiles that can be used when building on MacOS
#
#  flake.nix
#   └─ ./darwin
#       ├─ ./default.nix *
#       ├─ configuration.nix
#       └─ home.nix
#

{ lib, inputs, nixpkgs, home-manager, darwin, user, ... }:

let
  system = "aarch64-darwin"; # System architecture
in
{
  macbook = darwin.lib.darwinSystem {
    inherit system;
    specialArgs = { inherit user inputs; };
    modules = [
      ./configuration.nix # darwin system settings (defaults, homebrew, nix, fonts)

      home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup"; # back up clobbered dotfiles instead of failing
        home-manager.extraSpecialArgs = { inherit user inputs; };
        home-manager.users.${user} = {
          imports = [
            ../../users/ricardoyepes/home.nix
            ./files.nix
          ];
        };
      }
    ];
  };
}
