{ config, pkgs, ... }:

{

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-gtk
    pkgs.xdg-desktop-portal-wlr
  ];

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbOptions = "caps:escape";
    libinput.enable = true; # Enable touchpad
    dpi = 135;
  };

  environment.systemPackages = with pkgs; [
    kitty
    libnotify
  ];

}
