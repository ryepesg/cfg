#  flake.nix *
#   ├─ ./darwin
#   │   └─ default.nix

{
  description = "Personal configuration for MacOS";

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

  };

  outputs = inputs @ { self, nixpkgs, home-manager, darwin, ... }:
    let
      systemDarwin = "aarch64-darwin";
      pkgs = import nixpkgs {
        system = systemDarwin;
        config.allowUnfree = true;
      };
      user = "ricardoyepes";
    in
    {

      # Reusable, machine-agnostic modules consumed by downstream PRIVATE flakes
      # (personal `conf`, the work computer) via `inputs.cfg.<...>`. These are the
      # public/shared half; nothing here names a user or a machine.
      darwinModules.systemDefaults = ./hosts/darwin/system-defaults.nix;
      homeManagerModules.zsh = ./users/programs/zsh/default.nix;

      darwinConfigurations = (
        # Darwin Configurations
        import ./hosts/darwin {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs home-manager darwin user;
        }
      );

      # nix develop
      devShell."${systemDarwin}" = import ./shells/shell.nix { inherit pkgs; };

    };
}
