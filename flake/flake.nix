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
          modules = [ ./configuration.nix ];
        };
      };

#      darwinConfigurations = (                                              # Darwin Configurations
#        import ./darwin {
#          inherit (nixpkgs) lib;
#          inherit inputs nixpkgs home-manager darwin user;
#        }
#      );

      homeConfigurations = {
        ${user} = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          #username = "${user}";
          #homeDirectory = "/home/${user}";

          # home configuration modules
          modules = [
            ./home.nix
          ];
          # extraSpecialArgs to pass through arguments to home.nix
        };
      };

      #${user} = self.homeConfigurations.${user}.activationPackage;
      #defaultPackage.${system} = self.${user};

    };
}
