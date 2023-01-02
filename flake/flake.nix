{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  # outputs = { self, nixpkgs, home-manager }:
  outputs = { self, nixpkgs, ... }@attrs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        ricardoyepes = lib.nixosSystem {
          inherit system;
          specialArgs = attrs;
          modules = [ ./configuration.nix ];
        };
      };
    };
}
