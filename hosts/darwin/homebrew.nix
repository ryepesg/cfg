#
#  Shared macOS Homebrew *policy only* — the portable onActivation behaviour
#  wanted identically on every laptop. Consumed by machine flakes via
#  `inputs.cfg.darwinModules.homebrew`. No taps/brews/casks lists here; those
#  are declared per-machine.
#

{ lib, ... }:

{
  homebrew = {
    enable = true; # Manage Homebrew declaratively via nix-darwin
    onActivation = {
      autoUpdate = true; # Run `brew update` before each activation
      upgrade = true; # Upgrade outdated formulae/casks on each activation
      # Forced off (was "zap"): under drs's `sudo --user` activation, brew bundle's
      # cleanup pass rewrites Homebrew's trust store and wipes ~/.homebrew/trust.json
      # every rebuild (Homebrew 6.0 made tap-trust mandatory), so a `brew trust` for
      # AeroSpace's third-party tap never survived. No cleanup = trust granted once
      # sticks. Chosen over HOMEBREW_NO_REQUIRE_TAP_TRUST=1, which disables the trust
      # check globally. Trade-off: undeclared casks are no longer auto-removed.
      cleanup = lib.mkForce "none";
      # No extraFlags: bundle install/upgrade are non-interactive already; --force
      # only existed to make the (now-disabled) cleanup zap execute for real, and on
      # install it just adds --overwrite — silent file clobbering next to nix-managed
      # binaries.
    };
  };

  environment.systemPath = [ "/opt/homebrew/bin" ];
}
