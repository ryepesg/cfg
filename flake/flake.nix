{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, darwin, ... }@attrs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;
      user = "ricardoyepes";
    in {

      nixosConfigurations = {
        ricardoyepes = lib.nixosSystem {
          inherit system;
          specialArgs = attrs;
          modules = [ 
            ./configuration.nix

            home-manager.nixosModules.home-manager {              # Home-Manager module that is used.
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              #home-manager.extraSpecialArgs = {
              #  inherit user;
              #  host = {
              #    hostName = "desktop";     #For Xorg iGPU  | Videocard 
              #    mainMonitor = "HDMI-A-3"; #HDMIA3         | HDMI-A-1
              #    secondMonitor = "DP-1";   #DP1            | DisplayPort-1
              #  };
              #};                                                  # Pass flake variable
              home-manager.users.${user} = {
                # imports = [(import ./home.nix)] ++ [(import ./desktop/home.nix)];
                imports = [ ./home.nix ];
              };
            }

          ];
        };

      };

#      darwinConfigurations = (                                              # Darwin Configurations
#        import ./darwin {
#          inherit (nixpkgs) lib;
#          inherit inputs nixpkgs home-manager darwin user;
#        }
#      );

    # Standalone Home manager
     # homeConfigurations = {
     #   ${user} = home-manager.lib.homeManagerConfiguration {
     #     inherit pkgs;

     #     # home configuration modules
     #     modules = [
     #       ./home.nix
     #     ];
     #     # extraSpecialArgs to pass through arguments to home.nix
     #   };
     # };

      #${user} = self.homeConfigurations.${user}.activationPackage;
      #defaultPackage.${system} = self.${user};

    };
}
