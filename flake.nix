#  flake.nix *
#
#  A shared, non-secret Nix LIBRARY + VERSION ANCHOR for the machine
#  flakes. They import this as `inputs.cfg`,
#  consume its module outputs, AND follow its pinned inputs (`cfg/nixpkgs`,
#  `cfg/home-manager`, `cfg/darwin`) so every machine locks to the SAME versions.
#  Bump versions once here, then `nix flake update cfg` on each machine.
#  No machine or user identity lives here.

{
  description = "Shared Nix library + version anchor imported by machine flakes";

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

  # home-manager / darwin are pinned here purely as the shared version anchor
  # (consumers follow `cfg/home-manager`, `cfg/darwin`). cfg's own outputs only
  # need nixpkgs (for the dev shell); the modules below are plain paths, evaluated
  # in the consumer's context.
  outputs = { self, nixpkgs, ... }:
    let
      systemDarwin = "aarch64-darwin";
      pkgs = import nixpkgs {
        system = systemDarwin;
        config.allowUnfree = true;
      };
    in
    {
      # Reusable modules consumed downstream via `inputs.cfg.<...>`. Add more as
      # needed, e.g. homeManagerModules.git = ./users/programs/git;
      darwinModules.systemDefaults = ./hosts/darwin/system-defaults.nix;
      homeManagerModules.zsh = ./users/programs/zsh/default.nix;

      # `nix develop` for working on this repo (just / nixpkgs-fmt / manix / …).
      devShell."${systemDarwin}" = import ./shells/shell.nix { inherit pkgs; };
    };
}
