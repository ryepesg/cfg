#
#  Shared macOS `system.defaults` — portable, non-secret UI/UX preferences.
#  Factored out so every consumer shares one source of truth:
#    - this repo: imported natively by ./configuration.nix
#    - downstream flakes: imported via the `cfg` flake input
#  Keep this free of host-specific / secret settings (those stay in each
#  configuration.nix: hostname, casks, activationScripts, stateVersion).
#
#  flake.nix
#   └─ ./hosts/darwin
#       ├─ ./configuration.nix
#       └─ ./system-defaults.nix *
#

{ ... }:

{
  system.defaults = {
    NSGlobalDomain = {
      # Global macOS system settings
      KeyRepeat = 1;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      AppleWindowTabbingMode = "manual"; # Prefer Windows over Tabs (Preview etc.) — AeroSpace-friendly
    };
    dock = {
      # Dock settings
      autohide = true;
      orientation = "bottom";
      showhidden = true;
      tilesize = 40;
      expose-group-apps = true; # Group windows by app in Mission Control (AeroSpace-friendly)
      mru-spaces = false; # Don't auto-rearrange Spaces (keeps AeroSpace workspaces aligned)
    };
    finder = {
      # Finder settings
      QuitMenuItem = false; # I believe this probably will need to be true if using spacebar
    };
    trackpad = {
      # Trackpad settings
      Clicking = true;
      TrackpadRightClick = true;
    };
  };
}
