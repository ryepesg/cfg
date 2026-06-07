#
#  Shared macOS Homebrew *policy only* — the portable onActivation behaviour
#  wanted identically on every laptop. Consumed by machine flakes via
#  `inputs.cfg.darwinModules.homebrew`. No taps/brews/casks lists here; those
#  are declared per-machine.
#

{ ... }:

{
  homebrew = {
    enable = true; # Manage Homebrew declaratively via nix-darwin
    onActivation = {
      autoUpdate = true; # Run `brew update` before each activation
      upgrade = true; # Upgrade outdated formulae/casks on each activation
      cleanup = "zap"; # Uninstall + zap anything not declared in the machine's lists
      extraFlags = [ "--force" ]; # Force non-interactive bundle (needed for the zap cleanup to proceed)
    };
  };
}
