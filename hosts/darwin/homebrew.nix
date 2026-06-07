#
#  Shared macOS Homebrew *policy* — the portable onActivation behaviour wanted
#  identically on every laptop. Consumed by machine flakes via
#  `inputs.cfg.darwinModules.homebrew`. NOTE: only the policy lives here; the
#  per-machine `casks`/`brews`/`taps` lists stay in the private machine layer
#  (they differ per machine, `cleanup = "zap"` uninstalls anything not listed,
#  and the app inventory must not be published in this public repo).
#
#  flake.nix
#   └─ ./hosts/darwin
#       ├─ ./system-defaults.nix
#       ├─ ./jankyborders.nix
#       └─ ./homebrew.nix *
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
