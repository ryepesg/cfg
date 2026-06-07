#
#  Shared macOS jankyborders config — a colored border around the AeroSpace-focused
#  window (AeroSpace has no native border). Non-secret and portable; consumed by
#  machine flakes via `inputs.cfg.darwinModules.jankyborders`.
#

{ ... }:

{
  services.jankyborders = {
    # Colored border around the focused window
    enable = true; # Runs `borders` as a launchd agent (AeroSpace has no native border)
    active_color = "0xFFFFFFFF"; # Focused window: solid white
    inactive_color = "0x00000000"; # Unfocused windows: transparent (only the active one is highlighted)
    width = 7.0;
    hidpi = true; # Retina-sharp border on the MacBook display
  };
}
