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
      url = "github:nix-darwin/nix-darwin";
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
      darwinModules.jankyborders = ./hosts/darwin/jankyborders.nix;
      darwinModules.homebrew = ./hosts/darwin/homebrew.nix;
      darwinModules.base = ./hosts/darwin/base.nix;
      homeManagerModules.zsh = ./users/programs/zsh/default.nix;
      homeManagerModules.git = ./users/programs/git;
      homeManagerModules.nvim = ./users/programs/editors/nvim;

      # The shared home baseline — CLI package set + the canonical program
      # modules (zsh / git / neovim). Machine flakes import this and add only a
      # thin per-machine delta, so installing a CLI tool once reaches both
      # laptops. See ./users/programs/default.nix. (`homeManagerModules.zsh`
      # above stays exposed for anything that wants zsh alone; `default` already
      # bundles it, so don't import both in the same home config.)
      homeManagerModules.default = ./users/programs/default.nix;

      # Scaffold for a private per-machine flake that imports this library:
      # follows cfg/{nixpkgs,home-manager,darwin} and imports
      # homeManagerModules.default + darwinModules.systemDefaults, with the
      # machine identity (user / hostname / casks) left to fill in.
      #   nix flake init -t github:ryepesg/cfg
      templates.default = {
        path = ./templates/machine;
        description = "Private macOS machine flake that imports cfg";
      };

      # `nix develop` for working on this repo (just / nixpkgs-fmt / manix / …).
      devShell."${systemDarwin}" = import ./shells/shell.nix { inherit pkgs; };
    };
}
