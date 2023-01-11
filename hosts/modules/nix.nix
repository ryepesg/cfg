{ config, lib, pkgs, inputs, ... }:

{

  ## Nixpkgs

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = false;
  };

  ## Nix

  nix = {

    package = pkgs.nix;
    # package = pkgs.nixVersions.stable;

    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      auto-optimise-store = true
    '';

    registry.nixpkgs.flake = inputs.nixpkgs;

    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
    ];

    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      sandbox = true;
      max-jobs = lib.mkDefault 8;
      auto-optimise-store = true;
      trusted-users = [
        "root"
      ];
    };

    gc = {
      automatic = true;
      interval.Day = 7;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

  };

}