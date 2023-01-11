{ config, lib, pkgs, ... }:

{

  # Keeping .conf locally to simplify editor extensions
  xdg.configFile."i3/config".source = ./i3.conf;

  # services.screen-locker = {
  #   enable = true;
  #   inactiveInterval = 5;
  #   lockCmd = "${pkgs.i3lock}/bin/i3lock -f -c 000000";
  # };

}
