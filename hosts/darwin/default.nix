#
#  These are the different profiles that can be used when building on MacOS
#
#  flake.nix
#   └─ ./darwin
#       ├─ ./default.nix *
#       ├─ configuration.nix
#       └─ home.nix
#

{ lib, inputs, nixpkgs, home-manager, darwin, user, ...}:

let
  system = "x86_64-darwin";                                 # System architecture
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
in
{
  macbook = darwin.lib.darwinSystem {                       # MacBook8,1 "Core M" 1.2 12" (2015) A1534 ECM2746 profile
    inherit system;
    specialArgs = { inherit user inputs; };
    modules = [                                             # Modules that are used
      home-manager.darwinModules.home-manager {             # Home-Manager module that is used
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit user; };  # Pass flake variable
        home-manager.users.${user} = {
          imports = [
                  ./files.nix
                  ./configuration.nix
                  ../../users/ricardoyepes/home.nix
                  ../modules/nix.nix
                  ../modules/direnv.nix
                  ../modules/locale.nix
                  ../modules/xfonts.nix
                  ../modules/security.nix
                  ../modules/network.nix
                  ../modules/dns.nix
                  ../modules/home.nix
          ];
        };
      }

    ];
  };
}
