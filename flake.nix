#  flake.nix *
#   ├─ ./darwin
#   │   └─ default.nix

{
  description = "Personal configuration for Linux and MacOS";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl = {                                                             # OpenGL
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs @ { self, nixpkgs, home-manager, darwin, nixgl, ... }:   # Function that tells my flake which to use and what do what to do with the dependencies.
    let
      system = "x86_64-linux";
      # pkgs = nixpkgs.legacyPackages."${system}";
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;
      user = "ricardoyepes";
    in {

      nixosConfigurations.ricardoyepes = lib.nixosSystem {
          specialArgs = inputs;
          system = system;
          modules = [
            ./hosts/linux-vm
            ./users/ricardoyepes
            ./users/root
          ];
        };


      darwinConfigurations = (                                              # Darwin Configurations
        import ./hosts/darwin {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs home-manager darwin user;
        }
      );

      # nix develop
      devShell."${system}" = import ./shells/shell.nix { inherit pkgs; };


    };
}
